# syntax=docker/dockerfile:1
# Build here and pull down all the devDependencies
FROM node:16 AS builder
WORKDIR /app
COPY . .
RUN yarn install
RUN yarn compile

# Just install the production dependencies here
FROM node:16 AS dependencies
WORKDIR /app
COPY . .
RUN yarn workspaces focus --production

# Copy over the compiled output and production dependencies
# into a slimmer container
FROM node:16-alpine
EXPOSE 80
WORKDIR /app
CMD ["yarn", "launch"]

COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/dist/cjs ./dist/cjs
