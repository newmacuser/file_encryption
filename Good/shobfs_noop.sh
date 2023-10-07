#!/bin/bash
echo "
This script obfs a shell script.
Please enter the script name with path and extension (e.g., /mnt/c/script.sh)
"
read sh
if [ -z "${sh}" ] ; then
    echo "
Error: Input file name is empty."
    exit 1
fi
echo "Please enter iterations [int], default 5. Enter to use default setting."
read n
if [ -z "${n}" ] ; then
    declare -i n=5
fi

i=0; x=1
echo "bash <(echo '$(base64 $sh)' | base64 -d)" >> "$sh"_"$i".sh
while [ $i -lt $n ]; do
echo "bash <(echo '$(base64  "$sh"_"$i".sh)' | base64 -d)" >> "$sh"_"$x".sh
i=$(( $i + 1 ))
x=$(( $x + 1 ))
done
mv "$sh"_"$i".sh obfs."$sh".sh
rm "$sh"_*.sh
