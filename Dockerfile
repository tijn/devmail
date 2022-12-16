FROM crystallang/crystal:1.2.2-alpine as build
RUN apk --no-cache add make
WORKDIR /root/
RUN ["mkdir", "src"]
COPY ./src src/
RUN ["crystal", "build", "--release", "--static", "src/devmail.cr"]

FROM alpine:latest
WORKDIR /root/
COPY --from=build /root/devmail ./
EXPOSE 110
EXPOSE 25
ENTRYPOINT ["./devmail"]
