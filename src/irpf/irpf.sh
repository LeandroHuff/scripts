#!/bin/bash
if [[ -z $1 ]];
then
   /usr/local/IRPF2022/java-runtime/bin/java -Xms128M -Xmx512M -jar /usr/local/IRPF2022/irpf.jar
elif [[ $1 == "update" ]];
then
   sudo /usr/local/IRPF2022/java-runtime/bin/java -Xms128M -Xmx512M -jar /usr/local/IRPF2022/irpf.jar
else
   printf "\n \e[1;31mError:\e[0m\n\tParameter \e[1;37m$1\e[0m is not valid.\n\t\e[1;37mUse:\e[0m\n\t   irpf.sh\n\t\e[1;37mor\e[0m\n\t   irpf.sh update\n"
fi
