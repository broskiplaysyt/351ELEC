# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)

PKG_NAME="freej2me"
PKG_VERSION="560859c84d26f27cfa264555d1c856aeb630c13a"
PKG_SHA256="d343da4dc4db31d40fd97cbe584f9f92c3992e12189a909ca8e65c753df443aa"
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/hex007/freej2me"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain apache-ant:host"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="A free J2ME emulator with libretro, awt and sdl2 frontends."
PKG_LONGDESC="A free J2ME emulator with libretro, awt and sdl2 frontends."
PKG_TOOLCHAIN="make"

pre_configure_target() {
  ${TOOLCHAIN}/bin/ant
}

make_target() {
  make -C ${PKG_BUILD}/src/libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp ${PKG_BUILD}/src/libretro/freej2me_libretro.so $INSTALL/usr/lib/libretro/

  mkdir -p $INSTALL/usr/config/distribution/freej2me
  cp ${PKG_BUILD}/build/freej2me-lr.jar $INSTALL/usr/config/distribution/freej2me

  mkdir -p $INSTALL/usr/bin
  cp ${PKG_DIR}/freej2me.sh $INSTALL/usr/bin
}
