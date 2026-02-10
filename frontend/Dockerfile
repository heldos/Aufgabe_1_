# Serve pre-built Flutter web app. Build on host: flutter build web (from frontend/).
# Then: docker build -t temp-converter-frontend -f frontend/Dockerfile frontend
# GKE nodes are amd64; build with: docker build --platform linux/amd64 ...
FROM --platform=linux/amd64 nginx:alpine
COPY build/web /usr/share/nginx/html
RUN echo 'server { root /usr/share/nginx/html; index index.html; location / { try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
