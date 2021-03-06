#!/bin/bash

#settings
crf=22
maxwidth=1920
maxheight=1080
encoderpreset=medium
denoise=true
denoisepreset=light
niceness=8 #priority from -20 (highest) to 19 (lowest)

if [ "$1" == "-u" ] || [ "$1" == "--update" ]; then
	abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
	wget https://raw.githubusercontent.com/bagbag/easierhandbrakecli/master/handbrake.sh -O "$abspath"
	echo "hopefully updated!"
	exit
fi

if [ "$1" == "-h" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "" ]; then
  echo "Usage: ./`basename $0` inputfile outputfile [starttime in seconds] [duration in seconds]"
  echo "	or -u|--update to download latest version from github"
  exit 0
fi

if ! [ -r "$1" ]; then
    echo "Input file does not exist or is not readable"
	exit 1
fi

if [ "$2" == "" ]; then
	echo "No output file given"
	exit 1
fi

if [ -e "$2" ]; then
    echo "Output file exists, overwrite? (y/n)"
	read overwrite
	
	if [ $overwrite != "y" ]; then
		exit 1
	fi
fi

parameters="-i '$1' -o '$2' -X $maxwidth -Y $maxheight -f mp4 -O -e x264 -q $crf --vfr -a 1,2,3,4,5,6,7,8,9 -B 256 -E av_aac --audio-copy-mask aac --audio-fallback av_aac -s 1,2,3,4,5,6,7,8,9 --encoder-preset=$encoderpreset --encoder-tune=film"

if [ $denoise == true ]; then
    parameters+=" --denoise=$denoisepreset"
fi

if [ "$3" != "" ]; then
    parameters+=" --start-at duration:$3"
fi

if [ "$4" != "" ]; then
    parameters+=" --stop-at duration:$4"
fi

eval "time nice -n $niceness HandBrakeCLI $parameters"
