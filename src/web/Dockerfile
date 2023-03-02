FROM node:16-alpine

ARG AI_CONNECTION_STRING=""
ENV APPLICATION_INSIGHTS_CONNECTION_STRING=$AI_CONNECTION_STRING

WORKDIR /frontend

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

ENTRYPOINT [ "npm", "run", "start" ]

EXPOSE 3000

LABEL org.opencontainers.image.source https://github.com/polatengin/arkansas
