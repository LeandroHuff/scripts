#!/bin/bash

#   @brief: Bash script file to run any linux command with parameters from a terminal
#           and return to the terminal to execute another commands without blocking it.
#    @file: run
#  @author: Leandro Daniel Huff - leandrohuff@programmer.net
#    @date: 2021/09/14 (YYYY/MM/DD)
# @version: 1.0.0
# @sintaxe: run <LinuxCommand> [param1] [param2] [param3] ... [param8]
#
#           where:
#
#           run            - is the bash script to be executed from a linux terminal.
#           <LinuxCommand> - any valid linux command.
#           [param1]       - optional, first parameter passed to command from terminal.
#				[param2]       - optional, second parameter passed to command from terminal.
#           [param3]       - optional, third parameter passed to command from terminal.
#       ... [param8]       - optionals, accept up to 8 parameters passed to command from terminal.
#
# Script Command Description:
#
#     $command - Linux command passed by terminal at first parameter.
#       $2..$9 - Optional parameters passed to linux command from terminal line command.
#  < /dev/null - Avoid any input message from terminal.
# &> /dev/null - Avoid any output message to terminal.
#            & - Stay running while return to terminal without blocking it.

command=$1
$command $2 $3 $4 $5 $6 $7 $8 $9 < /dev/null &> /dev/null &

