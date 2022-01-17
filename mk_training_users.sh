#!/bin/bash
echo "Creating group training ..."
groupadd training
echo "Creating group fours ..."
groupadd fourjs
echo "Creating user training ..."
useradd -s /bin/bash -M -d /opt/users/training -g training -G informix,fourjs training
for no in {1..8};
do
	echo "Creating user training$no ..."
	useradd -s /bin/bash -M -d /opt/users/training$no -g training -G informix,fourjs training$no
done
echo "Done."
