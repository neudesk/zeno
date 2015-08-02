#!/bin/bash
STATION_NAME="$1"
cd lib/java_compiler
rm -f tmp/$STATION_NAME/res/drawable-hdpi/ic_launcher.png
rm -f tmp/$STATION_NAME/res/drawable-ldpi/ic_launcher.png
rm -f tmp/$STATION_NAME/res/drawable-mdpi/ic_launcher.png
rm -f tmp/$STATION_NAME/res/drawable-xhdpi/ic_launcher.png
rm -f tmp/$STATION_NAME/dist/RadioTemplate.apk
