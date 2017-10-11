export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get install -y ca-certificates nginx python2.7 python-flup python-imaging python-setuptools sqlite3 sudo
apt-get install -y -q --force-yes ssl-cert wget

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt

mkdir -p /etc/service/seafile
mkdir -p /etc/service/seahub
mkdir -p /etc/service/nginx
mkdir -p /opt/seafile 
mkdir -p /opt/image

adduser --disabled-password --gecos "" seafile

chown seafile:seafile /opt/seafile
chown seafile:seafile /opt/image

cp /tmp/files/seafile.start /etc/service/seafile/run
cp /tmp/files/seahub.start /opt/image

cp /tmp/files/service-nginx.sh /etc/service/nginx/run
cp /tmp/files/seafile-nginx.conf /etc/nginx/sites-available/seafile

ln -s /etc/nginx/sites-available/seafile /etc/nginx/sites-enabled/seafile

deploy-bin() {
    filename="$1"
    dest_dir="$2"
    src_dir="/tmp/files"
    cp "${src_dir}/${filename}" "${dest_dir}/${filename}"
    chmod +x "${dest_dir}/${filename}"
}

deploy-bin-image() {
    filename="$1"
    deploy-bin "${filename}" "/opt/image"
}

deploy-bin "init_data.sh" "/etc/my_init.d"
deploy-bin-image "init_data_user.sh"
deploy-bin-image "upgrade.sh"
deploy-bin-image "upgrade_user.sh"
deploy-bin-image "find-upgrade.py"
deploy-bin-image "clean.sh"

ln -s "/etc/my_init.d/init_data.sh" "/init"
ln -s "/opt/image/upgrade.sh" "/upgrade"
ln -s "/opt/image/clean.sh" "/clean"

rm -rf "/tmp/files"

