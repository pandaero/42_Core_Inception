#!/bin/bash

SERVER_NAME=pandalaf.42.fr
SERVER_KEY=$SERVER_NAME.key
SERVER_CSR=$SERVER_NAME.csr
SERVER_CRT=$SERVER_NAME.crt
SSL_CONF=$SERVER_NAME.cnf

echo "Generating private key"
openssl genrsa -out $SERVER_KEY 4096
if [ $? -ne 0 ]; then
	echo "ERROR: could not generate $SERVER_KEY"
	exit 1
fi

echo "Generating Certificate Signing Request"
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -config $SSL_CONF
if [ $? -ne 0 ]; then
	echo "ERROR: could not generate $SERVER_CSR"
	exit 1
fi

echo "Generating self-signed certificate"
openssl x509 -req -days 365 -in $SERVER_CSR -signkey $SERVER_KEY -out $SERVER_CRT
if [ $? -ne 0 ]; then
	echo "ERROR: could not generate certificate $SERVER_CRT"
	exit 1
fi
