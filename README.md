# virtuoso7-debs
Virtuoso 7.2 Compiled as DEB Packages

## Installation script

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
