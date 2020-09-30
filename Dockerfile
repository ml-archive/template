# You can set the Swift version to what you need for your app. Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.3.0 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN swift build
