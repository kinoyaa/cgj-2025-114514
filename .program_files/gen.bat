set WORKSPACE=.
set GODOT_PROJ_WORKSPACE=..\
set LUBAN_DLL=%WORKSPACE%\Luban\Luban.dll
set CONF_ROOT=%WORKSPACE%\DataTables

dotnet %LUBAN_DLL% ^
    -t all ^
    -c gdscript-json ^
    -d json  ^
    --conf %CONF_ROOT%\luban.conf ^
    -x outputCodeDir=%GODOT_PROJ_WORKSPACE%\datas\gen ^
    -x outputDataDir=%GODOT_PROJ_WORKSPACE%\datas\json ^
    -x pathValidator.rootDir=%WORKSPACE%\Projects\Csharp_Unity_bin

pause