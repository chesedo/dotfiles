#1/bin/sh

volume=`amixer sget Capture | rg 'Left:' | awk -F'[][]' '{ print $2 }' | tr -d '%'`

if [ $volume -eq 0 ]
then
  echo ""
else
  echo ""
fi

