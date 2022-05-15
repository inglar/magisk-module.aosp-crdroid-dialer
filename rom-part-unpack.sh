#!/bin/sh

if [ -z $1 ]; then
  echo "Specify ROM filepath as first argument"
  exit 1
fi

if [ -z $2 ]; then
  echo "Specify part name (system, product, vendor, ...) as second argument"
  exit 1
fi

if [ -z $3 ]; then
  echo "Specify output directory as thirt argument"
  exit 1
fi

ROM_FILEPATH=$1
PART=$2
OUTPUT_DIR=$3

jar xf ${ROM_FILEPATH} ${PART}.new.dat.br ${PART}.patch.dat ${PART}.transfer.list
brotli -d ${PART}.new.dat.br -o ${PART}.new.dat
/srv/sdat2img/sdat2img.py ${PART}.transfer.list ${PART}.new.dat ${PART}.new.img

mv ${PART}.new.img ${OUTPUT_DIR}

rm ${PART}.new.dat.br ${PART}.patch.dat ${PART}.transfer.list ${PART}.new.dat
