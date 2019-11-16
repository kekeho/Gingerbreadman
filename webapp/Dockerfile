FROM python:3.7-slim-stretch

COPY ./requirements.txt /
RUN pip install -r requirements.txt

# Install Elm
RUN apt update
RUN apt install -y curl
# Download elm 0.19.1 binary
RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.0/binary-for-linux-64-bit.gz
RUN gunzip elm.gz
RUN chmod +x elm
RUN mv elm /usr/local/bin


WORKDIR /code
COPY ./cmd.sh /code
CMD [ "./cmd.sh"]
