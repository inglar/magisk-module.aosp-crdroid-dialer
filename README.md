# CrDroid Dialer for AOSP ROM
Install CrDroid Dialer to AOSP ROM. Works on LineageOS 19.1, PixelOS, ArrowOS.

## Build
```bash
docker build -t magisk-module.aosp-crdroid-dialer .
docker run -it --rm --privileged -v $(pwd)/share/:/srv/share/ magisk-module.aosp-crdroid-dialer [device_name] [crdroid_base_version]
```

## Update update-binary
```bash
wget -O META-INF/com/google/android/update-binary https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh
```
