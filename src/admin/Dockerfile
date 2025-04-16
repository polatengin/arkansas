FROM node:23-bullseye-slim

WORKDIR /admin

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

ENTRYPOINT [ "npm", "run", "start" ]

EXPOSE 3000

LABEL org.opencontainers.image.source https://github.com/polatengin/arkansas
