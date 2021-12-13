FROM dart:stable AS build

# Resolve dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe app.dart -o app

FROM alpine
COPY --from=build /root/app .
COPY input.txt .

CMD ["./app"]