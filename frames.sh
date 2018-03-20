#!/bin/sh
rm -rf frame
rm -rf out
mkdir frame
mkdir out/frame -p
ffmpeg -i test.mp4 -r 5 'frame/f%03d.png'
find frame -iname "*.png" -exec convert -scale 256x192 -monochrome -colors 2 {} out/{} \;
mv out/frame/* out/
rm -r out/frame/
