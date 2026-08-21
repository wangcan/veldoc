#!/bin/bash
# sync research & development project claude

targetPath='/data/docker/veldoc/docs/rd/'

case $1 in
'vitesse')
  fullPath="${targetPath}frontend/vitesse/"
  sourcePath="/data/frontapp/vitesse"
  resources=(.claude CLAUDE.md .requirements MEMORY.md README.zh-CN.md)
  ;;
*)
  echo 'error type'-
  exit 1
  ;;
esac

echo ${fullPath}
$(rm -rf ${fullPath}/)
$(mkdir ${fullPath})

for currentResource in ${resources[*]}; do
  $(\cp ${sourcePath}/${currentResource} ${fullPath}/${currentResource} -rf)
  echo "${sourcePath}/${currentResource} ${fullPath}/${currentResource}"
done
