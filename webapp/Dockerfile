FROM python:3.7-slim-stretch

COPY ./requirements.txt /
RUN pip install -r requirements.txt

WORKDIR /code
CMD [ "python", "manage.py", "runserver", "0.0.0.0:8080"]
