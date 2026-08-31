#!/bin/bash
# sync research & development project claude

targetPath='/data/docker/veldoc/docs/rd/'

case $1 in
'vitesse')
  fullPath="${targetPath}frontend/vitesse/"
  sourcePath="/data/project/frontend/vitesse"
  resources=(.claude CLAUDE.md .requirements README.zh-CN.md)
  ;;
'laravel')
  fullPath="${targetPath}backend/laravel/"
  sourcePath="/data/project/backend/ai-laravel"
  resources=(.mcp.json boost.json .claude .requirements CLAUDE.md README.md)
  ;;
'vben')
  fullPath="${targetPath}frontend/vue-vben-admin/"
  sourcePath="/data/project/frontend/vue-vben-admin"
  resources=(.mcp.json .claude .requirements CLAUDE.md README.zh-CN.md)
  ;;
'ruoyi')
  fullPath="${targetPath}backend/ruoyi-vue-pro/"
  sourcePath="/data/project/java/ruoyi-vue-pro"
  resources=(.claude .requirements CLAUDE.md README.md)
  ;;
'yudao')
  fullPath="${targetPath}frontend/yudao-ui-admin-vben/"
  sourcePath="/data/project/frontend/yudao-ui-admin-vben"
  resources=(.mcp.json .claude .requirements CLAUDE.md README.md)
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

$(rm -f ${fullPath}/.claude/settings.local.json)
