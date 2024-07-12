# Certificates

This will create the certificates for the server and for the CA (based on [this blog post](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)):
	
	openssl genrsa -des3 -out myCA.key 2048
	openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem -subj "/C=PT/emailAddress=admin@ca.local/CN=ca.local"
	openssl genrsa -out totoro.key 2048
	openssl req -new -key totoro.key -out totoro.csr -subj "/CN=totoro/C=PT"
	openssl x509 -req -in totoro.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out totoro.pem -days 825 -sha256 -extfile totoro.ext

The certificate (`totoro.pem`) and key (`totoro.key`) can be used in nginx.

In order for this to work on the device, you need to send `myCA.pem` to the phone via AirDrop and install it as a valid certificate.

For it to work on the simulator, go to the "Settings" menu and untick the "Use Device HTTPS requirements".