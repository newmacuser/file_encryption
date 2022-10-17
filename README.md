# file_encryption

This is a shell script used to encrypt or decrypt files on linux.

Usage:

  -i,    input file
  
  -p,    password
  
  -n,    rounds of encryption/decryption, not to exceed 10
  
  -o,    output file
  
  -d,    decryption, default encryption
  
  -h,    display this help and exit
  
  example: ./testGetopts.sh -i fileA.txt -p password -n 3 -o fileB.txt
  
