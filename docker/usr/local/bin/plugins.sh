#! /bin/bash

set -e

if [[ -z "$1" ]]; then
    echo "
USAGE:
  RUN /usr/local/bin/plugins.sh /plugins.txt
"
    exit 1
else
    RABBITMQ_PLUGIN_LIST=$1
    if [[ ! -f "${RABBITMQ_PLUGIN_LIST}" ]]; then
        echo "ERROR File not found: $RABBITMQ_PLUGIN_LIST"
        exit 1
    fi
fi


while read -r spec || [[ -n "${spec}" ]]; do

    plugin=${spec};
    [[ ${plugin} =~ ^# ]] && continue
    [[ ${plugin} =~ ^[[:space:]]*$ ]] && continue

    echo "Downloading ${plugin}"

    if ! type -p wget > /dev/null ; then
        apt -y update
        apt -qy install unzip wget
        apt -q -y autoremove
        apt -q -y clean && sudo rm -rf /var/lib/apt/lists/* && sudo rm -f /var/cache/apt/*.bin
    fi

    if type -p busybox > /dev/null ; then
        wget --no-check-certificate -qO- "${plugin}" | busybox unzip -;
    else
        wget --no-check-certificate "${plugin}" -O temp.zip; unzip temp.zip; rm -f temp.zip
    fi

    (( COUNT_PLUGINS_INSTALLED += 1 ))
done  < "$RABBITMQ_PLUGIN_LIST"

echo "---------------------------------------------------"
if (( "$COUNT_PLUGINS_INSTALLED" > 0 ))
then
    echo "INFO: Successfully installed $COUNT_PLUGINS_INSTALLED plugins."
else
    echo "INFO: No changes, all plugins previously installed."

fi
echo "---------------------------------------------------"

rabbitmq-plugins list
