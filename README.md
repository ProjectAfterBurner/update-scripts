# update-scripts

### Script Dependencies
- `reprepro` (see the instructions below to compile)
- `pinentry-tty`
- `gnupg`
- `wget`
- `expect`
- `jq`

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
</details>

All depends can be found indide the debian repos as of buster/bullseye. Run the following command to install the packages.
```bash
sudo apt-get update
sudo apt-get install jq expect wget apt-transport-https gnupg pinentry-tty reprepro -y
# if reprepro multiversion support needed, see the instructions above. 
# rebooting is probably a good idea, to "refresh" the system, but whether you do or don't is your choice.
```

### To test
- [ ] check if package is already up to date
- [ ] fetch latest release using github api
- [ ] check if deb file exists on the internet beforehand by using wget
- [ ] download the deb file to a temp directory
- [ ] write the package to the repository
- [ ] git push to push updated changes automatically
