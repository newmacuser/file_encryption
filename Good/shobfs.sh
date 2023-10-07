#!/bin/bash
usage(){
  echo "
This script obfs a shell script.
Usage:
  -i,    input file (required)
  -n,    iterations [int], default 5
  -h,    display this help and exit
  example: shobfs.sh -i input.sh
"
}
declare -i n=5
while getopts "i:n:h" arg; do
    case "${arg}" in
      i)
         sh="$OPTARG";;
      n)
         declare -i n="$OPTARG";;
      *)
         echo "Invalid option or argument"
	   usage; exit 1;;
    esac
done
if [ -z "${sh}" ] ; then
    echo "
Error: Input file name is required."
    usage; exit 1
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
