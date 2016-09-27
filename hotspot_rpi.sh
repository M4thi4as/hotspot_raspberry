#!/bin/bash
#je sais que supprimer les fichiers de config sert à rien mais sa me destress
sudo ifconfig
echo -e "\033[31mHello\033[00m"
echo -e "
	       |     		/n
	       |     		/n
	       |     		/n
	      /*\     		/n
	     /***\    		/n
	    /*****\   		/n
	   |***\033[31mO\033[00m***|  		/n
	   |**\033[31mOOO\033[00m**|  		/n
	   |***\033[31mO\033[00m***|  		/n
	   |*******|  		/n
	   |*******|  		/n
	   |*******|  		/n
	  |*********|   	/n
	  |****|****|   	/n
	  |****|****|   	/n
	  |****|****|   	/n
	  |****|****|   	/n
	  |****|****|   	/n
	  |***/*\***|   	/n
	 |***********|  	/n
	 |***********|  	/n
	 |***********|  	/n
	 |***********|  	/n
	|**\033[31mT-------T\033[00m**| 	/n
	|**\033[31m|       |\033[00m**| 	/n
	|**\033[31m|       |\033[00m**| 	/n
	|**\033[31m|       |\033[00m**| 	/n
	|**\033[31mT-------T\033[00m**| 	/n
	|*************| 	/n
	|*************| 	/n
	\--/\-----/\--/		/n
	  /  \   /  \   	/n
	 / \033[31m**\033[00m \ / \033[31m**\033[00m \  	/n
	 |    | |    |  	/n
	 |    | |    |  	/n
	***  *****  *** 	/n
       **** ******* ****        /n
      *******************       /n
     *********************	/n"
*******************************
echo "by Jonkey Smith"
echo "install apache2 php and the hotspot"
sleep 10
echo "start"
echo -e "\033[31m*******************************\033[00m"
sudo apt-get update && sudo apt-get upgrade
echo "install python /n /n"
sudo apt-get install python3
echo "Desktop /n /n" 
cd /home/pi/Desktop/
echo "install wiringpi for the gpio /n /n" 
sudo apt-get install git-core
git clone git://git.drogon.net/wiringPi
cd wiringPi
git pull origin
cd wiringPi
./build
sudo rm /etc/network/interfaces
echo "
auto lo
iface lo inet loopback
iface eth0 inet dhcp
allow-hotplug wlan0
auto wlan0
iface wlan0 inet dhcp
wpa-ssid "SFR_EB18"
wpa-psk "ipint5groshopcycsyog" " > /etc/network/interfaces
echo "install hotspot : hostpad and dnsmasq"
sudo apt-get install hostapd
sudo apt-get install dnsmasq
echo "configuration config file"
cd ~/ && mkdir tmp && cd /tmp 
sudo wget http://thomaskowalski.net/fichiers/RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip
sudo unzip RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip
cd RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911
cd wpa_supplicant_hostapd
sudo tar -xvf wpa_supplicant_hostapd-0.8_rtw_r7475.20130812.tar.gz
cd wpa_supplicant_hostapd-0.8_rtw_r7475.20130812
cd hostapd
sudo make
sudo make install
sudo mv hostapd /usr/sbin/hostapd
sudo chown root.root /usr/sbin/hostapd
sudo chmod 755 /usr/sbin/hostapd
cd ~/ && rmdir tmp
echo "edit file configuration"
sudo rm /etc/hostapd/hostapd.conf
sudo echo "
interface=wlan0
driver=rtl871xdrv
ssid=SFR_EB01
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=mathias55
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf
sudo cat /etc/hostapd/hostapd.conf
echo "config interface"
sudo rm /etc/network/interfaces
sudo echo "
#Boucle locale :
auto lo
#Ethernet (en DHCP)
iface lo inet loopback
iface eth0 inet dhcp
#Paramètres par défaut du WiFi que l'on désactive en ajoutant des #
#allow-hotplug wlan0
#iface wlan0 inet manual
#wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
#iface default inet dhcp
#Notre configuration WiFi
auto wlan0
iface wlan0 inet static
adress 10.0.0.1
netmask 255.255.255.0" > /etc/network/interfaces
echo "configuration du hotspot"
sudo echo "interface=wlan0
dhcp-range=10.0.0.3,10.0.0.20,12h
server=8.8.8.8
server=8.8.4.4
dhcp-authoritative " >> /etc/dnsmasq.conf
echo "configuration iptable and a lot of thing"
net.ipv4.ip_forward=1
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
cd ~
echo "#!/bin/bash
sudo rm -R /home/pi/photo_demarrage
mkdir /home/pi/photo_demarrage
exit 0" > rm_doss_photo.sh
sudo bash rm_doss_photo.sh
echo "#!/bin/bash
sudo chmod 777 /var/www
sudo chmod 777 /dev/vchiq
heure=$(date +%H%M)
jour=$(date +%Y%m%d)
/opt/vc/bin/raspistill -n -o /home/pi/photo_demarrage/$heure+$jour.jpg -w 2272 -h 1704
sudo cp /etc/hostapd/hostapd.conf /etc/hostapd.conf
sudo ifconfig wlan0 10.0.0.1
sudo service dnsmasq restart
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
sudo hostapd /etc/hostapd.conf
sudo iptables -D POSTROUTING -t nat -o ppp0 -j MASQUERADE
sudo sysctl net.ipv4.ip_forward=0
sudo service dnsmasq stop
sudo service hostapd stop
sudo service dnsmasq start
sudo service hostapd start
#bash photo.sh &
exit 0 " > hotspot.sh
echo "/n /n install apache2 /n /n" 
sudo apt-get install apache2 -y
sudo chown pi: /var/www/html/index.html
wget -O verif_apache.html http://127.0.0.1
cat ./verif_apache.html
echo "sa marche ?" 
sleep 10
echo "install php5 /n /n" 
sudo apt-get install php5 libapache2-mod-php5 -y
sudo rm /var/www/html/index.html
echo "<?php phpinfo(); ?>" > /var/www/html/index.php
echo "go to the web site"
sleep 10

exit && sudo reboot
