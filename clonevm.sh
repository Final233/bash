#!/bin/bash 

XMLFILE=/tmp/myvm.xml
IMG_DIR=/var/lib/libvirt/images
BASEVM=centos66
while [ 1 ]
do 
	read -p "Please input vm number: " VMNUM 
	if [ -z "$VMNUM" ]; then 
		echo "You can not input nothing."
		continue 
	elif [ "$VMNUM" != $(echo ${VMNUM}*1 | bc) ]; then
		echo "You MUST ipput a number."
		continue
	elif [ "$VMNUM" -lt 1 -o "$VMNUM" -gt 99 ];then
		echo "Out of range."
		continue
	else
		break
	fi
done
NEWVM=centos66node${VMNUM}
if [ -f ${IMG_DIR}/${NEWVM}.img ]; then
	echo "${NEWVM} already exists!!"
	exit 1
fi

echo -en "Creating disk image......\t\t\t"
qemu-img create -b ${IMG_DIR}/${BASEVM}.img -f qcow2 ${IMG_DIR}/${NEWVM}.img &> /dev/null
echo -e "\e[32;1m[OK]\e[0m"
virsh dumpxml centos66 >$XMLFILE
sed -i "/<name>${BASEVM}/s/${BASEVM}/${NEWVM}/" $XMLFILE
sed -i "/uuid/s/<uuid>.*</<uuid>$(uuidgen)</" $XMLFILE
sed -i "/libvirt/s/${BASEVM}/${NEWVM}/" $XMLFILE
sed -i "/mac addr/s/00'/${VMNUM}'/" $XMLFILE

echo -en "Defining New vm......\t\t\t\t"
virsh define $XMLFILE &> /dev/null
echo -e "\e[32;1m[OK]\e[0m"
