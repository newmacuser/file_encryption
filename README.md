# file_encryption

This is a shell script used to encrypt or decrypt files on linux and macos.

## Prerequisite
openssl and 7zip

## Usage:
-  -i,    input file
-  -p,    password
-  -n,    iterations [int 1-10], default 1
-  -o,    output file
-  -d,    decryption, default encryption
-  -h,    display this help and exit
-  example: ./enc7z.sh -i input.txt -p password -n 5 -o output.txt
  
