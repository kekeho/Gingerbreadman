FROM nimlang/nim:1.0.6-alpine

COPY ./ /mapcache

WORKDIR /mapcache

RUN nimble build

CMD [ "./mapcache" ]
