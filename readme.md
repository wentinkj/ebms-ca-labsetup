based on and modified from https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

simple setup which is not to be used for production, just an easy setup for a test/lab environment

* envsettings a sourced file containing config parameters
* create-ca.sh shell script to setup a root and intermediate CA
* create-server-cert.sh shell script to create a server certificate based on the intermediate CA, also exports it as p12

create-server-cert.sh <dnsname> <serial>
