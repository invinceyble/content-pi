# For rpis where you need to install drivers for a USB wifi dongle
# I have the D-link DWA-182, and running this script installed it without any hassle
# http://downloads.fars-robotics.net

# Download a script
sudo wget http://downloads.fars-robotics.net/wifi-drivers/install-wifi -O /usr/bin/install-wifi
sudo chmod +x /usr/bin/install-wifi

# Run
./install-wifi
