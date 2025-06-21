PORTNAME=	ghostbsd-gershwin-settings
DISTVERSION=	20250621
CATEGORIES=	x11

MAINTAINER=	jpm820@proton.me
COMMENT=	GhostBSD integration settings for the Gershwin desktop
WWW=		https://github.com/gershwin-os/ghostbsd-gershwin-settings

LICENSE=	BSD2CLAUSE

USES=		uidfix

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-os
GH_TAGNAME=	e4fc500

NO_ARCH=	yes
NO_BUILD=	yes

do-install:
	# Install bin scripts
	@${MKDIR} ${STAGEDIR}${PREFIX}/bin
	${INSTALL_SCRIPT} ${WRKSRC}/bin/gershwin-x11 ${STAGEDIR}${PREFIX}/bin/

	# Install etc files
	@cd ${WRKSRC}/etc && \
		${FIND} . -type d -exec ${MKDIR} "${STAGEDIR}/etc/{}" \; && \
		${FIND} . -type f -exec ${INSTALL_DATA} "{}" "${STAGEDIR}/etc/{}" \;

	# Install share files
	@cd ${WRKSRC}/share && \
		${FIND} . -type d -exec ${MKDIR} "${STAGEDIR}${PREFIX}/share/{}" \; && \
		${FIND} . -type f -exec ${INSTALL_DATA} "{}" "${STAGEDIR}${PREFIX}/share/{}" \;

.include <bsd.port.mk>
