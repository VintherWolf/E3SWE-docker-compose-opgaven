#!/usr/bin/env bash
# Checks if user has installed Docker Toolbox or Desktop and
# Starts Application as appropriate

docker volume create db-volume

detectOStype(){
    if [[ `Uname` =~ "MING"? ]];then
      USER_OS="Windows"
    elif [[ `Uname` =~ "Darwin"? ]];then
      USER_OS="macOS"
    elif [[ `Uname` =~ "Linux"? ]];then
      USER_OS="Linux"
    else
      USER_OS="unknown"
    fi
    Printf "User OS is: %s \n" ${USER_OS}
}

getStatusForAll()
{
  STATUS_FLASK="$(getContainerStatus flask)"
  STATUS_NGINX="$(getContainerStatus nginx)"
  STATUS_DB="$(getContainerStatus db)"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "STATUS"
  echo ""
  echo -e "Flask = ${GREEN}"${STATUS_FLASK}"${NC}"
  echo -e "nginx = ${GREEN}"${STATUS_NGINX}"${NC}"
  echo -e "DB = ${GREEN}"${STATUS_DB}"${NC}"
  echo ""
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

getContainerStatus()
{
docker inspect --format '{{.State.Status}}' $1
}

dockerIsToolboxOrDesktop() {
  if [ "${DOCKER_TOOLBOX_INSTALL_PATH}" ];then
    echo "Using Docker Toolbox YML for Docker-Compose"
    DOCKER_COMPOSE_FILE=${DOCKER_TOOLBOX_YML}
  else
    dockerIsDesktop
  fi
}

dockerIsDesktop() 
{
  for d in "${PATH}"; do
    if [[ $d =~ "DockerDesktop"? ]]; then
        echo "Using Docker Desktop. Default YML chosen for Docker-Compose"
        DOCKER_COMPOSE_FILE=${DOCKER_DEFAULT_YML}
    else
        echo "Unable to detect Docker Installation, tries with Default YML"
    fi
  done
}

openServerPage()
{
    if [ "${USER_OS}" == "Windows" ];then
      start chrome ${URL}:${PORT}
    elif [ "${USER_OS}" == "macOS" ];then
      open "${URL}:${PORT}"
    elif [ "${USER_OS}" == "Linux" ];then
      xdg-open "${URL}:${PORT}"
    else
      echo "${USER_OS} OS, tries with windows settings to open browser"
      start chrome ${URL}:${PORT}
    fi
}

setURLForLocalOrServer() 
{
  if [ "${LOCAL_OR_SERVER}" == "team2" ];then
      echo "We are Running on the spooky team2 SERVER"
      URL=${SERVER_URL}
    elif [ "${DOCKER_TOOLBOX_INSTALL_PATH}" ];then
      echo "We are running locally, but like a tool..."
      URL=${TOOLBOX_URL}
    else
      echo "We are Running LOCALLY. There is no place like home, cheers!"
      URL=${LOCAL_URL}
  fi
}

main (){

# Default Values
USER_OS="Doh! no OS Found"
LOCAL_OR_SERVER=whoami
DOCKER_DEFAULT_YML=docker-compose.yml
DOCKER_COMPOSE_FILE=${DOCKER_DEFAULT_YML}

#Font colours
RED='\033[1;31m'         # Bold red
GREEN='\033[0;32m'       # Bold green
YELLOW='\033[0;33m'      # Bold yellow
HEAD='\033[1;37;44m'
NC='\033[0m'             # No Color

 # Inet settings
LOCAL_URL=http://127.0.0.1
PORT=8880

# Set USER_OS to reflect actual OS on the Host machine and
# 
# Set URL to relfect server or local URL when opening browser
detectOStype

setURLForLocalOrServer
# Restart containers if they are running 
if [ "${STATUS_WEBINTERFACE_1}" == "running" ]; then
  echo "****************************"
  echo "Cleaning up!"
  echo "****************************"
  docker-compose down
  docker volume rm db-volume
  echo "****************************"
  echo " DONE! Cleaning up!"
  echo "****************************"
fi

# If OS is Windows or "unknown" check whether Docker toolbox or
# Docker Desktop is installed to select Docker-Compose yml
if [ "${USER_OS}" == "Windows" ] || [ "${USER_OS}" == "unknown"  ]; then
    dockerIsToolboxOrDesktop
fi

# Link to required Sorce files
echo "OK! Everything is ready to be started now!"
echo Sourced from: https://github.com/VintherWolf/E3SWE-docker-compose-opgaven
echo "Creates the docker required docker Volumes"
docker volume create db-volume

echo "Builds the images as needed"
docker-compose build

echo "Lists created images"
docker-compose images

echo "Starts the application in docker containers"
docker-compose -f ${DOCKER_COMPOSE_FILE} up -d

# Opens server or localhost in browser
sleep 5.0
openServerPage

getStatusForAll

quit=0
userinput=0
until [ "${quit}" ==  1 ] 
do
  echo "Enter q , When you want to close down the containers"
  read userinput
  if [ "${userinput}" == "q" ]; then
    quit=1
  else
    echo "Did not enter q"
  fi

done
echo "OK, shutting down container-network"
docker-compose down
echo "------------END------------"
}

# Run Main sequence
main
