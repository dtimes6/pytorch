#!/usr/bin/env bash
set -eu -o pipefail

export ANDROID_NDK_HOME=/opt/ndk
export ANDROID_HOME=/opt/android/sdk

export GRADLE_VERSION_FOR_PUBLISH=4.10.3

#--- Move to Docker Image
echo "GRADLE_VERSION:${GRADLE_VERSION_FOR_PUBLISH}"
_gradle_home=/opt/gradle
sudo mkdir -p $_gradle_home

wget --no-verbose --output-document=/tmp/gradle.zip \
"https://services.gradle.org/distributions/gradle-${GRADLE_VERSION_FOR_PUBLISH}-bin.zip"

sudo unzip -q /tmp/gradle.zip -d $_gradle_home
rm /tmp/gradle.zip

sudo chmod -R 777 $_gradle_home
#---

export GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION_FOR_PUBLISH
export GRADLE_PATH=$GRADLE_HOME/bin/gradle

echo "BUILD_ENVIRONMENT:$BUILD_ENVIRONMENT"
ls -la ~/workspace

if [ -z "$SONATYPE_NEXUS_USERNAME" ]; then
  echo "Error: missing env variable SONATYPE_NEXUS_USERNAME."
elif [ -z "$SONATYPE_NEXUS_PASSWORD" ]; then
  echo "Error: missing env variable SONATYPE_NEXUS_PASSWORD."
elif [ -z "$ANDROID_SIGN_KEY" ]; then
  echo "Error: missing env variable ANDROID_SIGN_KEY."
elif [ -z "$ANDROID_SIGN_PASS" ]; then
  echo "Error: missing env variable ANDROID_SIGN_PASS."
else
  export GRADLE_LOCAL_PROPERTIES=~/workspace/android/local.properties
  rm -f $GRADLE_LOCAL_PROPERTIES

  echo "sdk.dir=/opt/android/sdk" >> $GRADLE_LOCAL_PROPERTIES
  echo "ndk.dir=/opt/ndk" >> $GRADLE_LOCAL_PROPERTIES

  echo "SONATYPE_NEXUS_USERNAME=${SONATYPE_NEXUS_USERNAME}" >> $GRADLE_LOCAL_PROPERTIES
  echo "SONATYPE_NEXUS_PASSWORD=${SONATYPE_NEXUS_PASSWORD}" >> $GRADLE_LOCAL_PROPERTIES

  echo "signing.keyId=${ANDROID_SIGN_KEY}" >> $GRADLE_LOCAL_PROPERTIES
  echo "signing.password=${ANDROID_SIGN_PASS}" >> $GRADLE_LOCAL_PROPERTIES

  #$GRADLE_PATH -p ~/workspace/android/ uploadArchives
  $GRADLE_PATH -PABI_FILTERS=x86  -p ~/workspace/android/ uploadArchives
fi
