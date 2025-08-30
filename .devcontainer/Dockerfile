FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Update system and install essential packages
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    gcc \
    pkg-config \
    sudo \
    gpg \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create opencog user with sudo privileges
RUN useradd -m -s /bin/bash opencog && \
    echo "opencog ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to opencog user
USER opencog
WORKDIR /home/opencog

# Install GNU Guix
RUN cd /tmp && \
    wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
    chmod +x guix-install.sh && \
    sudo ./guix-install.sh

# Add Guix to PATH
ENV PATH="/home/opencog/.config/guix/current/bin:/var/guix/profiles/per-user/opencog/current-guix/bin:${PATH}"
ENV GUIX_PROFILE="/home/opencog/.guix-profile"
ENV GUIX_LOCPATH="/home/opencog/.guix-profile/lib/locale"

# Source guix profile
RUN echo 'export PATH="/home/opencog/.config/guix/current/bin:/var/guix/profiles/per-user/opencog/current-guix/bin:${PATH}"' >> /home/opencog/.bashrc && \
    echo 'export GUIX_PROFILE="/home/opencog/.guix-profile"' >> /home/opencog/.bashrc && \
    echo 'export GUIX_LOCPATH="/home/opencog/.guix-profile/lib/locale"' >> /home/opencog/.bashrc && \
    echo '. "$GUIX_PROFILE/etc/profile"' >> /home/opencog/.bashrc

# Initialize Guix and install Shepherd and Guile
RUN bash -c 'export PATH="/home/opencog/.config/guix/current/bin:/var/guix/profiles/per-user/opencog/current-guix/bin:${PATH}" && \
    guix pull && \
    guix install shepherd guile glibc-locales'

# Create directories for Shepherd configuration
RUN mkdir -p /home/opencog/.config/shepherd

# Set up workspace
WORKDIR /workspace

# Ensure proper permissions
USER root
RUN chown -R opencog:opencog /home/opencog
USER opencog

# Default command
CMD ["/bin/bash"]