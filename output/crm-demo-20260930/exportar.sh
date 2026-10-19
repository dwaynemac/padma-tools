#!/bin/sh
set -eu
if [ "$#" -ne 2 ]; then
  echo 'Uso: sh exportar.sh captura-real.mov padma-crm-demo.mp4' >&2
  exit 2
fi
command -v ffmpeg >/dev/null
command -v ffprobe >/dev/null
# Convierte una captura real sin sobrescribir archivos ni simular interacciones.
ffmpeg -nostdin -n -i "$1" -map 0:v:0 -map '0:a?' \
  -vf 'scale=trunc(iw/2)*2:trunc(ih/2)*2' \
  -c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart "$2"
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height,pix_fmt -of json "$2"
ffmpeg -nostdin -v error -i "$2" -f null -
