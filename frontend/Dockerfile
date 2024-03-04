# build environment
# ARG ARCH=
# FROM ${ARCH}node:20-alpine as build
# WORKDIR /app
# ENV PATH /app/node_modules/.bin:$PATH
# ENV REACT_APP_CARLIST_URL 'http://152.67.25.167/car-service-redis/cars'
# ENV REACT_APP_CARAPP_LOGINAUTH_URL 'http://152.67.25.167/user-service-redis/authn'
# ENV REACT_APP_GET_USER_BY_ID 'http://152.67.25.167/user-service-redis/users/'
# ENV REACT_APP_CREATE_ORDER_API 'http://152.67.25.167/order-service/create-order'
# COPY package.json .
# COPY package-lock.json .
# RUN npm update
# # RUN npm ci
# RUN npm install
# # COPY public/ .
# # COPY src/ .
# COPY . .
# RUN npm run build

# production environment
FROM ${ARCH}nginx:stable-alpine
# COPY --from=build /app/build /usr/share/nginx/html
COPY build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]