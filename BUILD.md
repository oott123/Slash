# Slash 构建方法

Sorry for the inconvenience, but this file has only Chinese version now.

If you want to translate it, please add BUILD_en.md to the root folder and send a PR.

Slash 采用 electron 构建，理应全程无痛，但由于使用 node-sqlite3 的原因，导致需要编译一个模块。

## 获取 Slash 和 Electron

[Slash 源码](https://github.com/oott123/Slash/archive/master.zip) | [Electron 下载](https://github.com/atom/electron/releases)

这里用 electron-v0.30.3-win32-ia32.zip 演示。

## 安装依赖、编译 html/css/js

打开命令行，进入 Slash 源码目录。
这里假设你已经安装好了 node 和 npm。

```
npm i
npm i -g bower gulp
.\node_modules\.bin\gulp
cd browser
..\node_modules\.bin\bower install
```

## 安装 sqlite3 for electron

```
cd node_modules\sqlite3
node-gyp rebuild --target=0.30.3 --arch=ia32 --dist-url=https://atom.io/download/atom-shell --module_name=node_sqlite3 --module_path=..\lib\binding\node-v44-win32-ia32
```

## 以 debug 模式启动 Slash

```
unzip electron-v0.30.3-win32-ia32.zip
cd electron-v0.30.3-win32-ia32
electron.exe ..\Slash-master -d
```