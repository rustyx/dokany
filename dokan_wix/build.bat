set PATH=%PATH%;%PROGRAMFILES(x86)%\MSBuild\14.0\Bin
set VCTargetsPath=%PROGRAMFILES%
IF %processor_architecture%==AMD64 set VCTargetsPath=%PROGRAMFILES(x86)%
set VCTargetsPath=%VCTargetsPath%\MSBuild\Microsoft.Cpp\v4.0\V140

REM set version info, edit version.txt before running the batch
if NOT exist SetAssemblyVersion\bin\Release\SetAssemblyVersion.exe (
	msbuild SetAssemblyVersion.sln /p:Configuration=Release /p:Platform="Any CPU" /t:rebuild 
)
SetAssemblyVersion\bin\Release\SetAssemblyVersion version.txt /setversion version.xml

IF EXIST C:\cygwin ( powershell -Command "(gc version.xml) -replace 'false', 'true' | sc version.xml" ) ELSE ( powershell -Command "(gc version.xml) -replace 'true', 'false' | sc version.xml" )

REM build light installer
powershell -Command "(gc version.xml) -replace 'yes', 'no' | sc version.xml"
msbuild Dokan_WiX.sln /p:Configuration=Release /p:Platform="Mixed Platforms" /t:rebuild /fileLogger
copy Bootstrapper\bin\Release\DokanSetup.exe .
msbuild Dokan_WiX.sln /p:Configuration=Debug /p:Platform="Mixed Platforms" /t:rebuild /fileLogger
copy Bootstrapper\bin\Debug\DokanSetup.exe DokanSetupDbg.exe

REM build full installer
powershell -Command "(gc version.xml) -replace 'no', 'yes' | sc version.xml"
msbuild Dokan_WiX.sln /p:Configuration=Release /p:Platform="Mixed Platforms" /t:rebuild /fileLogger
copy Bootstrapper\bin\Release\DokanSetup.exe DokanSetup_redist.exe
msbuild Dokan_WiX.sln /p:Configuration=Debug /p:Platform="Mixed Platforms" /t:rebuild /fileLogger
copy Bootstrapper\bin\Debug\DokanSetup.exe DokanSetupDbg_redist.exe

REM build archive
"C:\Program Files\7-Zip\7z.exe" a -tzip dokan.zip ../Win32 ../x64