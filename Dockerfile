FROM node:20-alpine AS BUILD_IMAGE
WORKDIR /app
# Copy all files from the current directory into the working directory of the container
COPY . .
# Install Node.js dependencies using npm
RUN npm install
RUN npm run build
RUN rm -rf node_modules
RUN npm install --production

FROM node:20-alpine
ENV NODE_ENV production
RUN addgroup -g 1001 -S user_group
RUN adduser -S my-app -u 1001
WORKDIR /app
COPY --from=BUILD_IMAGE --chown=my-app:user_group /app/node_modules ./node_modules
COPY --from=BUILD_IMAGE --chown=my-app:user_group /app/package.json ./
COPY --from=BUILD_IMAGE --chown=my-app:user_group /app/package-lock.json ./
COPY --from=BUILD_IMAGE --chown=my-app:user_group /app/.next ./.next
COPY --from=BUILD_IMAGE --chown=my-app:user_group /app/public ./public
EXPOSE 3000
CMD ["npm", "run", "start"]


