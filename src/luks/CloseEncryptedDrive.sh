#!/bin/bash
# Purpose: Unmount and Close a Decrypted Hard Drive.
# Author: Leandro D. Huff
# Version: 1.1
# Date: May-28-2022

IRED="\e[1;31m"
IWHITE="\e[1;37m"
NO_COLOR="\e[0m"

echo -e

if [[ -z $1 ]];
then
  echo "Close and unmount an encrypted device."
  echo "Use: closeluksdrive media"
  echo "where:"
  echo "  media: is a mounted device at /media/*"
  exit 1
fi

sudo umount /media/$1
sudo cryptsetup luksClose $1
sudo rm -rf /media/$1

if [[ -d /media/$1/verify/. ]];
then
  printf "\n${IRED}Error:${NO_COLOR}\n\tDevice at ${IWHITE}/media/$1/${NO_COLOR} is opened or mounted.\n"
  printf "\t Check failures and try again.\n"
  exit 2
else
  printf "${IWHITE}\nFinished!${NO_COLOR}\n"
fi

exit 0
