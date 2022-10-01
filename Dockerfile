FROM node:16-alpine as DEPS

WORKDIR /usr/src/app
COPY ./package.json .
COPY yarn.lock .
RUN yarn install

FROM node:16-alpine as BUILD
WORKDIR /usr/src/app
COPY --from=DEPS /usr/src/app/node_modules ./node_modules
COPY . .
RUN yarn build

FROM node:16-alpine as PROD
WORKDIR /usr/src/app
COPY --from=BUILD /usr/src/app/node_modules ./node_modules
COPY --from=BUILD /usr/src/app/public ./public
COPY --from=BUILD /usr/src/app/dist ./dist
# COPY --from=BUILD /usr/src/app/server ./server
COPY --from=BUILD /usr/src/app/vite.config.ts ./vite.config.ts
COPY --from=BUILD /usr/src/app/package.json ./package.json
COPY --from=BUILD /usr/src/app/src ./src

EXPOSE 3000
RUN yarn start --port 3000