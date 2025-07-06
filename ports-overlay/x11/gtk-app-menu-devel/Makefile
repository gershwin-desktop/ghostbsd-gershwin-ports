PORTNAME=       appmenu-gtk-module
DISTVERSION=    20250705
PORTREVISION=   1
CATEGORIES=     x11
PKGNAMESUFFIX=  -devel

MAINTAINER=     jpm820@proton.me
COMMENT=        GTK module for putting application menubar in a global menubar
WWW=            https://gitlab.com/vala-panel-project/vala-panel-appmenu/-/tree/master/subprojects/appmenu-gtk-module

LICENSE=        LGPL3
LICENSE_FILE=   ${WRKSRC}/subprojects/appmenu-gtk-module/LICENSE

LIB_DEPENDS=    libbamf3.so:sysutils/bamf

USES=		meson gnome pkgconfig vala:build
CONFLICTS=	gtk-app-menu

MESON_ARGS=     -Dappmenu-gtk-module=enabled \
		-Dbudgie=disabled \
		-Djayatana=disabled \
		-Dmate=disabled \
		-Dregistrar=disabled \
		-Dxfce=disabled \
		-Dvalapanel=disabled

USE_GITLAB=     yes
GL_ACCOUNT=     vala-panel-project
GL_PROJECT=     vala-panel-appmenu
GL_TAGNAME=     c172702

post-extract:
	@${CP} ${FILESDIR}/meson.build ${WRKSRC}/meson.build
	@${CP} ${FILESDIR}/gtk-meson.build ${WRKSRC}/subprojects/appmenu-gtk-module/meson.build

USE_GNOME=      gtk30 glib20 gtk20 gdkpixbuf
GLIB_SCHEMAS=   org.appmenu.gtk-module.gschema.xml

USE_LDCONFIG=   yes
.include <bsd.port.mk>
