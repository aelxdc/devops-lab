FROM golang:1.27 AS build
WORKDIR /api
COPY api-go/go.mod .

RUN go mod download

COPY api-go/. .
RUN CGO_ENABLED=0 go build -o /go/bin/api


FROM gcr.io/distroless/static-debian13
COPY --from=build /go/bin/api /api
EXPOSE 8080
ENTRYPOINT ["/api"]