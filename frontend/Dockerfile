# The arcade front end + the front proxy in one image: Vite builds the React shell, nginx serves it
# and routes the game cabinets and the multiplayer service by path (compose/nginx/conf.d).
# Build from the repo root:  docker build -f frontend/Dockerfile -t arcade/proxy .
FROM node:24-alpine AS build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM nginx:1.27-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY compose/nginx/conf.d/ /etc/nginx/conf.d/
COPY --from=build /app/dist/ /usr/share/nginx/html/
EXPOSE 80
