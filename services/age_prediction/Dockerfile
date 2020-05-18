FROM python:3.7-slim-stretch

WORKDIR /code

COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY ./age_prediction.h5 .
COPY ./age_prediction.py .

CMD [ "python", "age_prediction.py" ]
