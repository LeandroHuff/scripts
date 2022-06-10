#!/bin/bash

# Purpose: Encrypt, Decrypt, Mount and Umount a DEVICE.
# Author: Leandro D. Huff
# Version: 1.0
# Date: JUN-08-2022
#
# Copyright (c) <year> <copyright holders>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in ALL
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# WARNING! The following command will remove ALL data on the partition that you 
#          are encrypting. You WILL lose ALL your information! So make sure you
#          backup your data to an external source such as NAS or hard disk before 
#          typing any one of the following command. 

# Prepare some vars for color settings.
RED="\e[0;31m"
IRED="\e[1;91m"
IYELLOW="\e[1;93m"
IWHITE="\e[1;97m"
NO_COLOR="\e[0m"

# start variables to be used along the script.
SDXN=""
DEVICE=""
NEXT=$1
ERASE=$2
CREATE=0

# print a warning message on terminal.
printWarning()
{
   printf "${IYELLOW}WARNING! The following commands will remove ALL data on the partition that  you\n"
   printf "${IYELLOW}         are encrypting. You WILL lose ALL your information! So make  sure  you\n"
   printf "${IYELLOW}         have been backuped your data to an external source such as NAS or hard\n"
   printf "${IYELLOW}         disk before answer \"YES\" for the following question.${NO_COLOR}\n"
}

# print a help message on terminal.
printHelp()
{
   printf "\n"
   printf "Encryp, Decrypt, Mount and/or Umount a DEVICE by Luks.\n"
   printf "Writed by: Leandro D. Huff - leandrohuff@programmer.net\n\n"
   printWarning
   printf "\n"
   printf "  Syntaxe: Luks.sh <option> [-erase]\n\n"
   printf "    Where:\n\n"
   printf "   ${IWHITE}option${NO_COLOR}: Is any of the follow options...\n\n"
   printf "   Create: Make all steps to create an encrypted DEVICE.\n"
   printf "     Open: Open the encrypted file system.\n"
   printf "    Close: Close the encrypted file system.\n"
   printf "   AddKey: Add a new key password for the encrypted DEVICE.\n"
   printf "RemoveKey: Remove the key password from the encrypted DEVICE.\n\n"
   printf "    ${IWHITE}-erase${NO_COLOR}: Fill device with ${IWHITE}zeros (0)${NO_COLOR} to clean the device.\n"
   printf "            This option take a long time, have patience.\n"
}

