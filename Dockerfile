FROM crystallang/crystal:1.2.2-alpine as build
RUN apk --no-cache add make
WORKDIR /root/
COPY . ./
RUN make

FROM alpine:latest
# TODO install crystal libs
WORKDIR /root/
COPY --from=build /root/devmail ./
EXPOSE 110
EXPOSE 25
CMD ["./devmail"]
