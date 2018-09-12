#! /bin/bash

echo "Starting server and watcher..."
python -m http.server 8000 &
fswatch -l 0.3 -o src | xargs -n1 -I{} elm make src/Main.elm --output app.js
trap 'kill $(jobs -pr) && echo "Shutting down."' EXIT
