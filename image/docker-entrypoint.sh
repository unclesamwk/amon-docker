#!/bin/sh

##
## Verify ENV arguments
##

if ! [ "$MONGO_URI" ]; then
  MONGO_URI="mongodb://localhost:27017"
fi

if ! [ "$AMON_HOSTNAME" ]; then
  AMON_HOSTNAME="localhost"
fi

if ! [ "$AMON_PROTO" ] || ([ "$AMON_PROTO" != "http" ] && [ "$AMON_PROTO" != "https" ]); then
  AMON_PROTO="http"
fi

if ! [ "$SMTP_HOST" ] ; then
  SMTP_HOST="127.0.0.1"
fi

if ! [ "$SMTP_PORT" ] ; then
  SMTP_PORT="25"
fi

if ! [ "$SMTP_USE_TLS" ] ; then
  SMTP_USE_TLS="false"
fi

if ! [ "$SMTP_USERNAME" ] ; then
  SMTP_USERNAME=root
fi

if ! [ "$SMTP_PASSWORD" ] ; then
  SMTP_PASSWORD=root
fi

if ! [ "$SMTP_SENT_FROM" ] ; then
  SMTP_SENT_FROM=alerts@amon.cx
fi

# Write config
cat > /etc/opt/amon/amon.yml << EOF
host: $AMON_PROTO://$AMON_HOSTNAME
mongo_uri: $MONGO_URI
smtp:
  host: ${SMTP_HOST}
  port: ${SMTP_PORT}
  use_tls: ${SMTP_USE_TLS}
  username: ${SMTP_USERNAME}
  password: ${SMTP_PASSWORD}
  sent_from: ${SMTP_SENT_FROM}
EOF

# Start nginx for static files
mkdir -p /run/nginx
nginx

# Init database
cd /opt/amon
python3 manage.py migrate
python3 manage.py installtasks

# Execute docker CMD
exec "$@"
