#!/bin/bash

while getopts v:r: option
do
case "${option}"
in
v) VERSION=${OPTARG};;
r) RELEASE=${OPTARG};;
esac
done

APP=$name
PROJECT='eos-sdk-vrrp-route-tracking'
DUT='l3-l11.networkrob.com'
echo "Creating RPM Directories"
mkdir -p rpmbuild/SOURCES
mkdir -p rpmbuild/RPM
echo "OK"
echo "Creating source package"
tar -cvf rpmbuild/SOURCES/${APP}-${VERSION}-${RELEASE}.tar source/*
echo "OK"

echo "Changing to RPM Spec directory"
cd /workspaces/${PROJECT}/rpmbuild/SPECS
echo "OK"

echo "Starting RPM Build"
rpmbuild -ba ${APP}.spec
echo "OK"

echo "Changing to ${PROJECT} root directory"
cd /workspaces/${PROJECT}

echo "Start creating new manifest file"
rm manifest.txt

echo "format: 1" >> manifest.txt
echo "primaryRPM: ${APP}-${VERSION}-${RELEASE}.noarch.rpm" >> manifest.txt
echo -n "${APP}-${VERSION}-${RELEASE}.noarch.rpm: " >> manifest.txt
echo $(sha1sum rpmbuild/RPM/noarch/${APP}-${VERSION}-${RELEASE}.noarch.rpm | awk '{print $1}') >> manifest.txt

echo "Start file transfer and swix create"
scp -i ~/.ssh/builder /workspaces/${PROJECT}/rpmbuild/RPM/noarch/${APP}-${VERSION}-${RELEASE}.noarch.rpm builder@${DUT}:/mnt/flash/ext-eos/
scp -i ~/.ssh/builder manifest.txt builder@${DUT}:/mnt/flash/ext-eos/

ssh -i ~/.ssh/builder builder@${DUT} bash swix create /mnt/flash/ext-eos/swix/${APP}-${VERSION}-${RELEASE}.swix /mnt/flash/ext-eos/${APP}-${VERSION}-${RELEASE}.noarch.rpm

scp -i ~/.ssh/builder builder@${DUT}:/mnt/flash/ext-eos/swix/${APP}-${VERSION}-${RELEASE}.swix /workspaces/${PROJECT}/extension/
echo "OK"
echo "SWIX can be found at: /workspaces/${PROJECT}/extension/${APP}-${VERSION}-${RELEASE}.swix"

echo "Copying to ${DUT}"
scp -i ~/.ssh/builder /workspaces/${PROJECT}/extension/${APP}-${VERSION}-${RELEASE}.swix builder@${DUT}:/mnt/flash
echo "DONE"
