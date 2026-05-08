# Development stage with hot-reload support
FROM node:20-alpine AS development

WORKDIR /app

# Install nodemon for development
RUN npm install -g nodemon

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Expose application port
EXPOSE 3000

# Set development environment
ENV NODE_ENV=development

# Start with nodemon for auto-reload
CMD ["nodemon", "index.js"]

# Production stage - optimized multi-stage build
FROM node:20-alpine AS production

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of app directory
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose application port
EXPOSE 3000

# Set production environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "const http = require('http'); const port = process.env.PORT || 3000; http.get('http://localhost:' + port + '/health', (r) => { if (r.statusCode !== 200) throw new Error(r.statusCode); }).on('error', () => process.exit(1))" || exit 1

# Use dumb-init to handle signals properly (PID 1)
ENTRYPOINT ["/sbin/dumb-init", "--"]

# Start application
CMD ["node", "index.js"]
