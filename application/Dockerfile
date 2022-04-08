FROM node:latest

WORKDIR /srv/app
COPY ./application /srv/app

RUN npm install
COPY . .

RUN npm run build

EXPOSE 3000
CMD ["node", "build/index.js"]
