#!/bin/bash
usage(){
  echo "
Usage:
  -i,    input file
  -p,    password
  -n,    rounds of encryption/decryption, not to exceed 10
  -o,    output file
  -d,    decryption, default encryption
  -h,    display this help and exit
  example: ./testGetopts.sh -i fileA.txt -p password -n 3 -o fileB.txt
"
}
decryption="false"; declare -i number=1
while getopts "i:p:o:n:dh" arg; do
    case $arg in
      i)
         input="$OPTARG";;
      p)
         passwd="$OPTARG";;
      o)
         output="$OPTARG";;
      n)
         declare -i number="$OPTARG";;
      d)
         decryption="true";;
      h)
         usage; exit;;
      ?)
         echo "Invalid option or argument" >&2
	   usage; exit 1;;
    esac
done
if [ $number -gt 10 ] || [ $number -lt 1 ]; then
	echo "Invalid: The round is larger than 10 or smaller than 1."; exit 1
else
 echo "$input"
 echo "$passwd"
 echo "$number"
 echo "$output"
 echo "$decryption"
 if [ $decryption == "false" ]
 then
   if [ $number -eq 1 ]; then
       cat "$input" | base64 | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -e -pass pass:"$passwd" -nosalt -out "$output"
   else
       x=1
	 cat "$input" | base64 | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -e -pass pass:"$passwd" -nosalt -out temp_"$x".txt
	 while [ $x -lt $number ]; do
		 cat temp_"$x".txt | base64 | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -e -pass pass:"$passwd" -nosalt -out temp_"$(( $x + 1 ))".txt
		 x=$(( $x + 1 ))
	 done
	 mv temp_"$x".txt "$output"; rm temp_*.txt
   fi
 else
   if [ $number -eq 1 ]; then
       cat "$input" | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -d -pass pass:"$passwd" -nosalt | base64 -d > "$output"
   else
       x=1
	 cat "$input" | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -d -pass pass:"$passwd" -nosalt | base64 -d > temp_"$x".txt
	 while [ $x -lt $number ]; do
		 cat temp_"$x".txt | openssl enc -aes-256-cbc -md sha384 -a -pbkdf2 -d -pass pass:"$passwd" -nosalt | base64 -d > temp_"$(( $x + 1 ))".txt
             x=$(( $x + 1 ))
	 done
	 mv temp_"$x".txt "$output"; rm temp_*.txt
   fi
 fi
fi
