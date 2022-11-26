FROM node:19-alpine3.15

WORKDIRh /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "dev"]
