#!/bin/bash


LUBAN_DLL=./Luban/Luban.dll
CONF_ROOT=./DataTables/

dotnet $LUBAN_DLL \
    -t client \
    -c gdscript-json \
    -d json \
    --conf $CONF_ROOT/luban.conf \
    -x outputCodeDir=../datas/gen/ \
    -x outputDataDir=../datas/json/