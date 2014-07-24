#!/bin/bash

VERSION=$1

[ -z $VERSION ] && echo Usage: $0 X.Y.Z && exit 1

TGZ=`pwd`/apache-activemq-$VERSION-bin.tar.gz
BN=`basename $TGZ -bin.tar.gz`

if [ ! -e $TGZ  ]
then
  wget "http://www.apache.org/dyn/closer.cgi?path=/activemq/apache-activemq/${VERSION}/apache-activemq-${VERSION}-bin.tar.gz"
fi

pushd . > /dev/null
TMPDIR=`mktemp -d`
cd $TMPDIR
tar -xzf ${TGZ}
mkdir -p etc \
  usr/share/doc \
  var/run/activemq/ \
  var/lib/activemq/ \
  var/lib/activemq/activemq-data \
  var/log \
  usr/bin \
  var/log/activemq \
  etc/init.d

mv apache-activemq-$VERSION usr/share/activemq

mv usr/share/activemq/data var/lib/activemq/data
ln -s /var/lib/activemq/data usr/share/activemq/data

# For Kaha database
ln -s /var/lib/activemq/activemq-data usr/share/activemq/activemq-data

ln -s /var/log/activemq  usr/share/activemq/log

mv usr/share/activemq/docs usr/share/doc/activemq
ln -s /usr/share/doc/activemq usr/share/activemq/docs

mv usr/share/activemq/webapps var/lib/activemq/webapps
ln -s /var/lib/activemq/webapps usr/share/activemq/webapps

mv usr/share/activemq/lib var/lib/activemq/lib
ln -s /var/lib/activemq/lib usr/share/activemq/lib

mv usr/share/activemq/conf etc/activemq
ln -s /etc/activemq usr/share/activemq/conf

ln -s /usr/share/activemq/bin/activemq-admin usr/bin/activemq-admin

echo "This deb was generated from ${BN}" > usr/share/doc/activemq/README.Debian

popd >/dev/null

cp init $TMPDIR/etc/init.d/activemq
chmod 755 $TMPDIR/etc/init.d/activemq

fpm -s dir -t deb \
  -n activemq -v $VERSION -a all \
  -C $TMPDIR \
  -d java6-sdk \
  -m 'Rudy Gevaert <Rudy.Gevaert@UGent.be>' \
  --description "Activemq $VERSION" \
  --url 'http://activemq.apache.org/' \
  --after-install postinst \
  --before-remove prerm \
  --after-remove postrm \
  --config-files etc/activemq/activemq.xml \
  --config-files etc/activemq/log4j.properties \
  .

rm -fr $TMPDIR

