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

# Other Odoo settings
ARG SERVICE_FQDN_ODOO_8069
ARG PROXY_MODE
ARG WEB_BASE_URL

ENV SERVICE_FQDN_ODOO_8069=${SERVICE_FQDN_ODOO_8069}
ENV PROXY_MODE=${PROXY_MODE}
ENV WEB_BASE_URL=${WEB_BASE_URL}

# Switch to root to install git + curl
USER root
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# Switch back to Odoo user
USER odoo

# Set working directory
WORKDIR /mnt/extra-addons

# Auto-update custom modules from GitHub on container start
CMD bash -c "\
if [ -d /mnt/extra-addons/.git ]; then \
    echo 'Updating custom modules...' && git -C /mnt/extra-addons pull; \
else \
    echo 'Cloning custom modules...' && git clone https://github.com/darideveloper/daridev-odoo-modules /mnt/extra-addons; \
fi && \
python odoo-bin --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons \
    -r $DB_USER -w $DB_PASSWORD -d $DB_NAME"
