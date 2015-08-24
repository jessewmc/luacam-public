#!/bin/bash
SOURCE="${HOME}/Github/luacam"
SINK="${HOME}/luacam-production"
IUP="${SOURCE}/iup.out"
LIB="${SOURCE}/lib.out"

echo Do you really want to copy into production?
select yn in "Yes" "No"; do
  case $yn in 
    Yes)
      echo Copying files into production...

      luac -o iup.out iup.lua
      mv $IUP $SINK
      echo $IUP copied to $SINK

      luac -o lib.out lib.lua
      mv $LIB $SINK
      echo $LIB copied to $SINK
      exit
      ;;

    No) exit;;
  esac
done
