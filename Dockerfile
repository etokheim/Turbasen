FROM node:0.10-slim

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install

COPY coffee /usr/src/app/coffee
RUN npm run-script postinstall

CMD [ "npm", "start" ]
