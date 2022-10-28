#!/bin/bash
usage(){
  echo "
Usage:
  -i,    input file
  -p,    password
  -n,    iterations [int 1-10], default 1
  -o,    output file
  -d,    decryption, default encryption
  -h,    display this help and exit
  example: ./encryption1.1.sh -i input.txt -p password -n 3 -o output.txt
"
}
decryption="false"; declare -i number=1
while getopts "i:p:n:odh" arg; do
    case "${arg}" in
      i)
         input="$OPTARG" 
	 echo "Your input file: $input";;
      p)
         passwd="$OPTARG"
	 echo "Password is: $passwd";;
      n)
         declare -i number="$OPTARG";;
      o)
         eval nextopt=\${$OPTIND}
         if [[ -n $nextopt && $nextopt != -* ]] ; then
            OPTIND=$((OPTIND + 1))
            output=$nextopt
         else
            output=""
         fi;;
      d)
         decryption="true";;
      h)
         usage; exit;;
      *)
         echo "Invalid option or argument"
	   usage; exit 1;;
    esac
done
if [ -z "${input}" ] || [ -z "${passwd}" ]; then
    echo "
Error: Input file and password are required."
    usage; exit 1
fi
if [ $number -gt 10 ] || [ $number -lt 1 ]; then
	echo "Invalid: The iteration number is larger than 10 or smaller than 1."; exit 1
else
 if [ -z "$output" ]; then
	 output="$passwd"-"$number".txt
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
