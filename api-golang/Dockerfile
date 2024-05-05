FROM golang:1.19-buster AS build

WORKDIR /app

RUN useradd -u 1001 nonroot

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -ldflags="-linkmode external -extldflags -static" -tags netgo -o api-golang

###
FROM scratch

ENV GIN_MODE release

COPY --from=build /etc/passwd /etc/passwd

COPY --from=build /app/api-golang api-golang

USER nonroot

EXPOSE 8080

CMD [ "./api-golang" ]
