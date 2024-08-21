
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY app/index.html .


EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]



