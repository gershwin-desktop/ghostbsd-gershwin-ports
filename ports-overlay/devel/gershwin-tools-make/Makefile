PORTNAME=	tools-make
DISTVERSION=	20250615
CATEGORIES=	devel gnustep
PKGNAMEPREFIX=	gershwin-


MAINTAINER=	jpm820@proton.me
COMMENT=	GNUstep makefile package
WWW=		http://www.gnustep.org/

LICENSE=	GPLv3
CONFLICTS=	gnustep-make

USES=		gershwin objc
GNU_CONFIGURE=	yes

BUILD_DEPENDS=	${GNUSTEP_PREFIX}System/Library/Preferences/GNUstep.conf:misc/gershwin-globaldefaults
RUN_DEPENDS=	${GNUSTEP_PREFIX}System/Library/Preferences/GNUstep.conf:misc/gershwin-globaldefaults

USE_GITHUB=	yes
GH_ACCOUNT=	gnustep
GH_TAGNAME=	faa64aa

MAKE_FLAGS=	OPTFLAG="${CFLAGS}"
CONFIGURE_ENV+=	INSTALL_PROGRAM="${INSTALL} -c" INSTALL_DATA="${INSTALL} -c"

CONFIGURE_ARGS+= \
		--with-config-file=/System/Library/Preferences/GNUstep.conf \
		--enable-importing-config-file \
		--with-library-combo=ng-gnu-gnu

GNU_CONFIGURE_PREFIX= ${GNUSTEP_PREFIX}
NO_ARCH=	yes

.include <bsd.port.mk>
