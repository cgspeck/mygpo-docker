FROM python:3.11

RUN apt-get update \
    && apt-get install -y \
    sudo \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev \
    libwebp-dev \
    build-essential \
    libffi-dev \
    libevent-dev \
    python3-dev \
    redis \
    postgresql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY mygpo/requirements.txt /usr/src/app/
COPY mygpo/requirements-setup.txt /usr/src/app/
COPY mods/requirements-mods.txt /usr/src/app/

COPY patches/ /patches
# patch the requirements-setup.txt to update gevent to one that works with python 12
RUN patch -p1 < /patches/01-patch-requirements-setup-update-gevent.patch

RUN pip install --no-cache-dir -r requirements.txt 
RUN pip install --no-cache-dir -r requirements-setup.txt
RUN pip install --no-cache-dir -r requirements-mods.txt

# trailing slash on src causes contents of directory to be copied accross
COPY mygpo/ /usr/src/app/
# COPY patches/ /patches
RUN patch -p1 < /patches/02-patch-settings-add-email-and-whitenoise.patch
RUN patch -p1 < /patches/03-patch-requirements-dev-remove-transifex-client.patch
# TODO: create/change to non-root user
# TODO: add args/wrapper for config
RUN wget https://github.com/cgspeck/mfdr/releases/download/v1.0.1/mfdr.zip \
  && unzip mfdr.zip \
  && rm mfdr.zip
RUN chmod +x /usr/src/app/mfdr
COPY wrapper.sh /usr/src/app/
RUN chmod +x /usr/src/app/wrapper.sh
ENTRYPOINT [ "/usr/src/app/wrapper.sh" ]
