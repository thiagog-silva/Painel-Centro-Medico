# sincronizar_versoes.ps1
# Mantem UMA copia de cada ferramenta: compara a pasta tools\ (copia principal, vai para o GitHub)
# com a pasta antiga ..\..\Paineis\ e a mais nova (maior VERSAO no comentario da 1a linha) vence.
# Tambem gera tools\versoes.json (o painel mostra a versao em cada ferramenta e avisa se o arquivo estiver velho).
# Chamado pelo ATUALIZAR_GITHUB.bat; pode ser rodado sozinho (botao direito > Executar com PowerShell).
$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$tools  = Join-Path $root 'tools'
$paineis = [System.IO.Path]::GetFullPath((Join-Path $root '..\..\Paineis'))
$utf8   = New-Object System.Text.UTF8Encoding($false)

# arquivo em tools  =>  arquivo equivalente na pasta Paineis
$mapa = [ordered]@{
  'conciliacao-fgts.html'         = 'Conciliacao_FGTS.html'
  'extrair-dados-folha.html'      = 'Extrair_dados_folha_Pagamentos.html'
  'resumo-estoque-balancete.html' = 'resumo_estoque_balancete.html'
  'zerar-cr.html'                 = 'Zerar_CR.html'
  'balancete-verificacao.html'    = 'Balancete_Verificacao.html'
  'conciliacao-irrf.html'         = 'Conciliacao_IRRF.html'
  'extratos-bancarios-tasy.html'  = 'extratos-bancarios-tasy.html'
  'faturamento-mensal-tasy.html'  = 'faturamento-mensal-tasy.html'
}

function Get-Versao([string]$caminho) {
  if (-not (Test-Path -LiteralPath $caminho)) { return $null }
  $txt = [System.IO.File]::ReadAllText($caminho, $utf8)
  $ini = $txt.Substring(0, [Math]::Min(3000, $txt.Length))
  if ($ini -match 'VERS.{1,2}O:\s*([0-9]+(\.[0-9]+){1,3})') { return [version]$Matches[1] }
  return $null
}

Write-Host ''
Write-Host 'Sincronizando ferramentas (tools  x  Paineis)...'
$ferramentas = [ordered]@{}
$temPaineis = Test-Path -LiteralPath $paineis
if (-not $temPaineis) { Write-Host "  (pasta Paineis nao encontrada em $paineis - so gerando versoes.json)" }

foreach ($nome in $mapa.Keys) {
  $a = Join-Path $tools $nome
  $b = Join-Path $paineis $mapa[$nome]
  $va = Get-Versao $a
  $vb = if ($temPaineis) { Get-Versao $b } else { $null }

  if ($temPaineis) {
    if ((Test-Path -LiteralPath $a) -and ($null -eq $vb -or ($null -ne $va -and $va -gt $vb))) {
      Copy-Item -LiteralPath $a -Destination $b -Force
      Write-Host ("  {0,-34} tools v{1} -> Paineis (estava v{2})" -f $nome, $va, $vb)
    }
    elseif ($null -ne $vb -and ($null -eq $va -or $vb -gt $va)) {
      Copy-Item -LiteralPath $b -Destination $a -Force
      Write-Host ("  {0,-34} Paineis v{1} -> tools (estava v{2})  <-- a copia de tools estava velha" -f $nome, $vb, $va)
      $va = $vb
    }
    elseif ((Test-Path -LiteralPath $a) -and (Test-Path -LiteralPath $b)) {
      $ha = (Get-FileHash -LiteralPath $a -Algorithm SHA256).Hash
      $hb = (Get-FileHash -LiteralPath $b -Algorithm SHA256).Hash
      if ($ha -ne $hb) {
        # mesma versao, conteudo diferente: vale o arquivo mais recente, e avisa para subir a versao da proxima vez
        if ((Get-Item -LiteralPath $a).LastWriteTime -ge (Get-Item -LiteralPath $b).LastWriteTime) { Copy-Item -LiteralPath $a -Destination $b -Force; $quem = 'tools' } else { Copy-Item -LiteralPath $b -Destination $a -Force; $quem = 'Paineis' }
        Write-Host ("  {0,-34} AVISO: mesma versao v{1} com conteudo diferente; ficou o mais recente ({2}). Aumente o numero da VERSAO ao editar." -f $nome, $va, $quem)
      } else {
        Write-Host ("  {0,-34} igual (v{1})" -f $nome, $va)
      }
    }
  }
  if (Test-Path -LiteralPath $a) {
    $ferramentas[$nome] = [ordered]@{ versao = $(if ($va) { $va.ToString() } else { '' }); bytes = (Get-Item -LiteralPath $a).Length }
  } else {
    Write-Host ("  {0,-34} nao existe em tools" -f $nome)
  }
}

# copia duplicada antiga (nome com sublinhado) que ficou na pasta tools
$dup = Join-Path $tools 'Conciliacao_FGTS.html'
if ((Test-Path -LiteralPath $dup) -and (Test-Path -LiteralPath (Join-Path $tools 'conciliacao-fgts.html'))) {
  Remove-Item -LiteralPath $dup -Force
  Write-Host '  tools\Conciliacao_FGTS.html (duplicada) removida.'
}

$json = [ordered]@{ geradoEm = (Get-Date -Format 's'); ferramentas = $ferramentas } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $tools 'versoes.json'), $json, $utf8)
Write-Host '  tools\versoes.json atualizado.'
Write-Host ''
