#!/usr/bin/make -f

PROFILE					:= mesanine
ALPINE_NAME     := $(PROFILE)
MODLOOP_EXTRA   := 
KERNEL_FLAVOR   := grsec
KERNEL_FLAVOR_DEFAULT := grsec
SYSLINUX_SERIAL	:= serial 0 115200
BOOT_OPTS	:= KOPT_chart=yes KOPT_ignition_oem=qemu console=tty0 console=ttyS0,115200 single

BUILD_DATE	:= $(shell date +%y%m%d)
ALPINE_RELEASE	?= $(BUILD_DATE)
ALPINE_NAME	?= alpine-test
ALPINE_ARCH	:= x86_64

DESTDIR		?= $(shell pwd)/isotmp.$(PROFILE)

MKSQUASHFS	= mksquashfs
SUDO		= sudo
TAR		= busybox tar
GENISO		= xorrisofs
APK_SEARCH	= apk search --exact

ISO		?= $(ALPINE_NAME)-$(ALPINE_RELEASE)-$(ALPINE_ARCH).iso
ISO_LINK	?= $(ALPINE_NAME).iso
ISO_DIR		:= $(DESTDIR)/isofs
ISO_PKGDIR	:= $(ISO_DIR)/apks/$(ALPINE_ARCH)

#APKS		?= $(shell sed 's/\#.*//; s/\*/\\*/g' $(PROFILE).packages)
APKS := bkeymaps \
	alpine-base \
	alpine-mirrors \
	network-extras \
	openssl \
	openssh \
	chrony \
	tzdata \
	acct \
	openssh \
	ignition \
	mesanine-base

APK_KEYS	?= /etc/apk/keys
APK_OPTS	:= $(addprefix --repository ,$(APK_REPOS)) --keys-dir $(APK_KEYS) --repositories-file /etc/apk/repositories --quiet --no-progress

APK_FETCH_STDOUT := apk fetch $(APK_OPTS) --stdout

KERNEL_FLAVOR_DEFAULT	?= grsec
KERNEL_FLAVOR	?= $(KERNEL_FLAVOR_DEFAULT)
CUR_KERNEL_FLAVOR	= $*
CUR_KERNEL_PKGNAME	= linux-$*


help:
	@echo "Alpine ISO builder"
	@echo
	@echo "Type 'make iso' to build $(ISO)"
	@echo
	@echo "ALPINE_NAME:    $(ALPINE_NAME)"
	@echo "ALPINE_RELEASE: $(ALPINE_RELEASE)"
	@echo "KERNEL_FLAVOR:  $(KERNEL_FLAVOR)"
	@echo "APKOVL:         $(APKOVL)"
	@echo

clean-iso: clean-modloop clean-initfs clean-syslinux
	rm -rf $(ISO) $(ISO_LINK) $(ISO_DIR) \
		$(ISO_REPOS_DIRSTAMP) $(ISOFS_DIRSTAMP) \
		$(ALL_ISO_KERNEL)


#$(APK_FILES):
#	@echo ==================RUNNING APK_FILES $@ ==========================
#	mkdir -p "$(dir $@)";\
#	p="$(notdir $(basename $@))";\
	apk fetch $(APK_OPTS) -R -v -o "$(dir $@)" $${p%-[0-9]*}

#
# Modloop
#
MODLOOP		:= $(ISO_DIR)/boot/modloop-%
MODLOOP_DIR	= $(DESTDIR)/modloop.$*
MODLOOP_KERNELSTAMP := $(DESTDIR)/stamp.modloop.kernel.%
MODLOOP_DIRSTAMP := $(DESTDIR)/stamp.modloop.%
MODLOOP_EXTRA	?= $(addsuffix -$*, dahdi-linux xtables-addons)
MODLOOP_FIRMWARE ?= linux-firmware dahdi-linux
MODLOOP_PKGS	= $(CUR_KERNEL_PKGNAME) $(MODLOOP_EXTRA) $(MODLOOP_FIRMWARE)

modloop-%: $(MODLOOP)
	@:

