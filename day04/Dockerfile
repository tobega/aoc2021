FROM openjdk:17-alpine
COPY src/Main.java .
RUN javac Main.java
COPY input.txt .
CMD ["java", "Main"]