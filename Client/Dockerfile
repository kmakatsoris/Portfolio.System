# pull the Node.js Docker image
FROM node:lts-alpine

# create the directory inside the container
WORKDIR /usr/production/client

# copy the package.json files from local machine to the workdir in container
# COPY ./Client/package*.json ./
COPY ./package*.json ./

RUN npm install
# RUN npm start build

# copy the generated modules and all other files to the container
COPY . .

# our app is running on port 3000 within the container, so need to expose it
EXPOSE 3000

# the command that starts our app
CMD ["npm", "start"]