#!/bin/bash
for filename in ./textures/*.png; do
    ffmpeg -vcodec png -i $filename -vcodec rawvideo -f rawvideo -pix_fmt rgb565 $filename.raw
done
