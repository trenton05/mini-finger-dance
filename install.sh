#!/bin/bash

if [ ! -f "./original/mfd.xapk" ]; then
    echo "./original/mfd.xapk not found, download it here https://m.apkpure.com/mini-finger-dance/com.yxjh.antigravitydance and place in ./original/mfd.xapk"
    exit 0
fi

cd original
unzip mfd.xapk
cd ..

rm -f *.apk

rm -fR com.yxjh.antigravitydance
mkdir com.yxjh.antigravitydance

node com.yxjh.antigravitydance.js

cd com.yxjh.antigravitydance
zip -r ../com.yxjh.antigravitydance.apk *
cd ..
jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore ./platform.keystore -storepass schmuck com.yxjh.antigravitydance.apk platform

rm -fR base_assets
mkdir base_asssets
unzip -d base_assets ./original/base_assets.apk

node base_assets.js

cd base_assets
zip -r ../base_assets.apk *
cd ..
jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore ./platform.keystore -storepass schmuck base_assets.apk platform

rm -fR config.arm64_v8a
mkdir config.arm64_v8a

cd config.arm64_v8a
zip -r ../config.arm64_v8a.apk *
cd ..
jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore ./platform.keystore -storepass schmuck config.arm64_v8a.apk platform

adb install com.yxjh.antigravitydance.apk
adb install base_assets.apk
adb install config.arm64_v8a.apk
