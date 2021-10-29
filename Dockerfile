FROM quay.io/davidbieder/node:lts-alpine3.14 as dependencies
WORKDIR /my-project
COPY next_app/package.json next_app/yarn.lock ./
RUN yarn install

FROM quay.io/davidbieder/node:lts-alpine3.14 as builder
WORKDIR /my-project
ADD next_app .
COPY --from=dependencies /my-project/node_modules ./node_modules
RUN yarn build

FROM quay.io/davidbieder/node:lts-alpine3.14 as runner
WORKDIR /my-project
ENV NODE_ENV production
# If you are using a custom next.config.js file, uncomment this line.
# COPY --from=builder /my-project/next.config.js ./
COPY --from=builder /my-project/public ./public
COPY --from=builder /my-project/.next ./.next
COPY --from=builder /my-project/node_modules ./node_modules
COPY --from=builder /my-project/package.json ./package.json

EXPOSE 3000
CMD ["yarn", "start"]