# v.8 - 6/22/18 - Beginning
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$False)]
   [string]$Path,

   [Parameter(Mandatory=$False)]
   [string]$Directory,

   [Parameter(Mandatory=$False)]
   [string]$File,
	
   [Parameter(Mandatory=$False)]
   [string]$FileDest = 'C:\Backup',

   [Parameter(Mandatory=$False)]
   [bool]$Everyday
)

function Backup-Folder
{
Param(
    [Parameter(Mandatory=$True)]
    [string]$PathToBackup,

    [Parameter(Mandatory=$True)]
    [string]$FolderName,

    [Parameter(Mandatory=$False)]
    [bool]$Everyday
)
    # Backup with 7zip and add today's file to name and copy to $FileDest
    if ($everyday)
    {
        if (!(Test-Path $FileDest\$FolderName)){New-Item -ItemType Directory -Force -Path $FileDest\$FolderName}
        & 'c:\Program Files\7-Zip\7z.exe' a $FileDest\$FolderName\$FolderName-$TodaysDate.7z $PathToBackup\$FolderName -xr!Backup
    }
    else
    {& 'c:\Program Files\7-Zip\7z.exe' a $FileDest\$FolderName.7z $PathToBackup\$FolderName -xr!Backup}
}

function Backup-File
{
Param(
 [Parameter(Mandatory=$True)]
 [string]$PathToBackup,

 [Parameter(Mandatory=$True)]
 [string]$FileName
)

  $FileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension("$FileName")
  $ExtensionOnly = [System.IO.Path]::GetExtension("$FileName")
  $FileSrcBU = "$PathToBackup\$FileName"
  $FileDestBU = "$FileDest\$FileName"
	# if new month, rename 7z 
	$day = $TodaysDate[8..9] -join ''
	if ($day -eq '01')
	{
		$Yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
		$YearMonth = $Yesterday[0..6] -join ''
		Rename-Item -Path "$FileDestBU.7z" -newname "$Filename-$yearmonth.7z"
	}	

	if (Test-Path $FileSrcBU)
	{
		Copy-Item -Path $FileSrcBU -Destination $FileDest -force
		# Delete today's file if it already exist so it can be renamed
		if (Test-Path $FileDest\$FileNameOnly-$TodaysDate.$ExtensionOnly){Remove-Item $FileDest\$FileNameOnly-$TodaysDate$ExtensionOnly}
		Rename-Item -Path $FileDestBU -newname $FileDest\$FileNameOnly-$TodaysDate$ExtensionOnly
		# Run 7zip to add today's file to 7z
		& 'c:\Program Files\7-Zip\7z.exe' a "$FileDestBU.7z" $FileDest\$FileNameOnly-$TodaysDate$ExtensionOnly
	}
}	
          
$TodaysDate=Get-Date -UFormat "%Y-%m-%d"

#if Destination doesn't exist, create it
if (!(Test-Path $FileDest)){New-Item -ItemType Directory -Force -Path $FileDest}

if ($File)
{Backup-File -PathtoBackup $Path -FileName $File}

if ($Directory)
{Backup-Folder -PathtoBackup $Path -FolderName $Directory -Everyday:$Everyday}
