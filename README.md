## Partition Info

# Boot Partitions (Both Slots)
•boot
•dtbo
•init_boot
•vendor_boot

# VBmeta Partitions (Both Slots)
•vbmeta
•vbmeta_system
•vbmeta_vendor

# Firmware Partitions (Both Slots)
•apusys
•audio_dsp
•ccu
•connsys_bt
•connsys_gnss
•connsys_wifi
•dpm
•gpueb
•gz
•lk
•logo
•mcupm
•mcf_ota
•md1img
•mvpu_algo
•pi_img
•scp
•spmfw
•sspm
•tee
•vcp


##Other Important partitions

# Device specific (can't be shared)
•nvcfg
•nvram
•nvdata
•persist

# Device lock info (contains device password/Google account & OEM unlock status)
•frp - (encrypted)

# Preloader (can't be accessible through bootloader)
•preloader
•preloader_backup

# Dynamic (Recreated after every boot)
•protect1
•protect2
•boot_para
•dram_para

# Contains device related stuff (can't be shared)
•nt_reserve1 - ( contains SKU & Colors )
•nt_uefi - (encrypted)

# Partition Table(GPT)
•pgpt
•sgpt - (backup of pgpt)

# Contains Bootloader unlock status (not recommended to flash)
•seccfg

# Contains Boot mode & info
misc - ( contains recovery bootloop info )
•efuse
•para

# Logs
•nt_kmsg
•flashinfo - ( contains last flash info )
•expdb - (contains boot error)

# it's blank ( unused )
•pstore
•otp
•proinfo
•nt_reserve2
•sec1

#Unknown
•nt_log - (encrypted)
