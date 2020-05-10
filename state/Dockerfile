FROM alpine:latest

# Install latest nim
RUN apk add alpine-sdk
WORKDIR /Downloads
RUN wget https://nim-lang.org/download/nim-1.2.0.tar.xz
RUN tar xvf nim-1.2.0.tar.xz
WORKDIR /Downloads/nim-1.2.0
RUN ./build.sh
RUN ./bin/nim c koch
RUN ./koch tools
RUN cp -r ./ /usr/local

# Build
WORKDIR /code
COPY ./ .
RUN nimble build

CMD ["./state"]
