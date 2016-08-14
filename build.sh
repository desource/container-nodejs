#!/usr/bin/env sh
set -eux

BASE=$PWD
SRC=$PWD/src
OUT=$PWD/build
ROOTFS=$PWD/rootfs

mkdir -p $OUT $ROOTFS

curl -sL 'https://github.com/gliderlabs/docker-alpine/blob/rootfs/library-edge/versions/library-edge/rootfs.tar.gz?raw=true' | \
    tar -C $ROOTFS -zxf -

mv $ROOTFS/etc/localtime $ROOTFS/usr/share/zoneinfo
ln -s /usr/share/zoneinfo $ROOTFS/etc/localtime 

cat <<EOF > $OUT/etc/passwd
root:x:0:0:root:/:/dev/null
nobody:x:65534:65534:nogroup:/:/dev/null
EOF

cat <<EOF > $OUT/etc/group
root:x:0:
nogroup:x:65534:
EOF

cd $ROOTFS
tar -cf $OUT/rootfs.tar .

cat <<EOF > $OUT/Dockerfile
FROM scratch

ADD rootfs.tar /

RUN apk add --no-cache nodejs

ENV NODE_ENV=production

EOF
