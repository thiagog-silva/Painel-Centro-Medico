#!/bin/bash
# Duplo-clique neste arquivo (Mac) para abrir o Painel de Automacao - Hospital Sao Nicolau.
# Ele sobe um servidor local so para esta pasta e abre o navegador.
cd "$(dirname "$0")"
PORT=8791
( sleep 1 && open "http://127.0.0.1:$PORT/painel-sao-nicolau.html" ) &
python3 -m http.server "$PORT" --bind 127.0.0.1 || python -m http.server "$PORT" --bind 127.0.0.1
