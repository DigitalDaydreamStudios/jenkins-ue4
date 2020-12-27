$ErrorActionPreference = "Stop"

echo "Running on $env:MACMINI..."

& {
	echo "Preparing Runner Variables..."
	
	# required runner variables
	$env:enginepath="C:\Program Files\Epic Games"
	$env:projectname="Fetchr"
	$env:engineversion="UE_4.25"
	$env:projectpath="C:\actions-runner\_work\Fetchr\Fetchr"
	$env:buildconfig="Development"
	$env:runnerid="my-runner"
	$env:branch="master"
	$env:revision=$CI_PIPELINE_ID
	$env:backup="C:\Users\John\Google Drive\Build\Fetchr_$env:revision"

	# archive directory
	$env:archivename="Fetchr"
	$env:buildlocation="$env:projectpath\Build\$env:projectname"

	echo "==============================================="
	echo "Starting build for project $env:projectname..."
	echo "Using engine version $env:engineversion..."
	echo "Using build configuration: $env:buildconfig..."
	echo "Using runner $env:runnerid for this job..."
	echo "Archive name: $env:archivename"
	echo "==============================================="
}

& get-location

& "$env:enginepath\$env:engineversion\Engine\Binaries\DotNET\UnrealBuildTool.exe" -projectfiles -project="$env:projectpath\$env:projectname.uproject" -game -rocket -progress

echo "==============================================="
echo "Compile stage..."
echo "==============================================="

& "$env:enginepath\$env:engineversion\Engine\Binaries\DotNET\UnrealBuildTool.exe" $env:projectname $env:buildconfig Win64 -project="$env:projectpath\$env:projectname.uproject" -rocket -editorrecompile -progress -noubtmakefiles -NoHotReloadFromIDE -2017

echo "==============================================="
echo "Build and Cook..."
echo "==============================================="

& "$env:enginepath\$env:engineversion\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="$env:projectpath\$env:projectname.uproject" -noP4 -platform=Win64 -clientconfig="$env:buildconfig" -cook -allmaps -build -stage -pak -archive -archivedirectory="$env:buildlocation"

echo "==============================================="
echo "Archiving the artifact..."
echo "==============================================="

& Compress-Archive -Path "$env:buildlocation" -DestinationPath "$env:projectpath/Build/$env:archivename.zip" -Force

echo "Archive created..."

& Compress-Archive -Path  "$env:buildlocation" -DestinationPath "$env:backup" -Force

echo "Copying to Dropbox..."

if(!$?) { Exit $LASTEXITCODE }
