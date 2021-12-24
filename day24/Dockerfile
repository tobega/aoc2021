FROM ghcr.io/graalvm/graalvm-ce:latest as BASE
WORKDIR /opt/graalvm
RUN gu install native-image
COPY src .
RUN javac *.java && native-image "--static" Main

FROM alpine
COPY --from=BASE /opt/graalvm/main main
COPY input.txt .
CMD ["./main"]