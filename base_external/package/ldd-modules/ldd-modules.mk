##############################################################
#
# LDD-MODULES
# Builds scull, faulty and hello kernel modules from the LDD3
# source tree (located as a submodule at base_external/package/ldd).
#
##############################################################

LDD_MODULES_VERSION = 1.0
LDD_MODULES_SITE = $(BR2_EXTERNAL_project_base_PATH)/package/ldd
LDD_MODULES_SITE_METHOD = local

# After source is copied to the build dir, create a minimal Kbuild in
# misc-modules so that only hello and faulty are compiled (other LDD3
# modules use x86-specific I/O port instructions and won't build on ARM).
define LDD_MODULES_CREATE_KBUILD
	printf 'obj-m := hello.o faulty.o\n' \
		> $(@D)/misc-modules/Kbuild
endef
LDD_MODULES_POST_EXTRACT_HOOKS += LDD_MODULES_CREATE_KBUILD

define LDD_MODULES_BUILD_CMDS
	# Build scull kernel module
	$(MAKE) -C $(LINUX_DIR) \
		M=$(@D)/scull \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		LDDINC=$(@D)/include \
		EXTRA_CFLAGS="-I$(@D)/include" \
		modules
	# Build hello and faulty kernel modules
	$(MAKE) -C $(LINUX_DIR) \
		M=$(@D)/misc-modules \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		LDDINC=$(@D)/include \
		EXTRA_CFLAGS="-I$(@D)/include" \
		modules
endef

define LDD_MODULES_INSTALL_TARGET_CMDS
	# Install .ko files under /lib/modules/<version>/ so depmod and modprobe work
	$(MAKE) -C $(LINUX_DIR) \
		M=$(@D)/scull \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		INSTALL_MOD_PATH=$(TARGET_DIR) \
		INSTALL_MOD_STRIP=1 \
		modules_install
	$(MAKE) -C $(LINUX_DIR) \
		M=$(@D)/misc-modules \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		INSTALL_MOD_PATH=$(TARGET_DIR) \
		INSTALL_MOD_STRIP=1 \
		modules_install
	# Install load/unload helper scripts used by S98lddmodules
	$(INSTALL) -m 0755 $(@D)/scull/scull_load  $(TARGET_DIR)/usr/bin/scull_load
	$(INSTALL) -m 0755 $(@D)/scull/scull_unload $(TARGET_DIR)/usr/bin/scull_unload
	$(INSTALL) -m 0755 $(@D)/misc-modules/module_load   $(TARGET_DIR)/usr/bin/module_load
	$(INSTALL) -m 0755 $(@D)/misc-modules/module_unload $(TARGET_DIR)/usr/bin/module_unload
endef

$(eval $(generic-package))
