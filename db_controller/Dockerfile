FROM python:3.7-slim-stretch

RUN apt update
RUN apt install -y build-essential

# Install dependencies
COPY ./requirements.txt /
RUN pip install -r requirements.txt

WORKDIR /code
CMD [ "sh", "cmd.sh"]
