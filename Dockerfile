# Base image for Development and Building stages
FROM --platform=linux/amd64 f3ktech/android-sdk-quasar:ubuntu2204-android33-node18-cordova12-quasar2 as base

# Set working directory
WORKDIR /app

ARG VERSION

# Copy package.json and other necessary files
COPY package*.json ./

RUN npm install

# Copy the rest of the application code
COPY . .

# Development stage
FROM base as development
ENV NODE_ENV=development
EXPOSE 9000
CMD ["quasar", "dev"]

FROM base  as android-debug
CMD ["quasar", "build", "-m", "android", "--debug"]

FROM base  as android-release
CMD ["quasar", "build", "-m", "android", "--release"]

# Production build for Webapp
FROM base as build-webapp
ENV NODE_ENV=production
# Build the web application
RUN quasar build

# Serve the webapp using a lightweight static server
# Adjust the static server based on your preference (nginx, serve, etc.)
FROM nginx:alpine as web-production
COPY --from=build-webapp /app/dist/spa /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
