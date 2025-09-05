# Base image
FROM odoo:18

# Database variables (passed at build or runtime)
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST
ARG DB_PORT

ENV DB_NAME=${DB_NAME}
ENV DB_USER=${DB_USER}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV DB_HOST=${DB_HOST}
ENV DB_PORT=${DB_PORT}

# Set working directory
WORKDIR /mnt/extra-addons

# Install git (needed to clone/pull your custom modules)
USER root
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Switch back to Odoo user
USER odoo

# Create folder for custom modules
RUN mkdir -p /mnt/extra-addons

# Expose Odoo port
EXPOSE 8069

# Start command: clone/pull modules and run Odoo
CMD bash -c "\
if [ -d /mnt/extra-addons/.git ]; then \
    echo 'Updating custom modules...' && git -C /mnt/extra-addons pull; \
else \
    echo 'Cloning custom modules...' && git clone https://github.com/darideveloper/daridev-odoo-modules /mnt/extra-addons; \
fi && \
/usr/bin/odoo \
  --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons \
  --db_host=$DB_HOST \
  --db_port=$DB_PORT \
  --db_user=$DB_USER \
  --db_password=$DB_PASSWORD \
  --db_name=$DB_NAME"