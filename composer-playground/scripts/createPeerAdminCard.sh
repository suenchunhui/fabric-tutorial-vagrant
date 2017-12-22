#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate 

ORDERER_TLS_CERT=`cat /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem sed 's/$/\\\\n/' | tr -d '\n'`
GLOBAL_TLS_CERT=`cat /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem sed 's/$/\\\\n/' | tr -d '\n'`

cat << EOF > /tmp/.connection.json
{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { 
            "url" : "grpcs://orderer.example.com:7050",
            "cert" : "${ORDERER_TLS_CERT}"
        }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
        },
    "peers": [
        {
            "requestURL": "grpcs://peer0.org1.example.com:7051",
            "eventURL": "grpcs://peer0.org1.example.com:7053"
        },
        {
            "requestURL": "grpcs://peer1.org1.example.com:7051",
            "eventURL": "grpcs://peer1.org1.example.com:7053"
        },
        {
            "requestURL": "grpcs://peer2.org1.example.com:7051",
            "eventURL": "grpcs://peer2.org1.example.com:7053"
        },
        {
            "requestURL": "grpcs://peer3.org1.example.com:7051",
            "eventURL": "grpcs://peer3.org1.example.com:7053"
        }
    ],
    "globalCert": "${GLOBAL_TLS_CERT}",
    "keyValStore": "${HOME}/.composer-credentials",
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}
EOF

SK_FILE=`ls /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/ | grep _sk`
PRIVATE_KEY=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/$SK_FILE
CERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if composer card list -n PeerAdmin@hlfv1 > /dev/null; then
    composer card delete -n PeerAdmin@hlfv1
fi
composer card create -p /tmp/.connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@hlfv1.card
composer card import --file /tmp/PeerAdmin@hlfv1.card 

rm -rf /tmp/.connection.json

echo "Hyperledger Composer PeerAdmin card has been imported"
composer card list

