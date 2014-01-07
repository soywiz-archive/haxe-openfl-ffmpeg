@echo off
pushd %~dp0
del deploy.zip 2> NUL
"%~dp0\tools\7z" a -tzip -mx=9 deploy.zip -r -x!.git -x!obj -x!libs -x!libs.src -x!project/obj -xr!*.pdb -xr!all_objs -x!tools -x!project -x!example -x!deploy.bat -x!.DS_Store -x!build*.bat -x!build*.sh
haxelib submit deploy.zip
del deploy.zip 2> NUL
popd