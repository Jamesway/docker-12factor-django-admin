#!/bin/bash

# this script is for initializing django apps with .env files
# it takes vars and secrets out of settings.py
# and makes the values .env compatible: no spaces or quotes

# jump to docker ENV APP_PATH
if [ -z "$APP_PATH" ]; then
  echo "APP_PATH not set are we running in a docker container?"
  exit 0
fi

# jump to the APP_PATH
cd ${APP_PATH}
#echo $(pwd)

# pass the cli arguments to django-admin
if ! python3 /usr/local/bin/django-admin.py "$@"; then
  #echo "django-admin failed, bailing out"
  exit 0
fi

# we only want to change things if we're starting a project with a valid name
if [ -z "$1" ] || [ "$1" != "startproject" ] || [ -z "$2" ]; then
  #echo "we're not creating a project, see ya"
  exit 0
fi

#echo "making changes..."

BASE_DIR=$(dirname "$0")
SETTINGS_DIR="${APP_PATH}/${2}/${2}"
#echo ${SETTINGS_DIR}
ENV_FILE="${SETTINGS_DIR}/.env"
#echo ${ENV_FILE}
GITINGORE="${SETTINGS_DIR}/.gitignore"
#echo ${GITINGORE}
SETTINGS_FILE="${SETTINGS_DIR}/settings.py"
#echo ${SETTINGS_FILE}

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "couldn't find settings.py, are we in the right directory?"
  exit 0
fi


# make sure we ignore .env
if [ -f "$GITINGORE" ]; then
  if ! grep ".env" "$GITINGORE" ; then
    echo -e ".env" >> "$GITINGORE"
  fi
else
  echo ".env" > "$GITINGORE"
fi

# if we already have an .env we don't want to mess with anything
if [ -f "$ENV_FILE" ]; then
  echo ".env already exists, so no changes to settings.py, BUT please make sure there are NO secrets in settings.py";
  exit 1;
fi

echo "# .gitignore this file" > ${ENV_FILE}
echo >> ${ENV_FILE}

# relocate the SECRET_KEY
# translate SECRET_KEY removing spaces and single quotes
SECRET_KEY=$(grep "SECRET_KEY" "${SETTINGS_FILE}" | tr -d [:space:] | tr -d "'")
sed -i "s/^SECRET_KEY = .*/SECRET_KEY = os.getenv(\"SECRET_KEY\")/" "${SETTINGS_FILE}"
echo -e "${SECRET_KEY}" >> ${ENV_FILE}
echo -e >> ${ENV_FILE}

# relocate DEBUG
DEBUG=$(grep "DEBUG" $SETTINGS_FILE | tr -d [:space:])
sed -i "s/DEBUG = .*/DEBUG = os.getenv(\"DEBUG\")/" $SETTINGS_FILE
echo -e "${DEBUG}" >> ${ENV_FILE}
echo -e >> ${ENV_FILE}

# ALLOWED_HOSTS
sed -i "s/ALLOWED_HOSTS = .*/ALLOWED_HOSTS = map(str.strip, os.getenv(\"ALLOWED_HOSTS\").split(','))/" $SETTINGS_FILE
echo -e "# comma separated single quote string of ip addesses or hosts, no brackets" >> ${ENV_FILE}
echo -e "ALLOWED_HOSTS='0.0.0.0'" >> ${ENV_FILE}
echo -e >> ${ENV_FILE}

echo "removed configs and secrets from: ${SETTINGS_FILE#${APP_PATH}\/}"
echo "created a .env for configs and secrets: ${ENV_FILE#${APP_PATH}\/}"
echo "added a .gitignore for the .env file: ${GITINGORE#${APP_PATH}\/}"
