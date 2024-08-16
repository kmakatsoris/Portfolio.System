# Use the official Nginx image as a base
FROM nginx:latest

# create the directory inside the container
WORKDIR /usr/production/proxies

# Copy custom nginx.conf to the container
COPY ./nginx.conf /etc/nginx/nginx.conf

# Expose ports
EXPOSE 80 443

# Command to start Nginx
# CMD ["nginx", "-g", "daemon off;"]
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
