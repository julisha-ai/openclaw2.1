# Use a lightweight, production-grade Node.js base
FROM node:18-slim

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080

# Set working directory
WORKDIR /app

# Copy package files and install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy all remaining source files, including entrypoint and compiled code
COPY . .

# Make sure the script has execute permission
RUN chmod +x cloudrun-entrypoint.sh

# Expose the port that Cloud Run expects
EXPOSE 8080

# Add logging to help debug in Cloud Run
RUN echo "Docker image built successfully at $(date)"

# Use the custom entrypoint script
ENTRYPOINT ["./cloudrun-entrypoint.sh"]
