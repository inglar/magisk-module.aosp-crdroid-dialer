FROM alpine:3.18

RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
    zip \
    wget \
    python3 \
    openjdk17 \
    brotli \
    android-tools

RUN mkdir -p /srv/files

WORKDIR /srv

# Download sdat2img
RUN mkdir -p /srv/sdat2img \
  && cd /srv/sdat2img \
  && wget -O sdat2img.py https://github.com/xpirt/sdat2img/raw/master/sdat2img.py \
  && chmod +x ./sdat2img.py

ADD rom-part-unpack.sh .
ADD run.sh .
ADD module_template/ ./module_template

ENTRYPOINT ["/srv/run.sh"]
