#!/bin/bash

BASEDIR='/usr/local/share/containers/mt-twi/data_world/world/mapserver.tiles/'

read -r -p 'Min x: ' minx
read -r -p 'Min z: ' minz
read -r -p 'Max x: ' maxx
read -r -p 'Max z: ' maxz

printf 'Exporting map from %s to %s\n' "$minx,$minz" "$maxx,$maxz"

map_minx=$((minx / 32))
map_minz=$((minz / 32))
map_maxx=$(((maxx + 16) / 32))
map_maxz=$(((maxz + 16) / 32))

printf 'Map will be extracted from %s to %s\n' "$map_minx,$map_minz" "$map_maxx,$map_maxz"

IMG_TEMPFILE=$(mktemp)
trap 'rm -f "$IMG_TEMPFILE"' EXIT

i=0
for z in $(seq "$map_maxz" -1 "$map_minz"); do
    ((z=z*-1))
    for x in $(seq "$map_minx" "$map_maxx"); do
        THIS="${BASEDIR}0/12/$x/$z.png"
        if [ -f "$THIS" ]; then
            echo "$THIS" >> "$IMG_TEMPFILE"
        else
            echo "xc:white" >> "$IMG_TEMPFILE"
        fi
        ((i=i+1))
    done
done

num_column=$((map_maxx - map_minx + 1))
num_row=$((map_maxz - map_minz + 1))

epoch=$(date +%s)
FILENAME="map_${epoch}_${minx}_${minz}_${maxx}_${maxz}.png"

# shellcheck disable=SC2046
montage -geometry +0+0 "@$IMG_TEMPFILE" -tile "${num_column}x${num_row}" "$FILENAME"