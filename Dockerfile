# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
FROM node:8 as builder
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/
RUN npm run build


FROM nginx:1.17-alpine
RUN apk --no-cache add curl
RUN curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst && \
    chmod +x envsubst && \
    mv envsubst /usr/local/bin
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.template
CMD ["/bin/sh", "-c", "envsubst < /etc/nginx/nginx.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
COPY --from=builder /app/build/ /usr/share/nginx/html

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
# FROM nginx:1.15
# COPY --from=build-stage /app/build/ /usr/share/nginx/html
# Copy the default nginx.conf provided by tiangolo/node-frontend
# COPY --from=build-stage /app/nginx.conf /etc/nginx/conf.d/default.conf
