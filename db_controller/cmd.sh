python manage.py migrate

uwsgi --socket :8000 --module db_controller.wsgi
