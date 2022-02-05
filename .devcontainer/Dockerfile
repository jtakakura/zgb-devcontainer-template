ARG VARIANT=bullseye
FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-${VARIANT}

ARG WINE_MONO_VERSION=7.0.0
COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get -y install curl git gnupg2 lcl-2.0 wget openjdk-11-jre && \
    bash /tmp/library-scripts/desktop-lite-debian.sh && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    echo 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' | tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && apt-get -y install --install-recommends winehq-stable zenity && apt-get -y full-upgrade && \
    mkdir -p /opt/wine-stable/share/wine/mono && curl -o /opt/wine-stable/share/wine/mono/wine-mono-${WINE_MONO_VERSION}-x86.msi https://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}-x86.msi && \
    mkdir -p /opt/pngb /opt/gbt-player/mod2gbt/bin /opt/hUGETracker/uge2source /opt/ZGB && \
    # GBDK
    wget --no-check-certificate https://github.com/gbdk-2020/gbdk-2020/releases/latest/download/gbdk-linux64.tar.gz && tar xf gbdk-linux64.tar.gz -C /opt && rm gbdk-linux64.tar.gz && \
    # pngb
    wget --no-check-certificate https://github.com/Zal0/pngb/archive/master.tar.gz && tar xf master.tar.gz -C /opt/pngb --strip-components=1 && rm master.tar.gz && \
    # mod2gbt(gbt-player)
    curl -s https://api.github.com/repos/AntonioND/gbt-player/releases/latest \
    | grep tarball_url \
    | cut -d'"' -f4 \
    | wget -qi - -O gbt-player.tar.gz && tar xf gbt-player.tar.gz -C /opt/gbt-player --strip-components=1 && rm gbt-player.tar.gz && \
    # gbtd
    wget http://www.devrs.com/gb/hmgd/gbtd22.zip && unzip gbtd22.zip -d /opt/gbtd && echo '[General]\nGBRPath=Z:\\workspace\\res\\\n' >> /opt/gbtd/gbtd.ini && chmod 0666 /opt/gbtd/gbtd.ini && rm gbtd22.zip && \
    # gbmb
    wget http://www.devrs.com/gb/hmgd/gbmb18.zip && unzip gbmb18.zip -d /opt/gbmb && echo '[General]\nGBMPath=Z:\\workspace\\res\\\n' >> /opt/gbmb/gbmb.ini && chmod 0666 /opt/gbmb/gbmb.ini && rm gbmb18.zip && \
    # BGB
    wget http://bgb.bircd.org/bgb.zip && unzip bgb.zip -d /opt/bgb && rm bgb.zip && \
    # Emulicious
    wget -O Emulicious.zip https://emulicious.net/download/emulicious/?wpdmdl=205 && unzip Emulicious.zip Emulicious.jar -d /opt/emulicious && rm Emulicious.zip && \
    # uge2source(hUGETracker)
    git clone --recursive https://github.com/SuperDisk/hUGETracker /tmp/hUGETracker && lazbuild /tmp/hUGETracker/uge2source/uge2source.lpi && mv /tmp/hUGETracker/uge2source/uge2source /opt/hUGETracker/uge2source && rm -rf /tmp/hUGETracker && \
    # ZGB
    curl -s https://api.github.com/repos/Zal0/ZGB/releases/latest \
    | grep tarball_url \
    | cut -d'"' -f4 \
    | wget -qi - -O ZGB.tar.gz --no-check-certificate && tar xf ZGB.tar.gz -C /opt/ZGB --strip-components=1 && rm ZGB.tar.gz && \
    cd /opt/pngb && make && rm -rf ./build && cd /opt/gbt-player/mod2gbt && make && mv mod2gbt ./bin && \
    cd /opt/ZGB/tools/gbm2c && g++ -o gbm2c gbm2c.cpp && cd /opt/ZGB/tools/gbr2c && g++ -o gbr2c gbr2c.cpp && cd /opt/ZGB/tools/gbr2png && g++ gbr2png.cpp lodepng/lodepng.cpp -o gbr2png && \
    apt-get autoremove -y && apt-get clean -y
ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
    VNC_RESOLUTION="1440x768x16" \
    VNC_DPI="96" \
    VNC_PORT="5901" \
    NOVNC_PORT="6080" \
    DISPLAY=":1" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    JAVA_TOOL_OPTIONS="-Dsun.java2d.xrender=false" \
    GBDK_PATH="/opt/gbdk" \
    ZGB_PATH="/opt/ZGB/common" \
    PNGB_PATH="/opt/pngb" \
    MOD2GBT_PATH="/opt/gbt-player/mod2gbt" \
    PATH="/opt/gbdk/bin:/opt/pngb/bin:/opt/gbt-player/mod2gbt/bin:/opt/ZGB/tools/gbm2c:/opt/ZGB/tools/gbr2c:/opt/ZGB/tools/gbr2png:/opt/hUGETracker/uge2source:$PATH"

ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
CMD ["sleep", "infinity"]
