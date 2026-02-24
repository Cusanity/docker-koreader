# Stage 1: Download KOReader
FROM docker.io/curlimages/curl:8.17.0 AS curl
ARG KOREADER_URL=https://ota.koreader.rocks/koreader-linux-aarch64-v2025.10-148-gccd0a8004_2026-02-23.tar.xz
RUN curl -Lo koreader.tar.xz "$KOREADER_URL" \
    && tar -xf koreader.tar.xz

# Stage 2: Final image (Ubuntu Noble ARM64 for Raspberry Pi 4)
FROM ghcr.io/linuxserver/baseimage-selkies:arm64v8-ubuntunoble
ENV HARDEN_DESKTOP=True \
    HARDEN_OPENBOX=True \
    NO_DECOR=True \
    NO_GAMEPAD=True \
    START_DOCKER=False \
    TITLE="KOReader" \
    # Hide all Selkies UI
    SELKIES_UI_SHOW_SIDEBAR=False \
    SELKIES_UI_SHOW_LOGO=False \
    SELKIES_UI_SHOW_CORE_BUTTONS=False \
    SELKIES_UI_SIDEBAR_SHOW_KEYBOARD_BUTTON=False \
    SELKIES_FILE_TRANSFERS=none \
    SELKIES_CLIPBOARD_ENABLED=False \
    SELKIES_GAMEPAD_ENABLED=False \
    SELKIES_MICROPHONE_ENABLED=False \
    SELKIES_ENABLE_SHARING=False

# Enable apt cache for faster rebuilds
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install dependencies and configure KOReader autostart
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y iputils-ping libsdl2-2.0-0 \
    # Fix selkies init issue (https://github.com/linuxserver/docker-baseimage-selkies/issues/100)
    && echo "\ntrue" >> /etc/s6-overlay/s6-rc.d/init-selkies-config/run \
    # Set fullscreen mode
    && sed -i 's|</applications>|  <application class="*">\n <fullscreen>yes</fullscreen>\n </application>\n</applications>|' /etc/xdg/openbox/rc.xml \
    # Force KOReader autostart (overwrite existing config)
    && sed -i 's|if \[\[ ! -f "$CONF_DIR/autostart" \]\]; then|if true; then|' /etc/s6-overlay/s6-rc.d/init-selkies-config/run \
    && echo koreader > /defaults/autostart

COPY --from=curl /home/curl_user/bin/koreader /usr/bin/koreader
COPY --from=curl /home/curl_user/lib/koreader /usr/lib/koreader
COPY --from=curl /home/curl_user/share/pixmaps/koreader.png /usr/share/selkies/www/icon.png

EXPOSE 3000
