#!/bin/sh
set -e

# If key.properties is not already mounted, generate it from env vars
if [ ! -f android/key.properties ]; then
  cat > android/key.properties <<EOF
storePassword=${STORE_PASSWORD}
keyPassword=${KEY_PASSWORD}
keyAlias=scorepad
storeFile=/keys/scorepad-upload-key.jks
EOF
fi

flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk /output/ScorePad.apk
echo "APK copied to /output/ScorePad.apk"
