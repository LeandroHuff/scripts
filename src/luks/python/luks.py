#!/usr/bin/python3

################################################################################
#
import os
import sys

################################################################################
#
Option  = ''

SUCCESS = 0
FAILURE = 1

# STYLE #
NORMAL    = 0
BOLD      = 1
ITALIC    = 3
UNDERLINE = 4

# HIGHLIGHT #
HIGH = 60

# COLOR #
BLACK   = 0
RED     = 1
GREEN   = 2
YELLOW  = 3
BLUE    = 4
MAGENTA = 5
CYAN    = 6
GRAY    = 7

# FOREGROUND #
FG = 30

# BACKGROUND #
BG = 40

################################################################################
#
luksFunction = {
   0 : 'Create',
   1 : 'Open',
   2 : 'Close',
   3 : 'AddKey',
   4 : 'RemoveKey'
}

luksOption = {
   'Create'    : 0,
   'Open'      : 1,
   'Close'     : 2,
   'AddKey'    : 3,
   'RemoveKey' : 4
}

################################################################################
# @brief       Function to set the text color for style, foreground and background.
# @param st    Set the style for the text, can be 0, 1, 3, 4 for normal, bold, italic and underlined respectively.
# @param fg    Set foreground text color that will be added to 30.
# @param bg    Set background text color that will be added to 40.
# @return      A formated string text to be used on print function.
def colorStFgBg(st, fg, bg) -> str:
    return "\x1b[{};{};{}m".format(st,(30+fg),(40+bg))

################################################################################
# @brief       Function to set the text color for style, foreground.
# @param st    Set the style for the text, can be 0, 1, 3, 4 for normal, bold, italic and underlined respectively.
# @param fg    Set foreground text color that will be added to 30.
# @return      A formated string text to be used on print function.
def colorStFg(st, fg) -> str:
    return "\x1b[{};{}m".format(st,(30+fg))

################################################################################
# @brief       Function to reset the text color.
# @return      A formated string text to be used on reset text colors.
def colorReset() -> str:
    return '\x1b[0m'

################################################################################
# @brief Print a warning message on terminal.
# @param none
# @return none
def printWarning() -> None:
   print( colorStFgBg(NORMAL,BLACK,HIGH+RED) + ' WARNING! The following commands will remove ALL data on the partition that  you ' + colorReset() )
   print( colorStFgBg(NORMAL,BLACK,HIGH+RED) + '          are encrypting. You WILL lose ALL your information! So make  sure  you ' + colorReset() )
   print( colorStFgBg(NORMAL,BLACK,HIGH+RED) + '          have been backuped your data to an external source such as NAS or hard ' + colorReset() )
   print( colorStFgBg(NORMAL,BLACK,HIGH+RED) + '          disk before answer "YES" for the following question.                   ' + colorReset() )

################################################################################
# @brief Function to print a help message to user at command line for welcome and instructions about the sintaxe.
# @param none
# @return none
def printHelp() -> None:

   print ()
   print ( 'Python script to Encryp, Decrypt, Mount or Umount a DEVICE using Luks encryption engine.' )
   print ( 'Writed by: Leandro D. Huff - leandrohuff@programmer.net' )
   print ()
   print ( '  Syntaxe: luks.py <option>' )
   print ()
   print ( '    Where:' )
   print ()
   print ( "   {}option{}: Is one of the following parameters...".format( colorStFg(BOLD,HIGH+GRAY), colorReset() ) )
   print ()
   print ( ' -n, --create   : Create a new encrypted DEVICE.' )
   print ( ' -o, --open     : Open an encrypted device.' )
   print ( ' -c, --close    : Close an encrypted device.' )
   print ( '-ak, --addkey   : Add a new key password to an encrypted DEVICE.' )
   print ( '-rk, --removekey: Remove a key password from an encrypted DEVICE.' )
   print ()
   print ( 'Obs.: The script will make some question to set the device\'s name and confirm the execution.' )

################################################################################
# @brief Print a message error for any command line.
# @param msg String message to be highligthed, allways a command line name.
# @return none
def printError( msg ) -> None:
   print( '{}Error:{}\tCommand {}{}{} returned an error.\n'.format(colorStFg(BOLD, HIGH+RED),colorReset(),colorStFg(BOLD, HIGH+GRAY),msg,colorReset()) )

