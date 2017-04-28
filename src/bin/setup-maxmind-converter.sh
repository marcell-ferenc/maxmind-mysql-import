#!/bin/bash

PWD=$(pwd)
MAXMIND_RELEASES_URL='https://github.com/maxmind/geoip2-csv-converter/releases/download'
MAXMIND_VERSION='v0.0.1'
MAXMIND_BASENAME='geoip2-csv-converter'
DEST_DIR="$HOME/tmp.$$.$RANDOM"
INSTL_DIR="/usr/local/bin"
MAXMIND_CONVERTER="$INSTL_DIR/$MAXMIND_BASENAME"

arch=$(uname -m)
os=$(uname)

case $arch in
  x86_64) arch=amd64 ;;
  *) echo 'Unsopperted architecture'
     exit ;;
esac

case $os in
  Linux|Darwin) ;;
  *) echo 'Unsupported OS'
     exit ;;
esac

case $BASH_VERSION in
  3*) echo "BASH 4 is required"
      # some variable expression is nut supported in BASH 3, e.g.: ${var,,}
      exit ;;
esac

err_code=$(type wget &> /dev/null; echo $?)
case $? in
  0) ;;
  *) echo 'Please install wget'
     exit ;;
esac

PACKAGE="${MAXMIND_BASENAME}-${MAXMIND_VERSION}-${os,,}-${arch}.tar.gz"

mkdir -p $DEST_DIR
wget -q -O - $MAXMIND_RELEASES_URL/$MAXMIND_VERSION/$PACKAGE > $DEST_DIR/$PACKAGE

case $? in
  0) ;;
  *) echo "Download of file <$MAXMIND_RELEASES_URL/$MAXMIND_VERSION/$PACKAGE> failed"
     exit ;;
esac

tar -xzf $DEST_DIR/$PACKAGE -C $DEST_DIR

if [ -d "$DEST_DIR/${MAXMIND_BASENAME}-${MAXMIND_VERSION}" ]; then

  if [ ! -d "$INSTL_DIR" ]; then
    mkdir -p "$INSTL_DIR"
  fi

  echo "Move executable to $INSTL_DIR"
  mv $DEST_DIR/${MAXMIND_BASENAME}-${MAXMIND_VERSION}/${MAXMIND_BASENAME} $MAXMIND_CONVERTER

  echo "Cleaning"
  rm -rf $DEST_DIR/${MAXMIND_BASENAME}-${MAXMIND_VERSION}
  rm -f $DEST_DIR/$PACKAGE
fi

if [ -f "$MAXMIND_CONVERTER" ]; then
  echo "MAXMIND ip converter successfully installed at location: $MAXMIND_CONVERTER"
else
  echo "MAXMIND ip converter failed to install"
fi

rm -rf $DEST_DIR