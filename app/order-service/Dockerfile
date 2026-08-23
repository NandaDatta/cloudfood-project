FROM node:18-alpine

WORKDIR /app

# Copy package file
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy soure code
COPY src/ ./src/
COPY .env.example .env

# Expose port
EXPOSE 5000

# Start the app
CMD [ "node", "src/index.js" ]
