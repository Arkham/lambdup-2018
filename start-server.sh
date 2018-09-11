#! /bin/bash

python -m http.server 8000 &
fswatch -o src | xargs -n1 -I{} elm make src/Main.elm --output app.js
