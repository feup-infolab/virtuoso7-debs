# virtuoso7-debs
Virtuoso 7.2 Compiled as DEB Packages

## Installation script
```bash
virtuoso_user='virtuoso'
virtuoso_group='virtuoso'

echo "Installing Virtuoso 7.2.4 from .deb @feup-infolab/virtuoso7-debs."

#save current dir
setup_dir=$(pwd)

#install Virtuoso 7.2.4 from .deb

git clone https://github.com/feup-infolab/virtuoso7-debs.git virtuoso7
cd virtuoso7/debs-ubuntu-16-04
sudo dpkg -i virtuoso-opensource*.deb

#setup default configuration .ini file
sudo cp /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini.sample /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini

#create virtuoso user and give ownership
sudo useradd $virtuoso_user
sudo addgroup $virtuoso_group
sudo usermod $virtuoso_user -g $virtuoso_group
echo "${virtuoso_user}:${virtuoso_user_password}" | sudo chpasswd
sudo chown -R $virtuoso_user:$virtuoso_group /usr/local/virtuoso-opensource
```
##Install systemd (run as Service)

virtuoso_startup_item_file="/var/systemd/system/virtuoso.service"

#set virtuoso startup service
sudo rm -rf $virtuoso_startup_item_file
sudo touch $virtuoso_startup_item_file

printf "[Unit]
Description=Virtuoso Server Daemon
Author=Joao Rocha
\n
[Service]
Type=simple
Restart=on-failure
RestartSec=5s
TimeoutStartSec=infinity
RuntimeMaxSec=infinity
Environment=HOME=/root
User=${virtuoso_user}
Group=${virtuoso_group}
ExecStart=/usr/local/virtuoso-opensource/bin/virtuoso-t -f -c /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini
PIDFile=/usr/local/virtuoso-opensource/virtuoso.pid
\n
[Install]
WantedBy=multi-user.target
Alias=virtuoso.service" | sudo tee $virtuoso_startup_item_file

sudo chmod 0644 $virtuoso_startup_item_file
sudo systemctl daemon-reload
sudo systemctl enable virtuoso
sudo systemctl unmask virtuoso
sudo systemctl start virtuoso
