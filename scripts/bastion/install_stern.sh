# configure stern to simplify logging
wget -O /opt/stern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
chmod +x /opt/stern
ln -s /opt/stern /usr/local/bin/stern

# quick validation
stern --help

