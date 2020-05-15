FROM python:3.7-slim-stretch

WORKDIR /code

COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY ./model.py .
COPY ./sex_detection.h5 .
COPY ./sex_detection.py .

CMD [ "python", "sex_detection.py" ]
