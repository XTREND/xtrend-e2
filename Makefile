#!/usr/bin/make -f
# target platform: et9x00 (et9000, et9200), et5x00 (et5000), et6x00 (et6000)
MACHINE ?= et9x00
BUILDDIR = build-${MACHINE}
# for a list of some other repositories have
# a look at http://git.opendreambox.org/
GIT_URL = git://github.com/XTREND/openembedded.git
GIT_BRANCH = master
# in case you want to send pull requests or generate patches
#GIT_AUTHOR_NAME ?= Your Name
#GIT_AUTHOR_EMAIL ?= you@example.com
# you should not need to change anything below
BITBAKE_BRANCH = 1.12
GIT = git
PWD := $(shell pwd)
OE_BASE = $(PWD)
all: initialize
	@echo
	@echo "Openembedded for the XTREND environment has been initialized"
	@echo "properly. Now you can start building your image, by doing either:"
	@echo
	@echo " make -f Makefile image"
	@echo "	or"
	@echo " cd $(BUILDDIR) ; source env.source ; bitbake openpli-enigma2-image"
	@echo
	@echo "and after 'some time' you should find your image (.bin) in"
	@echo "$(BUILDDIR)/tmp/deploy/images/"
	@echo
bitbake:
	$(GIT) clone -b $(BITBAKE_BRANCH) git://git.openembedded.org/bitbake
	cd bitbake && ( \
		python setup.py build ;\
	)
.PHONY: image initialize openembedded-update openembedded-update-all
image: initialize openembedded-update
	cd $(OE_BASE)/${BUILDDIR}; . ./env.source; bitbake openpli-enigma2-image
initialize: $(OE_BASE)/cache sources $(OE_BASE)/${BUILDDIR} $(OE_BASE)/${BUILDDIR}/conf \
	$(OE_BASE)/${BUILDDIR}/tmp $(OE_BASE)/${BUILDDIR}/conf/local.conf $(OE_BASE)/${BUILDDIR}/conf/site.conf \
	$(OE_BASE)/${BUILDDIR}/env.source bitbake $(OE_BASE)/openembedded
openembedded-update: initialize
	cd $(OE_BASE)/openembedded && $(GIT) pull origin $(GIT_BRANCH) && $(GIT) submodule update
$(OE_BASE)/${BUILDDIR} $(OE_BASE)/${BUILDDIR}/conf $(OE_BASE)/${BUILDDIR}/tmp $(OE_BASE)/cache sources:
	mkdir -p $@
$(OE_BASE)/${BUILDDIR}/conf/local.conf:
	echo 'OE_BASE = "$(PWD)"' > $@
	echo 'DL_DIR = "$(PWD)/sources"' >> $@
	echo 'BBFILES = "$${OE_BASE}/local/recipes/*/*.bb $${OE_BASE}/openembedded/recipes/*/*.bb"' >> $@
	echo '# BBMASK = "(nslu.*|.*-sdk.*|opie-.*|gpe-*)"' >> $@
	echo 'BBFILE_COLLECTIONS = "overlay"' >> $@
	echo 'BBFILE_PATTERN_overlay = "$${OE_BASE}/local"' >> $@
	echo 'BBFILE_PRIORITY_overlay = 5' >> $@
	echo 'PREFERRED_PROVIDERS += " virtual/$${TARGET_PREFIX}gcc-initial:gcc-cross-initial"' >> $@
	echo 'PREFERRED_PROVIDERS += " virtual/$${TARGET_PREFIX}gcc:gcc-cross"' >> $@
	echo 'PREFERRED_PROVIDERS += " virtual/$${TARGET_PREFIX}g++:gcc-cross"' >> $@
	echo 'MACHINE = "$(MACHINE)"' >> $@
	echo 'TARGET_OS = "linux"' >> $@
	echo 'DISTRO = "openpli"' >> $@
	echo 'CACHE = "$${OE_BASE}/cache/oe-cache.$${USER}.$${MACHINE}"' >> $@
	echo 'TOPDIR = "$${OE_BASE}/build-$${MACHINE}"' >> $@
	echo 'OE_ALLOW_INSECURE_DOWNLOADS = "1"' >> $@
$(OE_BASE)/${BUILDDIR}/conf/site.conf: $(OE_BASE)/site.conf
	@ln -s ../../site.conf $@
$(OE_BASE)/site.conf:
	echo 'BB_NUMBER_THREADS = "8"' >> $@
	echo 'IMAGE_KEEPROOTFS = "0"' >> $@
	echo 'INHERIT += "rm_work"' >> $@
$(OE_BASE)/${BUILDDIR}/env.source:
	echo 'OE_BASE=$(OE_BASE)' > $@
	echo 'MACHINE="$(MACHINE)"' >> $@
	echo 'export BBPATH="$${OE_BASE}/local/:$${OE_BASE}/openembedded/:$${OE_BASE}/bitbake/:$${OE_BASE}/build-$${MACHINE}/"' >> $@
	echo 'PATH=$${OE_BASE}/bitbake/bin:$${OE_BASE}/build-$${MACHINE}/tmp/cross/mipsel/bin:$${PATH}' >> $@
	echo 'export PATH' >> $@
	echo 'export LD_LIBRARY_PATH=' >> $@
	echo 'export LANG=C' >> $@
	echo 'export CVS_RSH=ssh' >> $@
	echo 'umask 0022' >> $@
$(OE_BASE)/openembedded: $(OE_BASE)/openembedded/.git
$(OE_BASE)/openembedded/.git:
	$(GIT) clone -b $(GIT_BRANCH) $(GIT_URL) $(OE_BASE)/openembedded
	cd $(OE_BASE)/openembedded && $(GIT) submodule init  && $(GIT) submodule update && ( \
		if [ -n "$(GIT_AUTHOR_EMAIL)" ]; then git config user.email "$(GIT_AUTHOR_EMAIL)"; fi; \
		if [ -n "$(GIT_AUTHOR_NAME)" ]; then git config user.name "$(GIT_AUTHOR_NAME)"; fi; \
	)
