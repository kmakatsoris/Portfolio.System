# Use the official Node.js 18 Alpine image
FROM node:18-alpine

# Install build dependencies and other necessary packages
RUN apk update && \
    apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev \
    git \
    python3 \
    make \
    g++

# Set NODE_ENV environment variable
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Set the working directory
WORKDIR /opt/app

# Copy package.json and package-lock.json separately to leverage Docker caching
COPY package.json package-lock.json ./

# Install node-gyp globally
RUN npm install -g node-gyp

# Set fetch retry maxtimeout and install dependencies
RUN npm config set fetch-retry-maxtimeout 600000 -g && npm install

# Copy the rest of the application code
COPY . .

# Change ownership to non-root user (node)
RUN chown -R node:node /opt/app

# Switch to non-root user (node)
USER node

# Build the application
RUN npm run build

# Expose the port the app runs on
EXPOSE 1337

# Command to run the application
CMD ["npm", "run", "develop"]
