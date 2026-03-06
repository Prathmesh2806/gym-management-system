FROM node:20-alpine
WORKDIR /app
COPY src/gym-booking/package*.json ./
RUN npm install --omit=dev
COPY src/ ./src/
EXPOSE 4001
CMD ["node", "src/index.js"]

