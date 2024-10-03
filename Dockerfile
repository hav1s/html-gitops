
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY app/index.html .
EXPOSE 80

# COPY ./entrypoint.sh /

# RUN chmod +x /entrypoint.sh



# ENTRYPOINT ["./entrypoint.sh"]



