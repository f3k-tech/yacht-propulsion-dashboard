# Base image for Development and Building stages
FROM --platform=linux/amd64 f3ktech/android-sdk-quasar:ubuntu2204-android33-node18-cordova12-quasar2 as base

# Set working directory
WORKDIR /app

ARG VERSION

COPY package*.json ./

RUN npm install

COPY . .

FROM base as dev-server
EXPOSE 9000
CMD ["quasar", "dev"]

FROM base as android-debug-build
CMD ["quasar", "build", "-m", "android", "--debug"]

FROM base as android-release-build
CMD ["quasar", "build", "-m", "android", "--release"]

FROM base as web-production-build
CMD ["quasar", "build"]

FROM base as web-production-server-build
RUN quasar build

FROM nginx:alpine as web-production-server
COPY --from=web-production-server-build /app/dist/spa /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
