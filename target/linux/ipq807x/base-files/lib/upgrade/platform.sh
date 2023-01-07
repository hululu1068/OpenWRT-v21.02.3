PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

platform_check_image() {
	return 0;
}

platform_do_upgrade() {
	case "$(board_name)" in
	dynalink,dl-wrx36)
		nand_do_upgrade "$1"
		;;
	edgecore,eap102)
		active="$(fw_printenv -n active)"
		if [ "$active" -eq "1" ]; then
			CI_UBIPART="rootfs2"
		else
			CI_UBIPART="rootfs1"
		fi
		# force altbootcmd which handles partition change in u-boot
		fw_setenv bootcount 3
		fw_setenv upgrade_available 1
		nand_do_upgrade "$1"
		;;
	edimax,cax1800)
		nand_do_upgrade "$1"
		;;
	qnap,301w)
		kernelname="0:HLOS"
		rootfsname="rootfs"
		mmc_do_upgrade "$1"
		;;
	redmi,ax6|\
	xiaomi,ax3600|\
	xiaomi,ax9000)
		# Enforce single partition.
		fw_setenv flag_boot_rootfs 0
		fw_setenv flag_last_success 0
		fw_setenv flag_boot_success 0
		fw_setenv flag_try_sys1_failed 0

		# Second partition won't work and can't be used
		# Flag is as failed by default
		fw_setenv flag_try_sys2_failed 1

		# kernel and rootfs are placed on 2 different ubi
		# First ubiformat the kernel partition than do nand upgrade
		CI_KERN_UBIPART="ubi_kernel"
		CI_ROOT_UBIPART="rootfs"
		nand_do_upgrade "$1"
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}
