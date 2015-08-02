#!/bin/bash
STATION_NAME="$1"
WEBSITE="$2"
cd lib/java_compiler
cp -r RadioTemplate tmp/$STATION_NAME
grep -rl "zeno_secret_code" tmp/$STATION_NAME | xargs sed -i '' "s/zeno_secret_code/$STATION_NAME/g"
sed -i '' "s/zeno_secret_website/$WEBSITE/" tmp/$STATION_NAME/res/values/strings.xml
mv "tmp/$STATION_NAME/smali/com/iconstrats/radiotemplate" "tmp/$STATION_NAME/smali/com/iconstrats/$STATION_NAME"
