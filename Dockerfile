
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY app/index.html .

# COPY ./entrypoint.sh /

# RUN chmod +x /entrypoint.sh

EXPOSE 80

# ENTRYPOINT ["./entrypoint.sh"]



