################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2020      351ELEC team (https://github.com/fewtarius/351ELEC)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="hatari"
PKG_VERSION="cea06eebf695b078fadc0e78bb0f2b2baaca799f"
PKG_SHA256="41a044a0a5625052a4a477dca47897aafccd23d835dc20b43e41b37a38e64628"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/hatari"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain capsimg"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="New rebasing of Hatari based on Mercurial upstream. Tries to be a shallow fork for easy upstreaming later on."
PKG_LONGDESC="New rebasing of Hatari based on Mercurial upstream. Tries to be a shallow fork for easy upstreaming later on."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
PKG_USE_CMAKE="no"

configure_target() {
  :
}

make_target() {
  if [ "$ARCH" == "arm" ]; then
    CFLAGS="$CFLAGS -DNO_ASM -DARM -D__arm__ -DARM_ASM -DNOSSE -DARM_HARDFP"
  fi
  CFLAGS="$CFLAGS -I$(get_build_dir capsimg)/Core -I$(get_build_dir capsimg)/.install_pkg/usr/local/include -L$(get_build_dir capsimg)/.install_pkg/usr/lib -lcapsimage -DHAVE_CAPSIMAGE=1 -DCAPSIMAGE_VERSION=5"
  LDFLAGS="$LDFLAGS -I$(get_build_dir capsimg)/LibIPF -DHAVE_CAPSIMAGE=1"
  make -C .. -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  mkdir -p $INSTALL/usr/config/distribution/configs/hatari
  cp ../hatari_libretro.so $INSTALL/usr/lib/libretro/
  cp -rf ${PKG_DIR}/config/* $INSTALL/usr/config/distribution/configs/hatari/
}
