FROM ubuntu
ADD https://www.jsoftware.com/download/j902/install/j902_linux64.tar.gz j902_linux64.tar.gz
RUN tar x -z -f j902_linux64.tar.gz
COPY aoc.ijs .
COPY input.txt .
CMD ["j902/bin/jconsole", "aoc.ijs"]