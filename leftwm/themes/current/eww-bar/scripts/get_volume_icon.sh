#1/bin/sh

volume=`amixer sget Master | rg 'Left:' | awk -F'[][]' '{ print $2 }' | tr -d '%'`

if [ $volume -eq 0 ]
then
  echo "ﱝ"
elif [ $volume -lt 30 ]
then
  echo "奄"
elif [ $volume -lt 70 ]
then
  echo "奔"
else
  echo "墳"
fi

