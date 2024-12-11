自行打包的 [dufs](https://github.com/sigoden/dufs)，供 Debian 或其他发行版上使用。

Self-packaged [dufs](https://github.com/sigoden/dufs) for use on Debian or other distro.


## Usage/用法

```sh
echo "deb [trusted=yes] https://github.com/wcbing-build/dufs-debs/releases/latest/download ./" |
    sudo tee /etc/apt/sources.list.d/dufs.list
sudo apt update
```