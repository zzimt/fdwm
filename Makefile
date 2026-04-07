VERSION = 0.2

CC ?= cc
PREFIX ?= /usr/local
MANPREFIX ?= ${PREFIX}/share/man
DESKTOP_DIR ?= /usr/share/xsessions
ICON_DIR ?= /usr/share/pixmaps

X11_CFLAGS = $(shell pkg-config x11 --cflags)
X11_LDFLAGS = $(shell pkg-config x11 --libs)

XINERAMA_CFLAGS = $(shell pkg-config xinerama --cflags)
XINERAMA_LDFLAGS  = $(shell pkg-config xinerama --libs)

FREETYPE2_CFLAGS = $(shell pkg-config freetype2 --cflags)
FREETYPE2_LDFLAGS = $(shell pkg-config freetype2 --libs)

XFT_CFLAGS = $(shell pkg-config xft --cflags)
XFT_LDFLAGS = $(shell pkg-config xft --libs)

FONTCONFIG_CFLAGS = $(shell pkg-config fontconfig --cflags)
FONTCONFIG_LDFLAGS = $(shell pkg-config fontconfig --libs)

LIBS_CFLAGS = ${X11_CFLAGS} ${XINERAMA_CFLAGS} ${FREETYPE2_CFLAGS} ${XFT_CFLAGS} ${FONTCONFIG_CFLAGS}
LIBS_LDFLAGS = ${X11_LDFLAGS} ${XINERAMA_LDFLAGS} ${FREETYPE2_LDFLAGS} ${XFT_LDFLAGS} ${FONTCONFIG_LDFLAGS}

CDEFINITIONS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L -DVERSION=\"${VERSION}\"
CFLAGS = -MMD -MP -Wpedantic -Wall -Wextra -Wno-format-truncation -O3 ${LIBS_CFLAGS} ${CDEFINITIONS}
LDFLAGS  = ${LIBS_LDFLAGS}

SRC_DIR = src
BUILD_DIR = build
DIST_DIR = dist

DIST = ${DIST_DIR}/fdwm-${VERSION}

SRC = ${SRC_DIR}/drw.c ${SRC_DIR}/fdwm.c ${SRC_DIR}/util.c ${SRC_DIR}/main.c
OBJ = $(patsubst ${SRC_DIR}/%.c,${BUILD_DIR}/%.o,${SRC})
DEP = $(OBJ:.o=.d)

BIN = ${BUILD_DIR}/fdwm

all: ${BIN}

${BUILD_DIR}/%.o: ${SRC_DIR}/%.c
	mkdir -p ${BUILD_DIR}
	${CC} -c ${CFLAGS} $< -o $@

${BIN}: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

-include ${DEP}

clean:
	rm -f ${BUILD_DIR}/*.o ${BUILD_DIR}/*.d ${BIN} ${DIST}.tar.gz

dist: clean
	mkdir -p ${DIST}
	cp -R LICENSE Makefile README.md fdwm.1 fdwm.desktop.in fdwm.png src ${DIST}
	tar -cf ${DIST}.tar ${DIST}
	gzip ${DIST}.tar
	rm -rf ${DIST}

install: all
	mkdir -p ${DEST_DIR}${PREFIX}/bin
	cp -f ${BIN} ${DEST_DIR}${PREFIX}/bin/fdwm
	chmod 755 ${DEST_DIR}${PREFIX}/bin/fdwm

	mkdir -p ${DEST_DIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < fdwm.1 > ${DEST_DIR}${MANPREFIX}/man1/fdwm.1
	chmod 644 ${DEST_DIR}${MANPREFIX}/man1/fdwm.1

	mkdir -p ${DEST_DIR}${ICON_DIR}
	cp -f fdwm.png ${DEST_DIR}${ICON_DIR}/fdwm.png
	chmod 644 ${DEST_DIR}${ICON_DIR}/fdwm.png

	mkdir -p ${DEST_DIR}/${DESKTOP_DIR}
	sed 's|@PREFIX@|${PREFIX}|g; s|@ICON_PATH@|${ICON_DIR}/fdwm.png|g;' \
	    fdwm.desktop.in > ${DEST_DIR}${DESKTOP_DIR}/fdwm.desktop
	chmod 644 ${DEST_DIR}${DESKTOP_DIR}/fdwm.desktop

uninstall:
	rm -f ${DEST_DIR}${PREFIX}/bin/fdwm \
		${DEST_DIR}${MANPREFIX}/man1/fdwm.1 \
		${DEST_DIR}${ICON_DIR}/fdwm.png \
		${DEST_DIR}${DESKTOP_DIR}/fdwm.desktop

.PHONY: all clean dist install uninstall
