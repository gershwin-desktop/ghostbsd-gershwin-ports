POUDRIERE_ETC= /zroot/gnustep-build/etc
SCRIPT_DIR= ${.CURDIR}
FUNCS= ${SCRIPT_DIR}/functions.sh

.SUFFIXES:
.SILENT:

ports:
	@sh -c ". ${FUNCS}; ports_target"

clean:
	@sh -c ". ${FUNCS}; clean_zfs"
