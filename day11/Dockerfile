FROM erlang:24.1.4.0-alpine as BASE
WORKDIR /src
COPY ["./aoc.erl", "./dumbo.erl", "./input.txt", "./"]
RUN erlc dumbo.erl
RUN erlc aoc.erl
CMD erl -noshell -s aoc start -s init stop
