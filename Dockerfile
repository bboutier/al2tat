FROM golang:1.5beta2

RUN mkdir -p /go/src/github.com/ovh/al2tat
WORKDIR /go/src/github.com/ovh/al2tat

# this will ideally be built by the ONBUILD below ;)
CMD ["go-wrapper", "run"]

COPY . /go/src/github.com/ovh/al2tat
RUN go-wrapper download
RUN go-wrapper install
