# Extra packages

Here are some extra packages that you might want to install.

## GoLang

```bash
sudo add-apt-repository ppa:longsleep/golang-backports
sudo nala update && sudo nala install golang-go
```

## Vesktop
<https://github.com/Vencord/Vesktop/releases>

## Docker

### Add Docker's official GPG key

```bash
sudo nala update
sudo nala install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Add the repository to Apt sources

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo nala update
```

### Install Docker

```bash
sudo nala install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
## sudo reboot
```

## Open in `<IDE>` in Nautilus

```bash
git clone --depth=1 https://github.com/realmazharhussain/nautilus-code.git
cd nautilus-code
meson setup build
meson install -C build
```
