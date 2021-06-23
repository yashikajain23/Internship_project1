sudo dd if=/dev/zero of=swapfile bs=1024 count=2000000
sudo mkswap -f  swapfile
sudo swapon swapfile
wget https://www.apachefriends.org/xampp-files/7.3.7/xampp-linux-x64-7.3.7-0-installer.run
chmod +x xampp-linux-x64-7.3.7-0-installer.run
./xampp-linux-x64-7.3.7-0-installer.run
sudo /opt/lampp/xampp start
sudo /opt/lampp/xampp status