# main function is a state machine to execute step-by-step every commands to 
# create, open, close, or change password to encrypt or an ecrypted device.
stateMachine()
{
   case $STATE in
   
   # first state to prepare the state machine to run.
   # print messages to the user got next state.
   "Start")
      if [[ -z $NEXT ]]; then
         printHelp
         exit 1
      fi
      STATE=$NEXT
   ;;
   
   # list the devices on host and go to the next state.
   "Create")
      let CREATE=1
      sudo fdisk -l
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}fdisk${NO_COLOR} command line returned an error.\n"
         STATE="Finish"
      else
         STATE="Read"
      fi
   ;;

   # read target devices to be encrypted and mounted to.
   "Read")
      read -e -p "Enter a device name at /dev/" SDXN
      read -e -p "Enter an output device name at /media/" DEVICE
      printWarning
      read -e -p "Are your sure? <YES|no>: " ANSWER
      if [[ "$ANSWER" != "YES" ]]; then
         exit 1
      fi
      STATE="Setup"
   ;;

   # prepare the device to be used for luks encrypt engine.
   "Setup")
      sudo cryptsetup luksFormat -y -v --type luks2 /dev/$SDXN
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksFormat${NO_COLOR} command line returned an error.\n"
         STATE="Finish"
      else
         STATE="Open"
      fi
   ;;

   # open a encrypted device and as for a password.
   "Open")
      if [[ $SDXN == "" ]]; then
         read -e -p "Enter a device name at /dev/" SDXN
      fi
      if [[ $DEVICE == "" ]]; then
         read -e -p "Enter an output device name at /media/" DEVICE
      fi
      sudo cryptsetup luksOpen /dev/$SDXN $DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksOpen${NO_COLOR} command line returned an error.\n"
         STATE="Finish"
      else
         STATE="Info"
      fi
   ;;

   # show some information about the encrypted target device.
   "Info")
      # ls -l /dev/mapper/$DEVICE
      # or 
      # df -H /dev/mapper/$DEVICE
      sudo df -H /dev/mapper/$DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}df${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         STATE="Status"
      fi
   ;;

   # show some iformation about the status of encrypted target device.
   "Status")
      sudo cryptsetup -v status $DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup status${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         STATE="Dump"
      fi
   ;;

   # show deeply information about the encrypted target device.
   "Dump")
      sudo cryptsetup luksDump /dev/$SDXN
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksDump${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         if [[ $CREATE -eq 1 ]]; then
            if [[ "$ERASE" == "-erase" ]]; then
               STATE="Fill"
            else
               STATE="Format"
            fi
         else
            STATE="Mount"
         fi
      fi
   ;;

   # optionaly fill the target device with zeros(0) to remove last data inside.
   # this procedure can take a long time to end because of device size.
   "Fill")
      sudo dd if=/dev/zero of=/dev/mapper/$DEVICE bs=128M status=progress
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}dd${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         STATE="Format"
      fi
   ;;

   # format the device for a ext4 linux partition.
   "Format")
      sudo mkfs.ext4 /dev/mapper/$DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}mkfs.ext4${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         STATE="Mount"
      fi
   ;;

   # mount a device into /media directory to be accessed by the system.
   "Mount")
      if [[ $DEVICE == "" ]]; then
         read -e -p "Enter an output device name at /media/" DEVICE  # read the device name
      fi
      if [[ ! -d /media/$DEVICE ]]; then  # if directory already exist, create one.
         sudo mkdir /media/$DEVICE
         if [[ $? -ne 0 ]]; then # check any error
            printf "${IRED}Error:${NO_COLOR}\t${IWHITE}mkdir${NO_COLOR} command line returned an error.\n"
            STATE="Close"
            continue
         fi
      fi
      sudo mount /dev/mapper/$DEVICE /media/$DEVICE   # mount the device
      if [[ $? -ne 0 ]]; then # check any error
         sudo rm -rf /media/$DEVICE
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}mount${NO_COLOR} command line returned an error.\n"
         STATE="Close"
      else
         sudo df -H /media/$DEVICE  # check if device exist and is all fine with it.
         if [[ $? -ne 0 ]]; then #check results
            printf "${IRED}Error:${NO_COLOR}\t${IWHITE}df${NO_COLOR} command line returned an error.\n"
            STATE="Umount" #if error go to unmount state.
         else
            sudo chown -R $USER:$GROUP /media/$DEVICE # change user and groups of device
            if [[ ! -d /media/$DEVICE/verify ]]; then # check if exist and is accessible.
               mkdir /media/$DEVICE/verify   # create a directory there
               touch /media/$DEVICE/verify/checker.txt   # create a file there
               echo "Script for Luks encrypt was finished successfuly." > /media/$DEVICE/verify/checker.txt # write a message for double check.
            fi
            if [[ ! -f /media/$DEVICE/verify/checker.txt ]]; then # test if happened any error.
               printf "${IRED}Error:${NO_COLOR}\tFailure to access the device at ${IWHITE}/media/$DEVICE${NO_COLOR} has an error.\n"
            fi
            STATE="Finish" # all fine, go ahead.
         fi
      fi
   ;;

   # unmount a device that was opened by a previous mount command and go next to close it.
   "Close")
      if [[ $DEVICE == "" ]]; then
         read -e -p "Enter an output device name at /media/" DEVICE
      fi
      sudo umount /media/$DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}umount${NO_COLOR} command line returned an error.\n"
      fi
      if [[ -d /media/$DEVICE ]]; then
         sudo rm -rf /media/$DEVICE
      fi
      STATE="luksClose"
   ;;

   # close an encrypted device to be protected and unavailable for read.
   "luksClose")
      sudo cryptsetup luksClose $DEVICE
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksClose${NO_COLOR} command line returned an error.\n"
      fi
      STATE="Finish"
   ;;

   # Add a new password, luks allow up to 8 password for the same device.
   "AddKey")
      if [[ $SDXN == "" ]]; then
         read -e -p "Enter a device name at /dev/" SDXN
      fi
      sudo cryptsetup luksAddKey /dev/$SDXN
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksAddKey${NO_COLOR} command line returned an error.\n"
      fi
      STATE="Finish"
   ;;

   # Remove a password from the device, almost one password have to be registered.
   "RemoveKey")
      if [[ $SDXN == "" ]]; then
         read -e -p "Enter a device name at /dev/" SDXN
      fi
      sudo cryptsetup luksRemoveKey /dev/$SDXN
      if [[ $? -ne 0 ]]; then
         printf "${IRED}Error:${NO_COLOR}\t${IWHITE}cryptsetup luksRemoveKey${NO_COLOR} command line returned an error.\n"
      fi
      STATE="Finish"
   ;;

   # end state, just to wait for finish by the main statement.
   "Finish")
   ;;

   # unknown state, control state machine to avoid unavailable or unrecgnized states.
   *)
      printf "${IRED}Error:${NO_COLOR}\t<${IWHITE}option${NO_COLOR}> at command line is not valid.\n"
      STATE="Finish"
   ;;

   esac
}

# Main script entry point, from here the script start running the commands.
STATE="Start"
COUNTER=0

# Looping to execute the state machine step-by-step until reach the last command.
while [ "$STATE" != "Finish" ]; do
   let COUNTER=$COUNTER+1  # increase a counter to control the iteration and avoid freeze or infinite loopings.
   stateMachine   # call function to run the state machine
   # if reached the limit of iteration, get out of here now!
   if [[ $COUNTER -ge 12 ]]; then
      break
   fi
done

# Check the reason to end the loop iteration and send a message to the terminal.
if [ $COUNTER -eq 0 ]; then
   printf "\n${IRED}Error:${NO_COLOR}\t${IWHITE}parameter${NO_COLOR} invalid.\n"
   exit 1
fi

# Check the reason to end the loop iteration and send a message to the terminal.
if [[ $COUNTER -ge 12 ]]; then
   printf "\n${IRED}Error:${NO_COLOR}\t${IWHITE}looping${NO_COLOR} iteration exceed the limit.\n"
   exit 1
fi

# Tell to the user that the proccess was finished, may be he/she is almost sleeping wainting for the end.
echo "FINISHED!"
exit 0
