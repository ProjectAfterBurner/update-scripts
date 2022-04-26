# update-scripts

### Script Dependencies
- `reprepro` (see the instructions below to compile)
- `pinentry-tty`
- `gnupg`
- `wget`

<details>
<summary>Compiling Reprepro with Multi-Version Support</summary>
```bash
sudo apt install git dh-make dpkg-dev -y
git clone https://github.com/ionos-cloud/reprepro
cd reprepro
sudo mk-build-deps -i debian/control
dpkg-buildpackage -us -uc -nc
sudo apt install -y ../reprepro_*.deb
```

### TODO
- [ ] fetch latest release from github api
- [ ] check if deb file exists on the internet beforehand by using wget
- [ ] download the deb file to a temp directory
- [ ] write the package to the repository