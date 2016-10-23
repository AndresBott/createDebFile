#!/bin/bash
#
# Usage: convertomp3 fileextention
#

# check if needed programs are installed
command -v mplayer >/dev/null 2>&1 || { echo >&2 "mplayer is required but it's not installed.  Aborting."; exit 1; }
command -v lame >/dev/null 2>&1 || { echo >&2 "lame is required but it's not installed.  Aborting."; exit 1; }


if [ $1="" ];then
  echo 'Please give a audio file extention as argument.'
  exit 1
fi

for i in *.$1
do
  if [ -f "$i" ]; then
  rm -f "$i.wav"
  mkfifo "$i.wav"
  mplayer \
   -quiet \
   -vo null \
   -vc dummy \
   -af volume=0,resample=44100:0:1 \
   -ao pcm:waveheader:file="$i.wav" "$i" &
  dest=`echo "$i"|sed -e "s/$1$/mp3/"`
  lame -V0 -h -b 192 --vbr-new "$i.wav" "$dest"
  rm -f "$i.wav"
fi
done 
