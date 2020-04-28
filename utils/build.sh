#!/usr/bin/env bash
cd $0/../
rm -rf ./dist

plugin_name="DynaMakerIntegration"

robocopy "./src" "./dist/$plugin_name/src" //e  //xf *.qmlc *.pyc "./src/__pycache__"
robocopy "./data" "./dist/$plugin_name/data" //mir

robocopy "./" "./dist/$plugin_name" __init__.py plugin.json CHANGELOG.md README.md LICENSE

powershell Compress-Archive "./dist/$plugin_name" "./dist/$plugin_name.zip"
rm -rf "./dist/$plugin_name/"