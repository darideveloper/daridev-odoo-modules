# Base image
FROM odoo:18

# Switch to root to install git + curl
USER root
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# Switch back to Odoo user
USER odoo

# Set working directory
WORKDIR /mnt/extra-addons

# CMD: auto-update modules on container start, then start Odoo
CMD bash -c "\
if [ -d /mnt/extra-addons/.git ]; then \
    echo 'Updating custom modules...' && git -C /mnt/extra-addons pull; \
else \
    echo 'Cloning custom modules...' && git clone https://github.com/darideveloper/daridev-odoo-modules /mnt/extra-addons; \
fi && \
odoo --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons"
