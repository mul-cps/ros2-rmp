#!/bin/bash

# copy script to a system directory
sudo cp ps4_controller_script.sh /etc/udev/rules.d

# Set execute permissions for the script
sudo chmod +x /etc/udev/rules.d/ps4_controller_script.sh

# Create or append the udev rule
echo 'ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="Wireless Controller", RUN+="/etc/udev/rules.d/ps4_controller_script.sh"' | sudo tee /etc/udev/rules.d/99-ps4-controller.rules

# Reload udev rules
sudo udevadm control --reload-rules

# Provide user feedback
echo "Setup completed. PS4 controller udev rule installed."