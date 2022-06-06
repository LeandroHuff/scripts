#!/bin/bash
# Purpose: Decrypt and Mount a Encrypted Hard Drive.
# Author: Leandro D. Huff
# Version: 1.1
# Date: May-28-2022

IRED="\e[1;31m"
IWHITE="\e[1;37m"
NO_COLOR="\e[0m"

if [[ -z $1 || -z $2 ]];
then
  echo "Open and mount an encrypted drive by Luks."
  echo "Use: openluksdrive drive media"
  echo "where:"
  echo "   device: is any encrypted device at /dev/*"
  echo "    media: is any media name that will be added at /media/*"
  exit 1
fi

if [[ ! -d /dev/mapped/$2 ]]
then
  sudo cryptsetup luksOpen /dev/$1 $2
fi

if [[ ! -d /media/$2 ]]
then
  sudo mkdir /media/$2
fi

if [[ ! -d /media/$2/verify/. ]]
then
  sudo mount /dev/mapper/$2 /media/$2
fi

if [[ ! -d /media/$2/verify/. ]]
then
  printf "${IRED}Error:${NO_COLOR}\n\tDevice at ${IWHITE}/media/$2/${NO_COLOR} not opened.\n\tCheck failures and try again.\n"
  exit 2
fi

exit 0
