## BitBucket fetch project offline
```bash
git config --global credential.helper cache

git config --global credential.helper store

repo init -u http://git.kratos/scm/dlp/dlp_yocto_manifest.git -b master -m dlpoff.xml

repo sync
```
## GitHUb fetch project
```
repo init -u git@github.com:KratosGMIEyal/dlp_yocto_manifest.git -b master -m dlp.xml

repo sync
```

## Setup & build the project 
```bash
. modular-tools setup

## for PCB
. modular-tools build_image_pcb
```

## use modular tools
```bash
. modular-tools help  #view all options and work accordinglly
```

