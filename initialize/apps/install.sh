#!/bin/bash
bash ${DOTPATH}/initialize/apps/minimun.sh

if test -e /etc/os-release ; then
  : # do nothing
else
  bash ${DOTPATH}/initialize/apps/mac_apps.sh
fi
