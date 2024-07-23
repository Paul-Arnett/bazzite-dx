#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Setup kernal args and libvertd service
rpm-ostree kargs \
--append-if-missing="kvm.ignore_msrs=1" \
--append-if-missing="kvm.report_ignored_msrs=0"
sudo systemctl enable bazzite-libvirtd-setup.service \
&& echo "libvirtd will be enabled at next reboot"

# Enable VFIO
echo "Enabling VFIO..."
VIRT_TEST=$(rpm-ostree kargs)
CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
VENDOR_KARG="unset"
if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
    echo 'add_drivers+=" vfio vfio_iommu_type1 vfio-pci "' | sudo tee /etc/dracut.conf.d/vfio.conf
    rpm-ostree initramfs --enable
    if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
        VENDOR_KARG="amd_iommu=on"
    elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
        VENDOR_KARG="intel_iommu=on"  
    fi
    if [[ ${VENDOR_KARG} == "unset" ]]; then
        echo "Failed to get CPU vendor, exiting..."
        exit 1
    else
        rpm-ostree kargs \
        --append-if-missing="${VENDOR_KARG}" \
        --append-if-missing="iommu=pt" \
        --append-if-missing="rd.driver.pre=vfio_pci" \
        --append-if-missing="vfio_pci.disable_vga=1"
        echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
        echo "Please understand that since this is such a niche use case, support will be very limited!"
        echo "To add your unused/second GPU device ids to the vfio driver by running"
        echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
        echo "NOTE: Your second GPU will not be usable by the host after you do this!"
    fi
fi