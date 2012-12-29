BUILD_NUMBER=1
OPENNI_VERSION=1.5.4.0

ARCHITECTURE=$(shell uname -m)

ifeq (${ARCHITECTURE},x86_64)
        ARCH=amd64
        OPENNI_ARCH=x64
else 
        ARCH=i386
        OPENNI_ARCH=xx
endif

DISTRO=$(shell lsb_release -sc)

OPENNI_PACKAGE_NAME=openni-dev-${OPENNI_VERSION}~${DISTRO}_$(ARCH)${BUILD_NUMBER}
OPENNI_REDISTNAME=OpenNI-Bin-Dev-Linux-${OPENNI_ARCH}-v${OPENNI_VERSION}

all: debian

debian: debian_openni 

debian_openni : $(OPENNI_PACKAGE_NAME).deb

$(OPENNI_PACKAGE_NAME).deb: ./CONTROL/openni_control ./CONTROL/openni_postinst ./CONTROL/openni_prerm openni_lib
	mkdir -p $(OPENNI_PACKAGE_NAME)/DEBIAN \
					 $(OPENNI_PACKAGE_NAME)/usr/bin \
					 $(OPENNI_PACKAGE_NAME)/usr/include/openni \
	         $(OPENNI_PACKAGE_NAME)/usr/lib \
	         $(OPENNI_PACKAGE_NAME)/etc/openni \
	         $(OPENNI_PACKAGE_NAME)/usr/lib/pkgconfig \
	         $(OPENNI_PACKAGE_NAME)/usr/share/openni/doc \
	         $(OPENNI_PACKAGE_NAME)/usr/share/openni/samples
	cp -f ./CONTROL/openni_postinst $(OPENNI_PACKAGE_NAME)/DEBIAN/postinst
	cp -f ./CONTROL/openni_prerm $(OPENNI_PACKAGE_NAME)/DEBIAN/prerm
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Samples/Config/* $(OPENNI_PACKAGE_NAME)/etc/openni/
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Lib/*.so $(OPENNI_PACKAGE_NAME)/usr/lib/
	cp -r ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Include/* $(OPENNI_PACKAGE_NAME)/usr/include/openni/
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Bin/* $(OPENNI_PACKAGE_NAME)/usr/bin/
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Documentation/html/* $(OPENNI_PACKAGE_NAME)/usr/share/openni/doc/
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Samples/Bin/${OPENNI_ARCH}-Release/Sample-* $(OPENNI_PACKAGE_NAME)/usr/share/openni/samples/
	cp -f ./Platform/Linux/Redist/${OPENNI_REDISTNAME}/Samples/Bin/${OPENNI_ARCH}-Release/NiViewer $(OPENNI_PACKAGE_NAME)/usr/share/openni/samples/
	@sed s/__VERSION__/${OPENNI_VERSION}~${DISTRO}/ ./CONTROL/openni_control | sed s/__ARCHITECTURE__/$(ARCH)/ > $(OPENNI_PACKAGE_NAME)/DEBIAN/control
	@sed s/__VERSION__/${OPENNI_VERSION}~${DISTRO}/ ./CONTROL/openni.pc > $(OPENNI_PACKAGE_NAME)/usr/lib/pkgconfig/openni-dev.pc
	@dpkg-deb -b $(OPENNI_PACKAGE_NAME)

openni_lib:
	cd Platform/Linux/CreateRedist && bash RedistMaker && cd -

clean:
	rm -rf $(OPENNI_PACKAGE_NAME)
	rm -f $(OPENNI_PACKAGE_NAME).deb

