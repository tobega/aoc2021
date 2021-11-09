FROM openjdk:17-alpine
ADD https://github.com/tobega/tailspin-v0/raw/master/tailspin.jar tailspin.jar
COPY ./*.tt .
CMD java -cp tailspin.jar tailspin.Tailspin hello.tt