#!/bin/sh

DAEMON_DIR="/usr/local/etc/daemon/"
DAEMON_NAME="fetchtitled"
DAEMON_PATH=$DAEMON_DIR/$DAEMON_NAME

mkdir -p $DAEMON_PATH
touch $DAEMON_PATH/run
chmod 755 $DAEMON_PATH/run
cat <<'EOF' > $DAEMON_PATH/run
#!/bin/sh

exec setuidgid travail envdir ./env /home/public/SayCheese/current/bin/daemon/fetchtitled.pl -d --max_workers 0 2>&1
EOF

# for env
mkdir $DAEMON_PATH/env
cat <<'EOF' > $DAEMON_PATH/env/PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
EOF
cat <<'EOF' > $DAEMON_PATH/env/SAYCHEESE_CONFIG_LOCAL_SUFFIX
service
EOF

# for multilog
mkdir $DAEMON_PATH/log
mkdir $DAEMON_PATH/log/main
touch $DAEMON_PATH/log/run
chmod 755 $DAEMON_PATH/log/run
chown travail:travail $DAEMON_PATH/log/main
cat <<'EOF' > $DAEMON_PATH/log/run
#!/bin/sh
exec setuidgid travail multilog t s100000000 n10 ./main
EOF

exit
