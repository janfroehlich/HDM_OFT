echo off

set SOURCEPATH=E:\xampp\htdocs\oftp\upload_directory
set TARGETPATH=F:\usr\OFTP\002Development\MatLab\IDTProcessIn
set PROCESSORPATH=F:\usr\OFTP\002Development\MatLab
set PROCESSOROUTPATH=F:\usr\OFTP\002Development\MatLab\IDTProcess

cd %SOURCEPATH%

for /L %%i IN (1 1 500) do (

echo on

echo -new scan-------------------------
echo ----- %%i

echo off

cd %SOURCEPATH%

echo on

echo ----------------------------------
echo -gather zip files in server directory--------

echo off

for /D %%A in (*) do (

echo on

echo ----------------------------------
echo -gather directory----------------------

echo on

echo current server task file source

echo ----- "%SOURCEPATH%\%%A"

if not exist "%TARGETPATH%\%%A" (

md "%TARGETPATH%\%%A"

echo move current server task file source to matlab input dir

xcopy "%SOURCEPATH%\%%A" "%TARGETPATH%\%%A"

echo ----------------------------------
echo -invoke matlab--------------------

matlab -nodisplay -nosplash -nodesktop -r -sd "%PROCESSORPATH%" "HDM_OFT_IDT_CreateBySpectralResponse_In_ZIPorXML('%TARGETPATH%\%%A\%%A.upload.zip','%SOURCEPATH%\%%A\','%%A'); exit;" -logfile "%PROCESSOROUTPATH%\%%A_IDT_Log.txt" 


)

echo off

)


rem 1.5min by ten

ping -n 10 localhost> nul

)