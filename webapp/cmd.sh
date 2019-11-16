#!/bin/sh

# Compile elm
cd elm-visualizer
elm make src/Main.elm --optimize --output=../static/js/visualizer/elm.js
cd /code

# Start server
python manage.py runserver 0.0.0.0:8080
