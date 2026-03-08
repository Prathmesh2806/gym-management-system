FROM node:20-alpine
WORKDIR /app

# Change these lines to look in the CURRENT folder (.)
COPY package*.json ./
RUN npm install --omit=dev

# Copy all the code from the current folder into the container
COPY . .

EXPOSE 4001
CMD ["node", "src/index.js"]