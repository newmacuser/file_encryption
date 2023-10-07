#!/bin/bash
  echo "
This script requires 7zip and openssl.
Please enter input file name (e.g., /mnt/c/important.txt)"
read input
if [ -z "${input}" ] ; then
    echo "
Error: Input file name is empty."
    exit 1
fi
decryption="false"
read -e -p "Default operation is encrytion. Do you want to decrpt a file? [y/N]" YN
[[ $YN == "y" || $YN == "Y" ]] && decryption="true"
echo "Please provide a password. Press 'Enter' to use default setting."
read passwd
if [ -z "${passwd}" ] ; then
    passwd="MDAxMA=="
fi
echo "Please indicate iterations [int 1-10]; default 2. Press 'Enter' to use default setting."
read number
if [ -z "${number}" ] ; then
    declare -i number=2
fi
echo "Please give an output file name. Press 'Enter' to skip."
read output

if [ $number -gt 10 ] || [ $number -lt 1 ]; then
	echo "Invalid: The iteration number is larger than 10 or smaller than 1."; exit 1
else
 if [ -z "$output" ]; then
	 output=$(echo "$passwd"\="$number""$RANDOM" | base64)
	 echo "Iteration: $number"
	 echo "Output file: $output"
 	 echo "Decryption: $decryption"
 else
	 echo "Iteration: $number"
	 echo "Output file: $output"
 	 echo "Decryption: $decryption"
 fi
 if [ $decryption == "false" ]
 then
   if [ $number -eq 1 ]; then
       cat "$input" | openssl enc -aes-256-cbc -md sha384 -a -e -pass pass:"$passwd" -nosalt -out "$output"
       7z a -t7z -r "$input"_"$output".7z "$output" -mx9 -m0=LZMA2:d=29:fb=256 -ms=200m -mmt2 && rm "$output"
   else
       x=1
	 cat "$input" | openssl enc -aes-256-cbc -md sha384 -a -e -pass pass:"$passwd" -nosalt -out temp_"$x".txt
	 while [ $x -lt $number ]; do
		 cat temp_"$x".txt | openssl enc -aes-256-cbc -md sha384 -a -e -pass pass:"$passwd""$x" -nosalt -out temp_"$(( $x + 1 ))".txt
		 x=$(( $x + 1 ))
	 done
	 mv temp_"$x".txt "$output"; rm temp_*.txt
	 7z a -t7z -r "$input"_"$output".7z "$output" -mx9 -m0=LZMA2:d=29:fb=256 -ms=200m -mmt2 && rm "$output"
   fi
 else
   ext=$(sed 's/.*\.\(.*\)_.*/\1/' <<< "$input")
   iname=$(sed 's/.*_\(.*\)\..*/\1/' <<< "$input")
   oname="${input%%.*}"
   if [ $number -eq 1 ]; then
       7z x "$input"
       cat "$iname" | openssl enc -aes-256-cbc -md sha384 -a -d -pass pass:"$passwd" -nosalt > "$oname".de."$ext" && rm "$iname"
   else
       x=1; y=$(( $number - $x ))
     7z x "$input"
	 cat "$iname" | openssl enc -aes-256-cbc -md sha384 -a -d -pass pass:"$passwd""$y" -nosalt > temp_"$x".txt && rm "$iname"
	 while [ $x -lt $(( $number - 1 )) ]; do
	     y=$(( $y - 1 ))
		 cat temp_"$x".txt | openssl enc -aes-256-cbc -md sha384 -a -d -pass pass:"$passwd""$y" -nosalt > temp_"$(( $x + 1 ))".txt
             x=$(( $x + 1 ))
	 done
	 cat temp_"$x".txt | openssl enc -aes-256-cbc -md sha384 -a -d -pass pass:"$passwd" -nosalt > "$oname".de."$ext" && rm temp_*.txt
   fi
 fi
fi
