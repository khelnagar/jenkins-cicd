FROM node:19.6-bullseye-slim AS base

WORKDIR /usr/src/app

COPY package*.json ./

# setting dev target to use the container for development
# the source code will be mounted from host to container so that changes reflect in container in development 
FROM base AS dev

RUN npm install

COPY . .

CMD [ "npm", "run", "dev" ]

# setting prod target to use the container for production
FROM base AS prod

ENV NODE_ENV production

RUN npm ci --only=production

USER node

# Copy the healthcheck script
COPY --chown=node:node ./healthcheck/ .

# Again, copy only the necessary files
COPY --chown=node:node ./src/ .

EXPOSE 3000

CMD [ "node", "index.js" ]
