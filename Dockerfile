FROM node:16

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY app.js .

EXPOSE 8080

CMD ["npm", "start"]