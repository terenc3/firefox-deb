PKG=firefox
BUILDDIR=build
CONTROLDIR=${BUILDDIR}/DEBIAN
INSTALLFOLDER=/usr/lib
INSTALLDIR=/usr/lib/${PKG}
BIN=${INSTALLDIR}/${PKG}

.PHONY: clean

all: firefox control desktop mime bin rights pkg

bin:
	mkdir -p ${BUILDDIR}/usr/bin/
	ln -nsf ../lib/${PKG}/${PKG} ${BUILDDIR}/usr/bin/${PKG}
	chmod +x ${BUILDDIR}/usr/bin/${PKG}

clean:
	-rm -f *.tar.bz2
	-rm -rf ${BUILDDIR}
	-rm -f *.deb

control:
	mkdir -p ${CONTROLDIR}
	$$(sed -e "s#%version%#$$(awk -F "=" '/^Version/ {print $$2}' ${BUILDDIR}/${INSTALLDIR}/application.ini)#g" templates/control > ${CONTROLDIR}/control)
	$$(sed -e "s#%bin%#${BIN}#g" templates/postinst > ${CONTROLDIR}/postinst)
	$$(sed -e "s#%bin%#${BIN}#g" templates/prerm > ${CONTROLDIR}/prerm)

desktop:
	mkdir -p ${BUILDDIR}/usr/share/applications/
	$$(sed -e "s#%installdir%#${INSTALLDIR}#g" templates/${PKG}.desktop > ${BUILDDIR}/usr/share/applications/${PKG}.desktop)

mime:
	mkdir -p ${BUILDDIR}/usr/lib/mime/packages/
	$$(sed -e "s#%bin%#${BIN}#g" templates/mime > ${BUILDDIR}/usr/lib/mime/packages/${PKG})

firefox.tar.bz2:
	wget -O firefox.tar.bz2 -q "https://download.mozilla.org/?product=${PKG}-latest-ssl&os=linux64&lang=de"

firefox: firefox.tar.bz2
	mkdir -p ${BUILDDIR}/${INSTALLFOLDER}
	tar --directory ${BUILDDIR}/${INSTALLFOLDER}/ -jxf ${PKG}.tar.bz2

rights:
	chmod 0775 ${CONTROLDIR}/postinst ${CONTROLDIR}/prerm

pkg:
	dpkg-deb --build ${BUILDDIR}/ "${PKG}_$$(awk -F "=" '/^Version/ {print $$2}' ${BUILDDIR}/${INSTALLDIR}/application.ini)_amd64.deb"
