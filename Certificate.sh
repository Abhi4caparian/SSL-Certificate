#file name Certificate.sh takes input 
#!/usr/bin/env bash
XREQ=$1
ROOTCA_KEY=$2
ALGO=$3
DAYS=$4
PEM_OUT=$5
NEW_CSR=$6
NEW_ALGO=$7
NEW_KEYOUT=$8
CSR_CNF=$9
NEW_CRTOUT=${10}
SERVER_DAYS=${11}
EXTFILE=${12}
echo =" in ldt.sh --- $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}"
echo =" in ldt.sh $XREQ $ROOTCA_KEY $ALGO $DAYS $PEM_OUT $NEW_CSR $NEW_ALGO $NEW_KEYOUT $CSR_CNF $NEW_CRTOUT $SERVER_DAYS $EXTFILE"
#--------------------------------------------------------------------------------------------
#sudo apt-get install -y apache2
#sudo apt-get install -y openssl
sudo a2enmod ssl

openssl genrsa -des3 -out $2 2048

echo ="Installation done"

openssl req -$1 -new -nodes -key $2 -$3 -days $4 -out $5

echo "[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=US
ST=RandomState
L=RandomCity
O=RandomOrganization
OU=RandomOrganizationUnit
emailAddress=hello@example.com
CN = localhost
" > $9

echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
" > ${12}

echo ="$9 and ${12} files are created "
# creates server.key
openssl req -new -$3 -nodes -out $6 -newkey $7 -keyout $8 -config <( cat $9 )
#openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config <( cat server.csr.cnf )
echo ="server.key created"

# creates server.crt
openssl $1 -req -in $6 -CA $5 -CAkey $2 -CAcreateserial -out ${10} -days ${11} -$3 -extfile ${12}
#openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext

echo ="server.crt created"

sudo cp ${10} /etc/ssl/certs/${10}
sudo cp $8 /etc/ssl/private/$8
echo ="done"
sudo service apache2 restart
