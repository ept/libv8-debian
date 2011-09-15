# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2005 Matthew A. Nicholson <matt@matt-land.com>
# Copyright © 2008,2010 Jonas Smedegaard <dr@jones.dk>
# Description: Builds and cleans SCons (SConstruct file) packages
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_class_scons
_cdbs_class_scons = 1

include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)
include $(_cdbs_class_path)/langcore.mk$(_cdbs_makefile_suffix)

#DEB_SCONS_ENVVARS =
DEB_SCONS_PARALLEL ?= $(and $(DEB_BUILD_PARALLEL),$(DEB_PARALLEL_JOBS),-j$(DEB_PARALLEL_JOBS))
DEB_SCONS_INVOKE ?= $(DEB_SCONS_ENVVARS) scons --directory="$(DEB_BUILDDIR)" CC="$(or $(CC_$(cdbs_curpkg)),$(CC))" CFLAGS="$(or $(CFLAGS_$(cdbs_curpkg)),$(CFLAGS))" CXX="$(or $(CXX_$(cdbs_curpkg)),$(CXX))" CXXFLAGS="$(or $(CXXFLAGS_$(cdbs_curpkg)),$(CXXFLAGS))" $(DEB_SCONS_PARALLEL)

# general options (passed on all scons commands)
#DEB_SCONS_OPTIONS =

# build target and options (only passed on build)
#DEB_SCONS_BUILD_TARGET =
#DEB_SCONS_BUILD_OPTIONS =

# install target and options (only passed on install)
DEB_SCONS_INSTALL_TARGET ?= install
#DEB_SCONS_INSTALL_OPTIONS =

# clean target
DEB_SCONS_CLEAN_TARGET ?= .

#DEB_SCONS_CHECK_TARGET =

CDBS_BUILD_DEPENDS_class_scons-vars ?= cdbs (>= 0.4.73~)
CDBS_BUILD_DEPENDS += , $(CDBS_BUILD_DEPENDS_class_scons-vars)

CDBS_BUILD_DEPENDS_class_scons ?= scons
CDBS_BUILD_DEPENDS += , $(CDBS_BUILD_DEPENDS_class_scons)

DEB_PHONY_RULES += scons-clean

common-build-arch common-build-indep:: debian/stamp-scons-build
debian/stamp-scons-build:
	$(DEB_SCONS_INVOKE) $(DEB_SCONS_BUILD_TARGET) $(DEB_SCONS_OPTIONS) $(DEB_SCONS_BUILD_OPTIONS)
	touch debian/stamp-scons-build

clean:: scons-clean
scons-clean::
	$(DEB_SCONS_INVOKE) $(DEB_SCONS_CLEAN_TARGET) $(DEB_SCONS_OPTIONS) --keep-going --clean || true
	rm -f debian/stamp-scons-build
	rm -rf .sconf_temp/
	rm -f .sconsign.dblite config.log

common-install-arch common-install-indep:: common-install-impl
common-install-impl::
	@if test -n "$(DEB_SCONS_INSTALL_TARGET)"; then \
	  echo $(DEB_SCONS_INVOKE) $(DEB_SCONS_INSTALL_TARGET) $(DEB_SCONS_OPTIONS) $(DEB_SCONS_INSTALL_OPTIONS); \
	  $(DEB_SCONS_INVOKE) $(DEB_SCONS_INSTALL_TARGET) $(DEB_SCONS_OPTIONS) $(DEB_SCONS_INSTALL_OPTIONS); \
	else \
	  echo "DEB_SCONS_INSTALL_TARGET unset, skipping default scons.mk common-install target"; \
	fi

ifeq (,$(findstring nocheck,$(DEB_BUILD_OPTIONS)))
common-post-build-arch common-post-build-indep:: common-post-build-impl
common-post-build-impl::
	@if test -n "$(DEB_SCONS_CHECK_TARGET)"; then \
	  echo $(DEB_SCONS_INVOKE) $(DEB_SCONS_CHECK_TARGET); \
	  $(DEB_SCONS_INVOKE) $(DEB_SCONS_CHECK_TARGET) $(DEB_SCONS_OPTIONS); \
	else \
	   echo "DEB_SCONS_CHECK_TARGET unset, not running checks"; \
	fi
endif

endif
