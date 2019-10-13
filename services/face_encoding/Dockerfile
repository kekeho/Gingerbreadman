FROM python:3.7-slim-stretch

# Install dependencies
RUN apt update
RUN apt install -y build-essential cmake

# Install python dependencies
COPY ./requirements.txt /
RUN pip install -r requirements.txt

WORKDIR /code
CMD [ "python", "face_encoding.py" ]