################################################################################
# @brief  
# @param  
# @return 
def Create() -> None:

   printWarning()
   print()
   Sdxn = input('Enter a device name at /dev/')
   print()
   Device = input('Enter an output device name at /media/')
   # Luks Format
   drive = os.path.join('/dev', Sdxn)
   if os.system( 'sudo cryptsetup luksFormat -y -v --type luks2 ' + drive ) != SUCCESS:
      printError("cryptsetup luksFormat")
      return
   # Luks Open
   if os.system( 'sudo cryptsetup luksOpen ' + drive + ' ' + Device ) != SUCCESS:
      printError('cryptsetup luksOpen')
      return
   # df -H
   mapper = os.path.join('/dev/mapper', Device)
   if os.system( 'sudo df -H ' + mapper ) != SUCCESS:
      printError('df -H')
   # Status
   if os.system( 'sudo cryptsetup status -v ' + Device ) != SUCCESS:
      printError('cryptsetup status')
   # Format device by mkfs.ext4
   if os.system( 'sudo mkfs.ext4 ' + mapper ) != SUCCESS:
      printError('mkfs.ext4')
   # Mount device
   media = os.path.join('/media', Device)
   if os.path.isdir( media ) != True:
      os.mkdir( media )
   if os.system( 'sudo mount ' + mapper + ' ' + media ) != SUCCESS:
      printError('mount')
   if os.system( 'sudo df -H ' + media ) != SUCCESS:
      printError('df -H')
   if os.system( 'sudo chown -R $USER:$GROUP ' + media ) != SUCCESS:
      printError('chown -R')
   filepath = '/media/' + Device + '/checker.txt'
   if os.path.isfile( filepath ) == False:
      fd = open(filepath, mode='w')
      fd.write( 'Script for Luks encrypt was finished successfuly.' )
      fd.close()
   if os.path.isfile( filepath ) == True:
      fd = open(filepath, mode='r')
      line = fd.read()
      print(line)
      fd.close()

def Open() -> None:

   # FDISK
   os.system( 'sudo fdisk -l' )
   print()
   Sdxn = input('Enter a device name at /dev/')
   drive = os.path.join('/dev', Sdxn)
   Device = input('Enter an output device name at /media/')
   os.system( 'sudo cryptsetup luksOpen ' + drive + ' ' + Device )
   # df -H
   mapper = os.path.join('/dev/mapper', Device)
   if os.system( 'sudo df -H ' + mapper ) != SUCCESS:
      printError('df -H')
   # Status
   if os.system( 'sudo cryptsetup status -v ' + Device ) != SUCCESS:
      printError('cryptsetup status')
   # Mount device
   media = os.path.join('/media', Device)
   if os.path.isdir( media ) != True:
      os.mkdir( media )
   if os.system( 'sudo mount ' + mapper + ' ' + media ) != SUCCESS:
      printError('mount')
   if os.system( 'sudo df -H ' + media ) != SUCCESS:
      printError('modf -H')
   if os.system( 'sudo chown -R $USER:$GROUP ' + media ) != SUCCESS:
      printError('chown -R')
   filepath = '/media/' + Device + '/checker.txt'
   if os.path.isfile( filepath ) == False:
      fd = open(filepath, mode='w')
      fd.write( 'Python script for Luks encrypt was finished successfuly.' )
      fd.close()
   if os.path.isfile( filepath ) == True:
      fd = open(filepath, mode='r')
      line = fd.read()
      print(line)
      fd.close()

##
# @brief Function to close an encrypted device.
# @param None  
# @return <0|1> (0) SUCCESS and (1) FAILURE
def Close() -> None:

   print()
   Device = input('Enter an output device name at /media/')
   media = os.path.join('/media', Device)
   if os.system( 'sudo umount ' + media) != SUCCESS:
      printError('umount')
   if os.path.isdir( media ) == True:
      os.rmdir( media )
   if os.system( 'sudo cryptsetup luksClose ' + Device) != SUCCESS:
      printError('cryptsetup luksClose')
   else:
      print('Luks device closed successfuly.')

##
# @brief Function to add a key password to an encrypted device.
# @param None  
# @return <0|1> (0) SUCCESS and (1) FAILURE
def AddKey() -> None:

   # FDISK
   os.system( 'sudo fdisk -l' )
   print()
   Sdxn = input('Enter an output device name at /dev/')
   drive = os.path.join('/dev', Sdxn)
   if os.system( 'sudo cryptsetup luksAddKey ' + drive ) != SUCCESS:
      printError('cryptsetup luksAddKey')
   else:
      print('Key password added successfuly.')

##
# @brief Function to remove a key password to an encrypted device.
# @param None  
# @return <0|1> (0) SUCCESS and (1) FAILURE
def Removekey() -> None:

   # FDISK
   os.system( 'sudo fdisk -l' )
   print()
   Sdxn = input('Enter an output device name at /dev/')
   drive = os.path.join('/dev',Sdxn)
   if os.system( 'sudo cryptsetup luksRemoveKey ' + drive ) != SUCCESS:
      printError('cryptsetup luksRemoveKey')
   else:
      print('Key password removed successfuly.')

##
# @brief Main function called by entry point function.
# @param args Command line arguments are passed by args.
# @return 0 For success, otherwise an error code.
def main(args) -> int:

   argc = len(args)

   if argc > 1:
      Option = str( args[1] )
   else:
      printHelp()
      return FAILURE

   if Option == '--create' or Option == '-n':
      Create()
   elif Option == '--open' or Option == '-o':
      Open()
   elif Option == '--close' or Option == '-c':
      Close()
   elif Option == '--addkey' or Option == '-ak':
      AddKey()
   elif Option == '--removekey' or Option == '-rk':
      Removekey()
   else:
      printHelp()
      return FAILURE
     
   return SUCCESS

##
# @brief Main entry point, the python program start here, from this point the main() function is called.
# @param sys.argv[] All command line parameters are passed to program by sys.argv[].
# @return 0 For success, otherwise and error code.
if __name__ == "__main__":

   retFromMain = main(sys.argv)
   exit( retFromMain )
