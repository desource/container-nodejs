#!/usr/bin/env bash
#
# Download and build nodejs container
set -euo pipefail

src=${PWD}/src
out=${PWD}/out
rootfs=${PWD}/rootfs

_download() {
  mkdir -p ${rootfs}

  curl -sL 'https://github.com/gliderlabs/docker-alpine/blob/rootfs/library-edge/versions/library-edge/rootfs.tar.gz?raw=true' | \
      tar -C ${rootfs} -zxf -
}

_build() {
  mv ${rootfs}/etc/localtime ${rootfs}/usr/share/zoneinfo
  ln -s /usr/share/zoneinfo ${rootfs}/etc/localtime
  
  cat <<EOF > ${rootfs}/etc/passwd
root:x:0:0:root:/:/dev/null
nobody:x:65534:65534:nogroup:/:/dev/null
EOF

  cat <<EOF > ${rootfs}/etc/group
root:x:0:
nogroup:x:65534:
EOF

  tar -cf ${out}/rootfs.tar -C ${rootfs} .
}

# _dockerfile "version"
_dockerfile() {
  cat <<EOF > ${out}/version
${1}
EOF
  
  cat <<EOF > ${out}/Dockerfile
FROM scratch

ADD rootfs.tar /

ENV NODE_ENV=production

RUN apk add --no-cache nodejs

EOF
}

_download
_build
_dockerfile next
