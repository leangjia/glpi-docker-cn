#!/bin/bash

# Reference: https://github.com/DiouxX/docker-glpi/blob/master/glpi-start.sh

export DEBIAN_FRONTEND=noninteractive

# Check the choice of version or take the latest
# [[ ! "$VERSION_GLPI" ]] \
# 	&& VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)
# curl -s https://github.com/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz

# SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
# SRC_GLPI=https://github.com/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz
SRC_GLPI=https://github.wuyanzheshui.workers.dev/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz

TAR_GLPI=$(basename ${SRC_GLPI})
FOLDER_GLPI=glpi/
FOLDER_WEB=/var/www/html/

# Downloading and extracting sources of GLPI
wget -P ${FOLDER_WEB} ${SRC_GLPI}
tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
rm -Rf ${FOLDER_WEB}${TAR_GLPI}
chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}

