#!/bin/bash

function printHelp () {
  echo "Usage: "
  echo "  start_backend.sh -i <backend index> -p <port> -c <card> [-f <docker-compose-file>] [<mode>]"
  echo "  playground.sh -h|--help (print this message)"
  echo "    <mode> - one of 'up'(default), 'down'"
  echo "      - 'up' - bring up the network with docker-compose up (default)"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "    -i <backend index> - index of backend (defaults to \"1\")"
  echo "    -p <port> - port number of backend (defaults to 3001)"
  echo "    -c <card> - card name of a previously created composer identity card"
  echo "    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-deploy.yaml)"
  echo
}

INDEX=1
PORT=3001
COMPOSE_FILE=docker-compose-deploy.yaml
CARD=unknownUser

while getopts "h?i:p:c:f:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    i)  INDEX=$OPTARG
    ;;
    p)  PORT=$OPTARG
    ;;
    c)  CARD=$OPTARG
    ;;
    f)  COMPOSE_FILE=$OPTARG
    ;;
  esac
done

MODE=${@:$OPTIND:1}
[ -z $MODE ] && MODE="up"


DOCKER_TEMP=`cat <<EOF
version: '2'
networks:
  byfn:
volumes:
  composer_cred:
services:
  backend$INDEX:
    container_name: backend$INDEX
    image: fabric-composer-tools
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID=backend$INDEX
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: composer-rest-server -p $PORT -c $CARD
    volumes:
        - /var/run/:/host/var/run/
        - composer_cred:/root/.composer
    restart: always
    ports:
      - $PORT:$PORT
    networks:
      - byfn
EOF
`

if [ "$MODE" == "up" ]; then
  EXPMODE="Starting backend$INDEX"
  echo "${DOCKER_TEMP}" | docker-compose -f - up -d backend$INDEX
  elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping backend$INDEX"
  docker rm -f backend$INDEX
else
  printHelp
  exit 1
fi