ALL_MODLOOP = $(foreach flavor,$(KERNEL_FLAVOR),$(subst %,$(flavor),$(MODLOOP)))
ALL_MODLOOP_DIRSTAMP = $(foreach flavor,$(KERNEL_FLAVOR),$(subst %,$(flavor),$(MODLOOP_DIRSTAMP)))

modloop: $(ALL_MODLOOP)

$(MODLOOP_KERNELSTAMP):
	@echo ======================MODLOOP_KERNELSTAMP $@ =============================
	@echo "==> modloop: Unpacking kernel modules";
	rm -rf $(MODLOOP_DIR) && mkdir -p $(MODLOOP_DIR)/tmp $(MODLOOP_DIR)/lib/modules
	apk add $(APK_OPTS) \
		--initdb \
		--update \
		--no-script \
		--root $(MODLOOP_DIR)/tmp \
		$(MODLOOP_PKGS)
	mv "$(MODLOOP_DIR)"/tmp/lib/modules/* "$(MODLOOP_DIR)"/lib/modules/
	if [ -d "$(MODLOOP_DIR)"/tmp/lib/firmware ]; then \
		find "$(MODLOOP_DIR)"/lib/modules -type f -name "*.ko" | xargs modinfo -F firmware | sort -u | while read FW; do \
			if [ -e "$(MODLOOP_DIR)/tmp/lib/firmware/$${FW}" ]; then \
				install -pD "$(MODLOOP_DIR)/tmp/lib/firmware/$${FW}" "$(MODLOOP_DIR)/lib/modules/firmware/$${FW}"; \
			fi \
		done \
	fi
	cp $(MODLOOP_DIR)/tmp/usr/share/kernel/$*/kernel.release $@

MODLOOP_KERNEL_RELEASE = $(shell cat $(subst %,$*,$(MODLOOP_KERNELSTAMP)))

