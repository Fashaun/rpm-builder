#!/bin/bash

# help set
# -e  Exit immediately if a command exits with a non-zero status.
set -e

pid=$$
#pid=PID	# debug usage
SOURCE_DIR=$1
OUTPUT_DIR=$2
NAME=$3
VERSION=$4
RELEASE=$5
INSTALL_DIR=$6
PACKAGE_SPEC_FILE=$7
RPM_BUILD_WORK_DIR=$HOME/tmp-rpm-build/$pid

if [ -z "$OUTPUT_DIR" ] ; then
	echo "Usage> bash $0 SOURCE_DIR RPM_OUTPUT_DIR RPM_PACKAGE_NAME RPM_PACKAGE_VERSION RPM_PACKAGE_VERSION RPM_PACKAGE_INSTALL_DIR"
	exit;
fi

if [ -z "$OUTPUT_DIR" ] ; then
	OUTPUT_DIR=$HOME/tmp-rpm-build/
fi

if [ ! -d "$SOURCE_DIR" ] ; then
	echo "[ERROR] SOURCE_DIR NOT EXISTS: $SOURCE_DIR"
	exit
fi

if [ -z "$NAME" ] ; then
	echo "[ERROR] NO NAME";
	exit
fi
if [ -z "$VERSION" ] ; then
	echo "[ERROR] NO VERSION";
	exit
fi
if [ -z "$RELEASE" ] ; then
	echo "[ERROR] NO RELEASE";
	exit
fi

if [ -z "$INSTALL_DIR" ] ; then
	INSTALL_DIR=/opt
fi

if [ ! -z "$PACKAGE_SPEC_FILE" ] ; then
	if [ ! -e $PACKAGE_SPEC_FILE ] ; then
		echo "[ERROR] PACKAGE_SPEC_FILE NOT EXISTS: $PACKAGE_SPEC_FILE"
		exit
	fi
fi

PACKAGE_NAME=$NAME-$VERSION
PACKAGE_DIR=$RPM_BUILD_WORK_DIR/SOURCES/$PACKAGE_NAME
#PACKAGE_TGZ_NAME=$NAME-$VERSION-$RELEASE.tar.gz
PACKAGE_TGZ_NAME=$NAME-$VERSION.tar.gz
PACKAGE_RPM_SPEC_FILENAME=$NAME-$VERSION-$RELEASE.spec

# build rpm dirs
mkdir -p $RPM_BUILD_WORK_DIR/BUILD $RPM_BUILD_WORK_DIR/RPMS $RPM_BUILD_WORK_DIR/SOURCES $RPM_BUILD_WORK_DIR/SPECS $RPM_BUILD_WORK_DIR/SRPMS -p $RPM_BUILD_WORK_DIR/BUILDROOT
mkdir -p $PACKAGE_DIR

#cp -a $SOURCE_DIR/. $PACKAGE_DIR/
rsync -a --exclude=.git --exclude=.git* --exclude=*.sql $SOURCE_DIR/. $PACKAGE_DIR/
cd $RPM_BUILD_WORK_DIR/SOURCES && tar -zcvf $PACKAGE_TGZ_NAME $PACKAGE_NAME
if [ ! -z "$PACKAGE_SPEC_FILE" ] ; then
	cp -ar $PACKAGE_SPEC_FILE $RPM_BUILD_WORK_DIR/SPECS/$PACKAGE_RPM_SPEC_FILENAME
else

cat <<EOF > $RPM_BUILD_WORK_DIR/SPECS/$PACKAGE_RPM_SPEC_FILENAME

%define Name $NAME
%define Source $PACKAGE_TGZ_NAME
%define Version $VERSION
%define Release $RELEASE
%define RPM_ARCH $HOSTTYPE
%define OWNER root
%define Vendor no
%define Packager no
%define License MIT
%define Group Applications/File

%define INSTALL_DIR $INSTALL_DIR/$NAME

%define _topdir $RPM_BUILD_WORK_DIR
%define RPM_BUILD_ROOT _topdir
%define BuildRoot $RPM_BUILD_WORK_DIR/BUILDROOT/%Name-%Version-%Release.%RPM_ARCH

Summary: %Name
Name: %Name
Version: %Version
Release: %Release
Vendor: %Vendor
Packager: %Packager
License: %License
Group: %Group
SOURCE: %Source
BuildArch: noarch
BuildRoot: %BuildRoot

%description

%prep

%setup -q

%build

%install
install -d %BuildRoot/%INSTALL_DIR
cp -r $PACKAGE_DIR/*.* %BuildRoot/%INSTALL_DIR
#find %BuildRoot/%INSTALL_DIR -type f | xargs chmod 644

%files
%INSTALL_DIR
%defattr(-,%OWNER,%OWNER,-)

%changelog

EOF
fi
#echo $PACKAGE_RPM_SPEC_FILENAME

echo "Build RPM"

cd $RPM_BUILD_WORK_DIR/SPECS && HOME=$RPM_BUILD_WORK_DIR rpmbuild -bb $PACKAGE_RPM_SPEC_FILENAME && cd -

if [ ! -z "$OUTPUT_DIR" ] && [ -d "$OUTPUT_DIR" ] ; then
	echo "OUTPUT_DIR: $OUTPUT_DIR"
	find $RPM_BUILD_WORK_DIR -name "*.rpm" -exec mv {} $OUTPUT_DIR \;
fi
if [ ! -z "$RPM_BUILD_WORK_DIR" ] && [ "/" != "$RPM_BUILD_WORK_DIR" ] ; then
	rm -rf $RPM_BUILD_WORK_DIR/;
fi
