param ($branch_name)

$ErrorActionPreference = "Stop"

echo "Running on $env:MACMINI..."

& {
	echo "Preparing Runner Variables..."
	
	# required runner variables
	$env:enginepath="C:\Users\rocks\Editors" 
	$env:projectname="Fetchr"
	$env:engineversion="UE_4.25"
	$env:projectpath="C:\Users\rocks\RiderProjects\Fetchr\"
	$env:buildconfig="Development"
	$env:runnerid="my-runner"
	$env:branch="master"
	$env:revision=Get-Date -Format "yyyyMMddTHHmmssffff"
	$env:backup="C:\actions-runner\gitActionsBuild\Backup"

	# archive directory
	$env:archivename="Fetchr"
	$env:buildlocation="C:\Users\rocks\Builds\Fetchr"

	echo "==============================================="
	echo "Starting build for project $env:projectname..."
	echo "Using engine version $env:engineversion..."
	echo "Using build configuration: $env:buildconfig..."
	echo "Using runner $env:runnerid for this job..."
	echo "Archive name: $env:archivename"
	echo "$branch_name"
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

#& Compress-Archive -Path "$env:buildlocation" -DestinationPath "$env:projectpath/Build/$env:archivename.zip" -Force

& "C:\Program Files\7-Zip\7z.exe" -mx=5 a $env:backup/$env:archivename_$env:revision.zip $env:buildlocation\WindowsNoEditor

echo "Archive created... Copying to Google Drive..."

#echo "$env:backup" >> $GITHUB_PATH

#& Compress-Archive -Path  "$env:buildlocation" -DestinationPath "$env:backup/Fetchr_$env:revision.zip" -Force

#echo "Copying to Google Drive..."

if(!$?) { Exit $LASTEXITCODE }
