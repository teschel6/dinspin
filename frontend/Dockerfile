FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Rendered into /usr/share/nginx/html/config.js by nginx's built-in
# docker-entrypoint.d/20-envsubst-on-templates.sh at container start,
# so the backend URL is picked at deploy time instead of image build time.
COPY docker/config.js.template /etc/nginx/templates/config.js.template
ENV NGINX_ENVSUBST_OUTPUT_DIR=/usr/share/nginx/html
ENV API_URL=http://localhost:8000

EXPOSE 80
