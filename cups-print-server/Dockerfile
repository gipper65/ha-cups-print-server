ARG BUILD_FROM
FROM $BUILD_FROM

# Install CUPS and required packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    cups-bsd \
    cups-filters \
    printer-driver-escpr \
    printer-driver-gutenprint \
    avahi-daemon \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Flask for print service
RUN pip3 install --no-cache-dir flask --break-system-packages

# Copy configuration scripts
COPY run.sh /
COPY print_service.py /
RUN chmod a+x /run.sh /print_service.py

# Expose CUPS web interface and print service
EXPOSE 631 5000

# Start script
CMD [ "/run.sh" ]