$(MODLOOP_DIRSTAMP): $(MODLOOP_KERNELSTAMP)
	@echo ==========================MODLOOP_DIRSTAMP $@ ====================================
	rm -rf $(addprefix $(MODLOOP_DIR)/modules/*/, source build)
	depmod $(MODLOOP_KERNEL_RELEASE) -b $(MODLOOP_DIR)
	touch $@

$(MODLOOP): $(MODLOOP_DIRSTAMP)
	@echo ============================MODLOOP $@ ==========================================
	@echo "==> modloop: building image $(notdir $@)"
	mkdir -p $(dir $@)
	$(MKSQUASHFS) $(MODLOOP_DIR)/lib $@ -comp xz

clean-modloop-%:
	rm -rf $(MODLOOP_DIR) $(subst %,$*,$(MODLOOP_DIRSTAMP) $(MODLOOP_KERNELSTAMP) $(MODLOOP))

clean-modloop: $(addprefix clean-modloop-,$(KERNEL_FLAVOR))

#
# Initramfs rules
#

# isolinux cannot handle - in filenames
INITFS_NAME	:= initramfs-%
INITFS		:= $(ISO_DIR)/boot/$(INITFS_NAME)

INITFS_DIR	= $(DESTDIR)/initfs.$*
INITFS_TMP	= $(DESTDIR)/tmp.initfs.$*
INITFS_DIRSTAMP := $(DESTDIR)/stamp.initfs.%
INITFS_FEATURES	?= ata base bootchart cdrom squashfs ext2 ext3 ext4 mmc qemu raid scsi usb virtio
INITFS_PKGS	= $(MODLOOP_PKGS) alpine-base acct mdadm ignition

initfs-%: $(INITFS)
	@:

ALL_INITFS = $(foreach flavor,$(KERNEL_FLAVOR),$(subst %,$(flavor),$(INITFS)))

initfs: $(ALL_INITFS)

$(INITFS_DIRSTAMP):
	@echo =============================== INITFS_DIRSTAMP $@ =========================================
	rm -rf $(INITFS_DIR) $(INITFS_TMP)
	mkdir -p $(INITFS_DIR) $(INITFS_TMP)
	apk add $(APK_OPTS) \
		--initdb \
		--update \
		--no-script \
		--root $(INITFS_DIR) \
		$(INITFS_PKGS)
	cp -r $(APK_KEYS) $(INITFS_DIR)/etc/apk/ || true
	if ! [ -e "$(INITFS_DIR)"/etc/mdev.conf ]; then \
		cat $(INITFS_DIR)/etc/mdev.conf.d/*.conf \
			> $(INITFS_DIR)/etc/mdev.conf; \
	fi
	touch $@

$(INITFS): $(INITFS_DIRSTAMP) $(MODLOOP_DIRSTAMP)
	@echo =================================== INITFS $@ ============================================
	mkinitfs -k -F "$(INITFS_FEATURES)" -t $(INITFS_TMP) \
		-b $(INITFS_DIR) -o $@ $(MODLOOP_KERNEL_RELEASE)

clean-initfs-%:
	rm -rf $(subst %,$*,$(INITFS) $(INITFS_DIRSTAMP)) $(INITFS_DIR) $(INITFS_TMP)

clean-initfs: $(addprefix clean-initfs-,$(KERNEL_FLAVOR))

#
# ISO rules
#

ISOLINUX_DIR	:= boot/syslinux
ISOLINUX	:= $(ISO_DIR)/$(ISOLINUX_DIR)
ISOLINUX_BIN	:= $(ISOLINUX)/isolinux.bin
ISOLINUX_C32	:= $(ISOLINUX)/ldlinux.c32 $(ISOLINUX)/libutil.c32 \
			$(ISOLINUX)/libcom32.c32 $(ISOLINUX)/mboot.c32
SYSLINUX_CFG	:= $(ISOLINUX)/syslinux.cfg
SYSLINUX_SERIAL	?=
SYSLINUX_TIMEOUT ?= 20
SYSLINUX_PROMPT ?= 1


$(ISOLINUX_C32):
	@echo "==> iso: install $(notdir $@)"
	mkdir -p $(dir $@)
	if ! $(APK_FETCH_STDOUT) syslinux \
		| $(TAR) -O -zx usr/share/syslinux/$(notdir $@) > $@; then \
		rm -f $@ && exit 1;\
	fi

$(ISOLINUX_BIN):
	@echo "==> iso: install isolinux"
	mkdir -p $(dir $(ISOLINUX_BIN))
	if ! $(APK_FETCH_STDOUT) syslinux \
		| $(TAR) -O -zx usr/share/syslinux/isolinux.bin > $@; then \
		rm -f $@ && exit 1;\
	fi

# strip trailing -vanilla on kernel name
VMLINUZ_NAME = $$(echo vmlinuz-$(1) | sed 's/-vanilla//')

$(SYSLINUX_CFG): $(ALL_MODLOOP_DIRSTAMP)
	@echo "==> iso: configure syslinux"
	echo "$(SYSLINUX_SERIAL)" >$@
	echo "timeout 20" >>$@
	echo "prompt 1" >>$@
	echo "default $(KERNEL_FLAVOR_DEFAULT)" >>$@
	for flavor in $(KERNEL_FLAVOR); do \
		echo "label $$flavor"; \
		echo "	kernel /boot/$(call VMLINUZ_NAME,$$flavor)";\
		echo "	append initrd=/boot/initramfs-$$flavor modloop=/boot/modloop-$$flavor modules=loop,squashfs,sd-mod,usb-storage $(BOOT_OPTS)"; \
	done >>$@

clean-syslinux:
	rm -f $(SYSLINUX_CFG) $(ISOLINUX_BIN)

ISO_KERNEL_STAMP	:= $(DESTDIR)/stamp.kernel.%
ISO_KERNEL	= $(ISO_DIR)/boot/$*
ISO_REPOS_DIRSTAMP := $(DESTDIR)/stamp.isorepos
ISOFS_DIRSTAMP	:= $(DESTDIR)/stamp.isofs

$(ISO_REPOS_DIRSTAMP): $(ISO_PKGDIR)/APKINDEX.tar.gz
	touch $(ISO_PKGDIR)/../.boot_repository
	rm -f $(ISO_PKGDIR)/.SIGN.*
	touch $@

$(ISO_PKGDIR)/APKINDEX.tar.gz:
	@echo "==> iso: generating repository"
	mkdir -p "$(ISO_PKGDIR)"
	apk fetch $(APK_OPTS) \
			--output $(ISO_PKGDIR) \
			--recursive $(APKS) || { rm $(ISO_PKGDIR)/*.apk; exit 1; }
	apk index --description "$(ALPINE_NAME) $(ALPINE_RELEASE)" \
		--rewrite-arch $(ALPINE_ARCH) -o $@ $(ISO_PKGDIR)/*.apk
	abuild-sign $@

repo: $(ISO_PKGDIR)/APKINDEX.tar.gz

$(ISO_KERNEL_STAMP): $(MODLOOP_DIRSTAMP)
	@echo "==> iso: install kernel $(CUR_KERNEL_PKGNAME)"
	mkdir -p $(dir $(ISO_KERNEL))
	@echo "Fetching $(CUR_KERNEL_PKGNAME)"
	$(APK_FETCH_STDOUT) $(CUR_KERNEL_PKGNAME) \
		| $(TAR) -C $(ISO_DIR) -xz boot
	rm -f $(ISO_KERNEL)
	if [ "$(CUR_KERNEL_FLAVOR)" = "vanilla" ]; then \
		ln -s vmlinuz $(ISO_KERNEL);\
	else \
		ln -s vmlinuz-$(CUR_KERNEL_FLAVOR) $(ISO_KERNEL);\
	fi
	rm -rf $(ISO_DIR)/.[A-Z]* $(ISO_DIR)/.[a-z]* $(ISO_DIR)/lib
	touch $@

ALL_ISO_KERNEL = $(foreach flavor,$(KERNEL_FLAVOR),$(subst %,$(flavor),$(ISO_KERNEL_STAMP)))

$(ISOFS_DIRSTAMP): $(ALL_MODLOOP) $(ALL_INITFS) $(ISO_REPOS_DIRSTAMP) $(ISOLINUX_BIN) $(ISOLINUX_C32) $(ALL_ISO_KERNEL) $(APKOVL_STAMP) $(SYSLINUX_CFG) $(APKOVL_DEST)
	echo "$(ALPINE_NAME)-$(ALPINE_RELEASE) $(BUILD_DATE)" \
		> $(ISO_DIR)/.alpine-release
	touch $@

$(ISO): $(ISOFS_DIRSTAMP)
	@echo "==> iso: building $(notdir $(ISO))"
	$(GENISO) -o $(ISO) -l -J -R \
		-b $(ISOLINUX_DIR)/isolinux.bin \
		-c $(ISOLINUX_DIR)/boot.cat	\
		-no-emul-boot		\
		-boot-load-size 4	\
		-boot-info-table	\
		-quiet			\
		-follow-links		\
		-V "$(ALPINE_NAME) $(ALPINE_RELEASE) $(ALPINE_ARCH)" \
		$(ISO_OPTS)		\
		$(ISO_DIR) && isohybrid $(ISO)
	ln -fs $@ $(ISO_LINK)

#build-iso: $(ISOFS_DIRSTAMP) $(ISO)
iso: $(ISO)

clean: clean-iso

release_targets := $(ISO)
SHA1	:= $(ISO).sha1
SHA256	:= $(ISO).sha256
SHA512	:= $(ISO).sha512

$(SHA1) $(SHA256) $(SHA512): $(ISO)


#
# rules for generating checksum
#
target_filetype = $(subst .,,$(suffix $@))

CHECKSUMS := $(SHA1) $(SHA256) $(SHA512)
$(CHECKSUMS):
	@echo "==> $(target_filetype): Generating $@"
	$(target_filetype)sum $(basename $@) > $@.tmp \
		&& mv $@.tmp $@

sha1: $(SHA1)
sha256: $(SHA256)
sha512: $(SHA512)

#
# releases
#

release_targets += $(CHECKSUMS)
release: $(release_targets)


.PRECIOUS: $(MODLOOP_KERNELSTAMP) $(MODLOOP_DIRSTAMP) $(INITFS_DIRSTAMP) $(INITFS) $(ISO_KERNEL_STAMP)

