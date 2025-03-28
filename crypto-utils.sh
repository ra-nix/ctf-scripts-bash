#!/bin/bash

# macOS /bin/bash is ver 3 and won't handle associative arrays

help_menu() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -x, --hex"
    echo "      Convert hexadecimal values to ASCII."
    echo ""
    echo "  -b64, --base64"
    echo "      Convert Base64 values to ASCII."
    echo ""
    echo "  -bin, --binary"
    echo "      Convert binary values to ASCII."
    echo ""
    echo "  -rot, --ceasar"
    echo "       Decrypts rotation ciphers (i.e. shift the alphabet by 13 characters if no key is specified)." 
    echo "       You must provided an integer between 2 and 25 for the decryption to run."
    echo ""
    echo "  -at, --atbash"
    echo "      Decrypt atbash ciphers."
    echo ""
    echo "  -rf [k], --rail-fence [k]"
    echo "      Decrypt rail fence ciphers, where [k] is the key.(i.e. -rf 3, --rail-fence 3)"
    echo ""
    echo "  -s, --strings"
    echo "       Extract NCL flag using string searching. Requires a file."
    echo ""
    echo "  -bb, --binary-base64"
    echo "       Convert from binary, then Base64."
    echo ""
    echo "  -h, --help"
    echo "      Displays this help menu"
    exit 0
}

convert_hex() {
    converted=$(xxd -r -p <<< $1)
    echo -e "$converted\n"
}

convert_base64() {
    converted=$(base64 -d <<< $1)
    echo -e "$converted\n"
}

bin2chr() {
    echo $(printf \\$(echo "ibase=2; obase=8; $1" | bc))
}

convert_binary() {
    for i in $*; do
        bin2chr $i | tr -d '\n' 
    done
}

convert_bb() {
    echo "$(convert_binary $1 | base64 -d)"
}

convert_string() {
    echo "[!] Searching for strings in flag format."
    flag=$(strings -n 8 $1 | egrep -o "[A-Z]{4}-[A-Z]{4}-[0-9]{4}")
    if [[ -z $flag ]]; then
        echo "[!] No flag was found."
    else
        echo "Flag: $flag"
    fi
}

convert_rot() {
    read -p "Please specify how many rotations to use (values: 2-25,enter 13 if you're unsure): " n
    declare -A rot_map
    rot_map=(
        ["2"]="tr 'c-za-bC-ZA-B' 'a-zA-Z'"
        ["3"]="tr 'd-za-cD-ZA-C' 'a-zA-Z'"
        ["4"]="tr 'e-za-dE-ZA-D' 'a-zA-Z'"
        ["5"]="tr 'f-za-eF-ZA-E' 'a-zA-Z'"
        ["6"]="tr 'g-za-fG-ZA-F' 'a-zA-Z'"
        ["7"]="tr 'h-za-gH-ZA-G' 'a-zA-Z'"
        ["8"]="tr 'i-za-hI-ZA-H' 'a-zA-Z'"
        ["9"]="tr 'j-za-iJ-ZA-I' 'a-zA-Z'"
        ["10"]="tr 'k-za-jK-ZA-J' 'a-zA-Z'"
        ["11"]="tr 'l-za-kL-ZA-K' 'a-zA-Z'"
        ["12"]="tr 'm-za-lM-ZA-L' 'a-zA-Z'"
        ["13"]="tr 'n-za-mN-ZA-M' 'a-zA-Z'"
        ["14"]="tr 'o-za-nO-ZA-N' 'a-zA-Z'"
        ["15"]="tr 'p-za-oP-ZA-O' 'a-zA-Z'"
        ["16"]="tr 'q-za-pQ-ZA-P' 'a-zA-Z'"
        ["17"]="tr 'r-za-qR-ZA-Q' 'a-zA-Z'"
        ["18"]="tr 's-za-rS-ZA-R' 'a-zA-Z'"
        ["19"]="tr 't-za-sT-ZA-S' 'a-zA-Z'"
        ["20"]="tr 'u-za-tU-ZA-T' 'a-zA-Z'"
        ["21"]="tr 'v-za-uV-ZA-U' 'a-zA-Z'"
        ["22"]="tr 'w-za-vW-ZA-V' 'a-zA-Z'"
        ["23"]="tr 'x-za-wX-ZA-W' 'a-zA-Z'"
        ["24"]="tr 'y-za-xY-ZA-X' 'a-zA-Z'"
        ["25"]="tr 'z-za-yZ-ZA-Y' 'a-zA-Z'"
        )
    for i in $n; do
        if [[ -n $rot_map[$i] ]]; then
            decoded=$(echo "$1" | ${rot_map[$i]})
            echo -e "$decoded\n"
        fi
    done
}

convert_atbash() {
    decoded=$(echo $1 | tr 'zyxwvutsrqponmlkjihgfedcba' 'abcdefghijklmnopqrstuvwxyz')
    echo -e "$decoded\n"
}

case $1 in
    -h|--help|"") help_menu;;
    -bin|--binary) convert_binary $2;;
    -x|--hex) convert_hex $2;;
    -b64|--base64) convert_base64 $2;;
    -at | --atbash) convert_atbash "$2";;
    -bb|--binary-base64) convert_bb $2;;
    -rf|--rail-fence) convert_rf $2;;
    -rot|--ceasar) convert_rot $2;;
    -s|--strings) convert_string $2;;
    *)
        echo "[!] Invalid option: $1"
        echo "  Use -h or --help for information."
        exit 1
    ;;
esac
