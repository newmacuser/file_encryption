#!/bin/bash
echo "
This script obfs a shell script.
Please enter the script name with path and extension (e.g., /mnt/c/script.sh)
"
read sh
if [ -z "${sh}" ] ; then
    echo "
Error: Input file name is empty."
    exit 0
fi
echo "Please enter iterations [int], default 1. Enter to use default setting."
read n
if [ -z "${n}" ] ; then
    declare -i n=1
fi

i=0; x=1
echo "bash <(echo '$(base64 ${sh})' | base64 -d)" >> "$sh"_"$i".sh
while [ $i -lt $n ]; do
echo "bash <(echo '$(base64  "$sh"_"$i".sh)' | base64 -d)" >> "$sh"_"$x".sh
i=$(( $i + 1 ))
x=$(( $x + 1 ))
done
mv "$sh"_"$i".sh encoded."$sh".sh
rm "$sh"_*.sh

if [ -z "$(command -v bashfuscator)" ]; then
   echo "your output file is encoded."$sh".sh"
   exit 0
else
   bashfuscator -f encoded."$sh".sh --choose-mutators token/special_char_only -o obfs."$sh".sc.sh && rm encoded."$sh".sh && bashfuscator -f obfs."$sh".sc.sh --choose-mutators compress/bzip2 -o obfs."$sh".sh && rm obfs."$sh".sc.sh && echo "
Your output file is obfs."$sh".sh
"
fi
