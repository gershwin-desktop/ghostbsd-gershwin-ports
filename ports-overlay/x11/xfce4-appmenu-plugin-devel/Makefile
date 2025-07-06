PORTNAME=       xfce4-appmenu-plugin
DISTVERSION=    20250705
PORTREVISION=   1
CATEGORIES=     x11
PKGNAMESUFFIX=  -devel

MAINTAINER=     jpm820@gmail.com
COMMENT=        Application Menu plugin for XFCE panel
WWW=            https://gitlab.com/vala-panel-project/vala-panel-appmenu

LICENSE=        LGPL3
LICENSE_FILE=   ${WRKSRC}/LICENSE

LIB_DEPENDS=    libbamf3.so:sysutils/bamf
RUN_DEPENDS=    appmenu-registrar-devel>=0:x11/appmenu-registrar-devel \
                appmenu-gtk-module-devel>=0:x11/gtk-app-menu-devel

USES=		meson gnome xfce pkgconfig gettext vala:build
CONFLICTS=	xfce4-appmenu-plugin

MESON_ARGS=     -Dvalapanel=disabled \
		-Dxfce=enabled \
		-Dmate=disabled \
		-Dbudgie=disabled \
		-Djayatana=disabled \
		-Dregistrar=disabled \
		-Dappmenu-gtk-module=disabled

USE_XFCE=       panel xfconf
USE_GNOME=      gtk30 glib20 gtk20 gdkpixbuf

USE_GITLAB=     yes
GL_ACCOUNT=     vala-panel-project
GL_PROJECT=     vala-panel-appmenu
GL_TAGNAME=     c172702

post-extract:
	@${CP} ${FILESDIR}/meson.build ${WRKSRC}/meson.build
	@${CP} ${FILESDIR}/lib-meson.build ${WRKSRC}/lib/meson.build

.include <bsd.port.mk>
