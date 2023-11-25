#1/bin/sh

volume=`amixer get Master | rg -o 'Left:.*\\[(\\d+)%\\]' -r '$1'`

if [ $volume -eq 0 ]
then
  echo "󰖁"
elif [ $volume -lt 30 ]
then
  echo "󰕿"
elif [ $volume -lt 70 ]
then
  echo "󰖀"
else
  echo "󰕾"
fi

