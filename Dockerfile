FROM nginx:alpine

# Remove default nginx config and add a custom one (to run on 3000)
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/

COPY dist/ /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
