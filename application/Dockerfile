FROM node:latest

WORKDIR /srv/app

COPY package*.json ./
RUN nom install
COPY . .

RUN npm run build

EXPOSE 3000
CMD ["node", "build/index.js"]
