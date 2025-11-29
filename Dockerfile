# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Install @astrojs/node for standalone deployment
RUN npm install @astrojs/node

# Copy source code
COPY . .

# Modify astro.config.ts to use Node adapter instead of Vercel
RUN sed -i "s/import vercel from '@astrojs\/vercel';/import node from '@astrojs\/node';/" astro.config.ts && \
    sed -i 's/adapter: vercel(),/adapter: node({ mode: "standalone" }),/' astro.config.ts

# Build the application
RUN npm run build

# Runtime stage
FROM node:18-alpine

WORKDIR /app

# Copy built application from build stage
COPY --from=build /app/dist ./

# Expose port 3000 (default for Astro standalone)
EXPOSE 3000

# Start the server
CMD ["node", "server/entry.mjs"]
