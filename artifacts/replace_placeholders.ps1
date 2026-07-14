#Requires -Version 7

param (
	[Parameter()][string] $ReplacementConfigPath,
	[Parameter()][string] $ArtifactInputPath,
	[Parameter()][string] $ArtifactOutputPath,
	[Parameter()][string] $ArtifactBackupPath,
	[Parameter()][string] $EnvironmentName,
	[Parameter()][switch] $Help
)

Remove-Variable * -Exclude ReplacementConfigPath, ArtifactInputPath, ArtifactOutputPath, ArtifactBackupPath, EnvironmentName, Help -ErrorAction SilentlyContinue



function Copy-Folder
{
	param (
		[Parameter()][string] $SourceFolder,
		[Parameter()][string] $TargetFolder,
		[Parameter()][string[]] $ExcludeFolders
	)

	if (-not [System.IO.Directory]::Exists($SourceFolder))
	{
		Write-Error "Source folder $SourceFolder not found"
		exit 1
	}
	if (-not [System.IO.Directory]::Exists($TargetFolder))
	{
		Write-Error "Target folder $TargetFolder not found"
		exit 1
	}
	
	# find files in all subfolders
	$SourceFiles = [System.IO.Directory]::GetFiles($SourceFolder, "*", [System.IO.SearchOption]::AllDirectories)
	foreach ($SourceFile in $SourceFiles)
	{
		# ignore if in $ExcludeFolders
		$IsExcluded = $false
		foreach ($Exclude in $ExcludeFolders)
		{
			if ($SourceFile.Contains($Exclude))
			{
				$IsExcluded = $true
				break
			}
		}
		if ($IsExcluded -eq $true)
		{
			continue
		}

		# calculate target path
		$SourceFileName = [System.IO.Path]::GetRelativePath($SourceFolder, $SourceFile)
		$TargetFilePath = [System.IO.Path]::Combine($TargetFolder, $SourceFileName)

		# create subfolder for target path
		$TargetFolderPath = [System.IO.Path]::GetDirectoryName($TargetFilePath)
		if (-not [System.IO.Directory]::Exists($TargetFolderPath))
		{
			[System.IO.Directory]::CreateDirectory($TargetFolderPath) | Out-Null
		}

		# copy the file
		[System.IO.File]::Copy($SourceFile, $TargetFilePath, $true) | Out-Null
	}
}



$ErrorActionPreference = 'stop'
$CurrentFolder = [System.IO.Directory]::GetCurrentDirectory()
$ScriptName = $MyInvocation.MyCommand.Name
$ExcludeFolders = @()



Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Running $ScriptName ..."



# Help
if ($Help.IsPresent)
{
	Write-Host
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host;
	Write-Host 'This script will replace placeholders within the deployment files in the folder'
	Write-Host 'and subfolders of the generator output with values provided by a replacement'
	Write-Host 'configuration file.'
	Write-Host 'Only placeholders in *.sql, *.txt, *.py, *.json, *.ipynb files are replaced.'
	Write-Host;
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host;
	Write-Host 'Parameters:'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ReplacementConfigPath "<string>"'
	Write-Host 'Specify the path and name for the replacement configuration file.'
	Write-Host 'If parameter is not specified, the current folder is used and a file named'
	Write-Host '"replacement_config.json" is expected.';
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ArtifactInputPath "<string>"'
	Write-Host 'Specify the path where the deployment files to modify are located.'
	Write-Host 'If parameter is not specified, the current folder is used.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ArtifactOutputPath "<string>"'
	Write-Host 'Specify the path where the deployment files should be stored after modification.'
	Write-Host 'If parameter is not specified, the current folder is used and files will be'
	Write-Host 'overwritten.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ArtifactBackupPath "<string>"'
	Write-Host 'Specify the path where the backup with the untouched original deployment files'
	Write-Host 'should be stored. For each backup a dedicated subfolder will be created.'
	Write-Host 'If parameter is not specified, no backup will be created.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-EnvironmentName "<string>"'
	Write-Host 'Specify the environment name for which the replacement configuration should be'
	Write-Host 'applied. This environement must be configured in the configuration file.'
	Write-Host 'If parameter is not specified, the first environment specified in the'
	Write-Host 'replacement configuration file is used.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-Help'
	Write-Host 'If parameter is used, this help will be displayed.'
	Write-Host;
	Write-Host '--------------------------------------------------------------------------------'
	exit
}



# ReplacementConfigPath
if (-not [String]::IsNullOrWhiteSpace($ReplacementConfigPath))
{
	$ReplacementConfigPath = [System.IO.Path]::Combine($CurrentFolder, $ReplacementConfigPath)
}
else
{
	$ReplacementConfigPath = [System.IO.Path]::Combine($CurrentFolder, 'replacement_config.json')
}
if (-not [System.IO.File]::Exists($ReplacementConfigPath))
{
	Write-Error "Replacement configuration file $ReplacementConfigPath not found"
	exit 1
}
else
{
	Write-Host "-> using replacement configuration file $ReplacementConfigPath"
}



# ArtifactInputPath
if (-not [String]::IsNullOrWhiteSpace($ArtifactInputPath))
{
	$ArtifactInputPath = [System.IO.Path]::Combine($CurrentFolder, $ArtifactInputPath)
}
else
{
	$ArtifactInputPath = $CurrentFolder
}
if (-not [System.IO.Directory]::Exists($ArtifactInputPath))
{
	Write-Error "Input folder $ArtifactInputPath not found"
	exit 1
}
else
{
	Write-Host "-> using input folder $ArtifactInputPath"
}



# ArtifactOutputPath
if (-not [String]::IsNullOrWhiteSpace($ArtifactOutputPath))
{
	$ArtifactOutputPath = [System.IO.Path]::Combine($CurrentFolder, $ArtifactOutputPath)
}
else
{
	$ArtifactOutputPath = $CurrentFolder
}
if (-not [System.IO.Directory]::Exists($ArtifactOutputPath))
{
	Write-Error "Output folder $ArtifactOutputPath not found"
	exit 1
}
else
{
	Write-Host "-> using output folder $ArtifactOutputPath"
}



# ArtifactBackupPath
$doBackup = $false
if (-not [String]::IsNullOrWhiteSpace($ArtifactBackupPath))
{
	$ArtifactBackupPath = [System.IO.Path]::Combine($CurrentFolder, $ArtifactBackupPath)

	if (-not [System.IO.Directory]::Exists($ArtifactBackupPath))
	{
		Write-Error "Backup folder $ArtifactBackupPath not found"
		exit 1
	}

	Write-Host "-> using backup folder $ArtifactBackupPath"

	if ($ArtifactInputPath -ne $ArtifactBackupPath)
	{
		$ExcludeFolders += $ArtifactBackupPath
	}
	$doBackup = $true
}
else
{
	Write-Host "-> not creating backup"
}



# EnvironmentName
$ReplacementConfigContent = Get-Content $ReplacementConfigPath | ConvertFrom-Json
$Environments = $ReplacementConfigContent.environments
$EnvironmentIndex = -1
if (-not [String]::IsNullOrWhiteSpace($EnvironmentName))
{
	$index = 0

	foreach ($Environment in $Environments)
	{
		if ($EnvironmentName -eq $Environment.name)
		{
			$EnvironmentIndex = $index;
			$EnvironmentName = $Environment.name
			break;
		}
		$index++
	}

	if ($EnvironmentIndex -eq -1)
	{
		Write-Error "Environment $EnvironmentName not found in replacement configuration file"
		exit 1
	}
}
else
{
	$EnvironmentIndex = 0
	$EnvironmentName = $Environments[$EnvironmentIndex].name
}
Write-Host "-> using environment $EnvironmentName"



# Copy files to backup folder
if ($doBackup -eq $true)
{
	Write-Host
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host

	# Create new subfolder (Format:yyyyMMddHHmmssfff)
	$ArtifactBackupPath = [System.IO.Path]::Combine($ArtifactBackupPath, (get-date -Format yyyyMMddHHmmssfff))
	New-Item $ArtifactBackupPath -ItemType Directory | out-null

	Write-Host "Copy backup files to $ArtifactBackupPath"

	# Copy all folders, subfolders and included files to backup folder
	$ExcludeFolders += $ArtifactBackupPath
	$ExcludeFoldersForBackup = $ExcludeFolders
	Copy-Folder -SourceFolder $ArtifactInputPath -TargetFolder $ArtifactBackupPath -ExcludeFolders $ExcludeFoldersForBackup
}



# Copy files to output folder
if ($ArtifactOutputPath -ne $ArtifactInputPath)
{
	Write-Host
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host
	Write-Host "Copy output files to $ArtifactOutputPath"

	# Copy all folders, subfolders and included files to output folder
	$ExcludeFoldersForOutput = $ExcludeFolders
	if ($ArtifactOutputPath -ne $ArtifactInputPath)
	{
		$ExcludeFoldersForOutput += $ArtifactOutputPath
	}
	Copy-Folder -SourceFolder $ArtifactInputPath -TargetFolder $ArtifactOutputPath -ExcludeFolders $ExcludeFoldersForOutput
}



# Process all files in output folder and subfolders
Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Processing files in $ArtifactOutputPath ..."

$ExcludeFoldersForProcessing += $ExcludeFolders
$ExcludeFoldersForProcessing += [System.IO.Path]::Combine($CurrentFolder, $ScriptName)
$ExcludeFoldersForProcessing += [System.IO.Path]::Combine($ArtifactOutputPath, $ScriptName)
$ExcludeFoldersForProcessing += $ReplacementConfigPath
$ExcludeFoldersForProcessing += [System.IO.Path]::Combine($ArtifactOutputPath, "replacement_config.json")
$ExcludeFoldersForProcessing += [System.IO.Path]::Combine($ArtifactOutputPath, "Context")

$FileCount = 0

# Loop through all relevant files
$ChildItems = [System.IO.Directory]::GetFiles($ArtifactOutputPath, "*.sql", [System.IO.SearchOption]::AllDirectories) +
	[System.IO.Directory]::GetFiles($ArtifactOutputPath, "*.txt", [System.IO.SearchOption]::AllDirectories) +
	[System.IO.Directory]::GetFiles($ArtifactOutputPath, "*.py", [System.IO.SearchOption]::AllDirectories) +
	[System.IO.Directory]::GetFiles($ArtifactOutputPath, "*.json", [System.IO.SearchOption]::AllDirectories) +
	[System.IO.Directory]::GetFiles($ArtifactOutputPath, "*.ipynb", [System.IO.SearchOption]::AllDirectories)
foreach ($Item in $ChildItems)
{
	# ignore if in $ExcludeFoldersForProcessing
	$IsExcluded = $false
	foreach ($Exclude in $ExcludeFoldersForProcessing)
	{
		if ($Item.Contains($Exclude))
		{
			$IsExcluded = $true
			break
		}
	}
	if ($IsExcluded -eq $true)
	{
		continue
	}

	Write-Host
	Write-Host "-> working on file $Item"

	$FileContent = Get-Content $Item

	# Replace placeholders in variable $FileContent with concrete values from JSON file
	foreach ($Project in $Environments[$EnvironmentIndex].projects)
	{
		$ProjectName = $Project.name
		$PreviousVariableGroup = [string]::Empty
		$IsPreviousVariableInGroupSkipped = $false
		Write-Verbose "  -> project $ProjectName"

		foreach ($Variable in $Project.variables)
		{
			$Placeholder = '{' + $Variable.name + '}'

			# split variable name into parts
			$VariableName = $Variable.name
			$VariableNameParts = $VariableName -split '#'
			if ($VariableNameParts.Length -eq 3) # three parts found?
			{
				$VariablePartProject = $VariableNameParts[0]
				$VariablePartLayer = $VariableNameParts[1]
			#	$VariablePartConfiguration = $VariableNameParts[2] #not required
			}
			else
			{
				Write-Error "Variable name $VariableName is not in the expected format 'project#layer#variable'"
				exit 1
			}
			
			# check if empty replacement variable could be skipped
			$doSkipEmptyVariable = $true
			if (($PreviousVariableGroup -ne "$VariablePartProject#$VariablePartLayer")) # current variable is first of variable group?
			{
				$PreviousVariableGroup = "$VariablePartProject#$VariablePartLayer"
				$IsPreviousVariableInGroupSkipped = $false
			}
			else
			{
				if ($IsPreviousVariableInGroupSkipped -eq $false) # previous variable was skipped?
				{
					$doSkipEmptyVariable = $false
				}
			}

			# get replacement value
			$ReplacementValue = $Variable.value

			# handle empty replacement value
			$IsPreviousVariableInGroupSkipped = $false
			if ([String]::IsNullOrWhiteSpace($ReplacementValue))
			{
				if ($doSkipEmptyVariable -eq $true) # empty variable should be skipped
				{
					$ReplacementValue = "~~~replacement_value_skipped~~~" # unconfigured values are marked and later replaced below
					$IsPreviousVariableInGroupSkipped = $true
				}
				else
				{
					$ReplacementValue = "~~~replacement_value_empty~~~" # unconfigured values are marked and later replaced below
				}
			}

			# Replace placeholder with value
			Write-Verbose "    -> search and replace $Placeholder"
			$PlaceholderEscaped = [regex]::Escape($Placeholder) # Escape special regex characters in placeholder
			$ReplacementValueEscaped = $ReplacementValue.Replace('$', '$$') # Escape only $ in replacement value since this would be used for capture groups
			$FileContent = $FileContent -replace $PlaceholderEscaped, $ReplacementValueEscaped

			# Remove empty identifier quotation
			# If a identifier part (like servername) was not configured in the replacement configuration file,
			# it should be removed from the output, together with the quotation around it.
			# For example: SQL Server uses square brackets as identifier quotation that must be removed as well.
			# If it was skipped, also the following punctuation is removed.
			# For example: If the server name is empty, a empty database and schema name can also be removed.

			$FileContent = $FileContent -replace ([regex]::Escape('[~~~replacement_value_skipped~~~].')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('"~~~replacement_value_skipped~~~".')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('`~~~replacement_value_skipped~~~`.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('''~~~replacement_value_skipped~~~''.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_skipped~~~.')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_skipped~~~')), ''
			$FileContent = $FileContent -replace ([regex]::Escape('[~~~replacement_value_empty~~~].')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('"~~~replacement_value_empty~~~".')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('`~~~replacement_value_empty~~~`.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('''~~~replacement_value_empty~~~''.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_empty~~~.')), '.'
			$FileContent = $FileContent -replace ([regex]::Escape('~~~replacement_value_empty~~~')), ''
		}
	}

	# write the processed content back to the file
	Set-Content -Path $Item -Value $FileContent
	
	$FileCount++
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished - $FileCount files processed"

# SIG # Begin signature block
# MII6ggYJKoZIhvcNAQcCoII6czCCOm8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDsHPsj7X80Xb6s
# ygyEppNHuCmIt2kb+eZO4wwOT+NqSqCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
# lUgTecgRwIeZMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDA0MTYxODM2MTZaFw00NTA0MTYxODQ0NDBaMHcxCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jv
# c29mdCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALORKgeD
# Bmf9np3gx8C3pOZCBH8Ppttf+9Va10Wg+3cL8IDzpm1aTXlT2KCGhFdFIMeiVPvH
# or+Kx24186IVxC9O40qFlkkN/76Z2BT2vCcH7kKbK/ULkgbk/WkTZaiRcvKYhOuD
# PQ7k13ESSCHLDe32R0m3m/nJxxe2hE//uKya13NnSYXjhr03QNAlhtTetcJtYmrV
# qXi8LW9J+eVsFBT9FMfTZRY33stuvF4pjf1imxUs1gXmuYkyM6Nix9fWUmcIxC70
# ViueC4fM7Ke0pqrrBc0ZV6U6CwQnHJFnni1iLS8evtrAIMsEGcoz+4m+mOJyoHI1
# vnnhnINv5G0Xb5DzPQCGdTiO0OBJmrvb0/gwytVXiGhNctO/bX9x2P29Da6SZEi3
# W295JrXNm5UhhNHvDzI9e1eM80UHTHzgXhgONXaLbZ7LNnSrBfjgc10yVpRnlyUK
# xjU9lJfnwUSLgP3B+PR0GeUw9gb7IVc+BhyLaxWGJ0l7gpPKWeh1R+g/OPTHU3mg
# trTiXFHvvV84wRPmeAyVWi7FQFkozA8kwOy6CXcjmTimthzax7ogttc32H83rwjj
# O3HbbnMbfZlysOSGM1l0tRYAe1BtxoYT2v3EOYI9JACaYNq6lMAFUSw0rFCZE4e7
# swWAsk0wAly4JoNdtGNz764jlU9gKL431VulAgMBAAGjVDBSMA4GA1UdDwEB/wQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTIftJqhSobyhmYBAcnz1AQ
# T2ioojAQBgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAr2rd5hnn
# LZRDGU7L6VCVZKUDkQKL4jaAOxWiUsIWGbZqWl10QzD0m/9gdAmxIR6QFm3FJI9c
# Zohj9E/MffISTEAQiwGf2qnIrvKVG8+dBetJPnSgaFvlVixlHIJ+U9pW2UYXeZJF
# xBA2CFIpF8svpvJ+1Gkkih6PsHMNzBxKq7Kq7aeRYwFkIqgyuH4yKLNncy2RtNwx
# AQv3Rwqm8ddK7VZgxCwIo3tAsLx0J1KH1r6I3TeKiW5niB31yV2g/rarOoDXGpc8
# FzYiQR6sTdWD5jw4vU8w6VSp07YEwzJ2YbuwGMUrGLPAgNW3lbBeUU0i/OxYqujY
# lLSlLu2S3ucYfCFX3VVj979tzR/SpncocMfiWzpbCNJbTsgAlrPhgzavhgplXHT2
# 6ux6anSg8Evu75SjrFDyh+3XOjCDyft9V77l4/hByuVkrrOj7FjshZrM77nq81YY
# uVxzmq/FdxeDWds3GhhyVKVB0rYjdaNDmuV3fJZ5t0GNv+zcgKCf0Xd1WF81E+Al
# GmcLfc4l+gcK5GEh2NQc5QfGNpn0ltDGFf5Ozdeui53bFv0ExpK91IjmqaOqu/dk
# ODtfzAzQNb50GQOmxapMomE2gj4d8yu8l13bS3g7LfU772Aj6PXsCyM2la+YZr9T
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAXBEoxI
# sBrXUM//AAAABcESMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjUxMDEwMDkwNTI5WhcNMjUxMDEz
# MDkwNTI5WjBnMQswCQYDVQQGEwJDSDEZMBcGA1UECBMQQmFzZWwtTGFuZHNjaGFm
# dDERMA8GA1UEBxMIUHJhdHRlbG4xFDASBgNVBAoTC2JpR0VOSVVTIEFHMRQwEgYD
# VQQDEwtiaUdFTklVUyBBRzCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AK868gcIjbLn3Nc4X+cWbo9n8Eu3oDrHtIy3y7zPlwiDIc8dBUdvEXe2dm0dwH+Y
# 9jzUQLCfiY8EXIiZUovIL4bIaWJqfNYc6q3ZPo+crXZ2BX+V59rRz2K/FeIAf3U3
# HO4rirPv/flfZr5M0dWJB+Gxy6ciqg2HcMG85j/vTV+F+Fa+yjGDhURCx5ZVXALI
# uUTyc7dbU/2ckx7NV1nAIRV0J0NEmv+zNN0hyvJS21/YSZ6rHjuRvsVQ9U6FvF25
# qh/ZmqWuGd7wEZCH0MSBK90tnF0Utm12u27z6B5aYAlg2nyfj7gUcbhxweaq7yHR
# AcmkEJIc7YUXGVjJzs9sJxoLyRAM/KJCO3Ex6w25Bx9uJUr8Wjjl/eoO1luEP11E
# wZLdBVukzhbD5W3P7w3W9lptWsdeP/wafu3u9wVEGhoZPUO1y3qgG8IPerpR26We
# n1jx8b/NSG1vMi8XOY+toC7fwsNHpcLXus93LC6FeOgXPc2/OZEu4TpQ9bN8f8qT
# owIDAQABo4ICFzCCAhMwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOgYD
# VR0lBDMwMQYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGSsGAQQBgjdhgsaA6WLf0W6B
# 6fmZVeSkpA0wHQYDVR0OBBYEFOUeG0FABz8xQbC9Dq7KfWmIk5eVMB8GA1UdIwQY
# MBaAFOiDxDPX3J8MnHaaCqbU34emXljuMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBABnV1BvTn1M+q8na
# 8Ioy7CgJN9egU87eWXL/oVZzFvEjW3NQSXT+SeOMbDxQ2+Uqb7WC0ofNp9efn8cb
# 9vX7biU1rVueNNPQiLiRxwR19K9HVXLKA+pEVS6PxkqinGUDhMwjiZwL6mEZTdjd
# IKaic4zW4+jOBOgWIz2cWaCtDlzm6085f2ier3+1GO82RE9QtA4TvtjuFglXIiP4
# ljez631F2OsiFF5vqKvn9QjlkIUmN6JaS9giqxRBAc5PjsBuenV9l5y+OrwmF1xz
# JpJXoJwSHAi9sor5yozaz12d3NmD/YPhlp9RX97WtucSaCwbyjMFoFnrnur1a5Ov
# 4tgjefx7O8++1ZS3hs90XbkW3mWUnK8Z1QYmwOKK9pQ+zL6DU+lq4kGjC/D7DrPT
# 4uhqv3Cxx6RWWceanlMyWNuhluqOk1ZoBtB/DIsOmJmzBr5GUfWnNlPJcxOnBcJR
# PNlXg+6SD9oYrIxvBgbvy3y/LzxuhXCuCqfJ+k6z3CX6pD5a9NmUZZsmXx3uR1+D
# SnUobDoKhr43xbB2dF5KnBpSymYAC7fcK1yqIqNUXX9OoVUljkNHmY8xbZ3Jl2JD
# Br2A7LxAwA55sd8JP3WWQ8Svie5XSErG5tviREWS+CCFPZHJ4HqbuT80djcNM/2t
# wH5XXAj7B0GIW9lQ95IJv50wR/nyMIIG5zCCBM+gAwIBAgITMwAFwRKMSLAa11DP
# /wAAAAXBEjANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAxMB4XDTI1MTAxMDA5MDUyOVoXDTI1MTAxMzA5MDUy
# OVowZzELMAkGA1UEBhMCQ0gxGTAXBgNVBAgTEEJhc2VsLUxhbmRzY2hhZnQxETAP
# BgNVBAcTCFByYXR0ZWxuMRQwEgYDVQQKEwtiaUdFTklVUyBBRzEUMBIGA1UEAxML
# YmlHRU5JVVMgQUcwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCvOvIH
# CI2y59zXOF/nFm6PZ/BLt6A6x7SMt8u8z5cIgyHPHQVHbxF3tnZtHcB/mPY81ECw
# n4mPBFyImVKLyC+GyGlianzWHOqt2T6PnK12dgV/lefa0c9ivxXiAH91NxzuK4qz
# 7/35X2a+TNHViQfhscunIqoNh3DBvOY/701fhfhWvsoxg4VEQseWVVwCyLlE8nO3
# W1P9nJMezVdZwCEVdCdDRJr/szTdIcryUttf2Emeqx47kb7FUPVOhbxduaof2Zql
# rhne8BGQh9DEgSvdLZxdFLZtdrtu8+geWmAJYNp8n4+4FHG4ccHmqu8h0QHJpBCS
# HO2FFxlYyc7PbCcaC8kQDPyiQjtxMesNuQcfbiVK/Fo45f3qDtZbhD9dRMGS3QVb
# pM4Ww+Vtz+8N1vZabVrHXj/8Gn7t7vcFRBoaGT1Dtct6oBvCD3q6Udulnp9Y8fG/
# zUhtbzIvFzmPraAu38LDR6XC17rPdywuhXjoFz3NvzmRLuE6UPWzfH/Kk6MCAwEA
# AaOCAhcwggITMAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMDoGA1UdJQQz
# MDEGCisGAQQBgjdhAQAGCCsGAQUFBwMDBhkrBgEEAYI3YYLGgOli39Fugen5mVXk
# pKQNMB0GA1UdDgQWBBTlHhtBQAc/MUGwvQ6uyn1piJOXlTAfBgNVHSMEGDAWgBTo
# g8Qz19yfDJx2mgqm1N+Hpl5Y7jBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAxLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# MS5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQAZ1dQb059TPqvJ2vCKMuwo
# CTfXoFPO3lly/6FWcxbxI1tzUEl0/knjjGw8UNvlKm+1gtKHzafXn5/HG/b1+24l
# Na1bnjTT0Ii4kccEdfSvR1VyygPqRFUuj8ZKopxlA4TMI4mcC+phGU3Y3SCmonOM
# 1uPozgToFiM9nFmgrQ5c5utPOX9onq9/tRjvNkRPULQOE77Y7hYJVyIj+JY3s+t9
# RdjrIhReb6ir5/UI5ZCFJjeiWkvYIqsUQQHOT47Abnp1fZecvjq8JhdccyaSV6Cc
# EhwIvbKK+cqM2s9dndzZg/2D4ZafUV/e1rbnEmgsG8ozBaBZ657q9WuTr+LYI3n8
# ezvPvtWUt4bPdF25Ft5llJyvGdUGJsDiivaUPsy+g1PpauJBowvw+w6z0+Loar9w
# scekVlnHmp5TMljboZbqjpNWaAbQfwyLDpiZswa+RlH1pzZTyXMTpwXCUTzZV4Pu
# kg/aGKyMbwYG78t8vy88boVwrgqnyfpOs9wl+qQ+WvTZlGWbJl8d7kdfg0p1KGw6
# Coa+N8WwdnReSpwaUspmAAu33CtcqiKjVF1/TqFVJY5DR5mPMW2dyZdiQwa9gOy8
# QMAOebHfCT91lkPEr4nuV0hKxubb4kRFkvgghT2RyeB6m7k/NHY3DTP9rcB+V1wI
# +wdBiFvZUPeSCb+dMEf58jCCB1owggVCoAMCAQICEzMAAAAHN4xbodlbjNQAAAAA
# AAcwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTRaFw0yNjA0MTMx
# NzMxNTRaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0Eg
# MDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC398ADKAfFuj6PEDTi
# E0jxvP4Spta9K711GABrCMJlq7VjnghBqXkCuklaLxwiPRYD6anCLHyJNGC6r0kQ
# tm9MyjZnVToC0TVOfea+rebLBn1J7FV36s85Ov651roZWDAsDzQuFF/zYC+tLDGZ
# mkIf+VpPTx2fv4a3RxdhU0ok5GbWFKsCOMNCJnUmKr9KqIOgc3o8aZPmFcqzbYTv
# 0x4VZgHjLRSU2pbRnYs825ryTStsRF2I1L6dM//GwRJlSetubJdloe9zIQpgrzlY
# HPdKvoS3xWVt2J3+mMGlwcj4fK2hpQAYTqtJaqaHv9oRl4MNSTP24wo4ZqwiBid6
# dSTkTRvZT/9tCoO/ep2GP1QlhYAM1gL/eLeLFxbVUQtpT7BOpdPEsAV6UKL+VEdK
# NpaKkN4T9NsFvTNMKIudz2eY6Nk8qW60w2Gj3XDGjiK1wmgiTZs+i3234BX5TA1o
# NEhtwRpBoHJyX2lxjBaZ/RsnggWf8KZgxUbV6QIHEHLJE2QWQea4xctfo8xdy94T
# jqMyv2zILczwkdF11HjNWN38XEGdLkc6ujemDpK24Q+yGunsj8qTVxMbzI5aXxqp
# /o4l4BXIbiXIn1X5nEKViZpTnK+0pgqTUUsGcQF8NbD5QDNBXS9wunoBXHYVzyfS
# +mjK52vdLBmZyQm7PtH5Lv0HMwIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTog8Qz19yfDJx2mgqm1N+Hpl5Y
# 7jBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAHf+
# 60si2TAtOng1+H32+tulKwvw3A8iPb5MGdkYvcLx61MZiz4dlTE0b6s15lr5HO72
# gRwBkkOIaMRbK3Mxq8PoGKHecRYWwhbhoaHiAHif+lE955WsriLUsbuMneQ8tGE0
# 4dmItRC2asXhXojG1QWO8GeKNpn2gjGxJJA/yIcyM/3amNCscEVYcYNuSbH7I7oh
# qfdA3diZt197DNK+dCYpuSJOJsmBwnUvRNnsHCawO+b7RdGw858WCfOEtWpl0TJb
# DDXRt+U54EqqRvdJoI1BPPyeyFpRmGvFVTmo2BiNpoNBCb4/ZISkEXtGiUQLeWWV
# +4vgA4YK2g1085avH28FlNcBV1MTavQgOTz7nLWQsZMsrOY0WfqRUJzkF10zvGgN
# ZDhpSgJFdywF5GGxyWTuRVc/7MkY85fCNQlufPYq32IX/wHoUM7huUa4auiAynJe
# S7AILZnhdx/IyM8OGplgA8YZNQg0y0Vtq7lG0YbUM5YT150JqG248wOAHJ8+LG+H
# LeyfvNQeAgL9iw5MzFW4xCL9uBqZ6aj9U0pmuxlpLSfOY7EqmD2oN5+Pl8n2Agdd
# ynYXQ4dxXB7cqcRdrySrMwN+tGX/DAqs1IWfenuDRvjgB3U40OZa3rUwtC8Xngsb
# raLp9+FMJ6gVP1n2ltSjaDGXJMWDsGbR+A6WdF8YMIIHnjCCBYagAwIBAgITMwAA
# AAeHozSje6WOHAAAAAAABzANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3Nv
# ZnQgSWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5IDIwMjAwHhcNMjEwNDAxMjAwNTIwWhcNMzYwNDAxMjAxNTIwWjBjMQswCQYD
# VQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTQwMgYDVQQD
# EytNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ29kZSBTaWduaW5nIFBDQSAyMDIxMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsvDArxmIKOLdVHpMSWxpCFUJ
# tFL/ekr4weslKPdnF3cpTeuV8veqtmKVgok2rO0D05BpyvUDCg1wdsoEtuxACEGc
# gHfjPF/nZsOkg7c0mV8hpMT/GvB4uhDvWXMIeQPsDgCzUGzTvoi76YDpxDOxhgf8
# JuXWJzBDoLrmtThX01CE1TCCvH2sZD/+Hz3RDwl2MsvDSdX5rJDYVuR3bjaj2Qfz
# ZFmwfccTKqMAHlrz4B7ac8g9zyxlTpkTuJGtFnLBGasoOnn5NyYlf0xF9/bjVRo4
# Gzg2Yc7KR7yhTVNiuTGH5h4eB9ajm1OCShIyhrKqgOkc4smz6obxO+HxKeJ9bYmP
# f6KLXVNLz8UaeARo0BatvJ82sLr2gqlFBdj1sYfqOf00Qm/3B4XGFPDK/H04kteZ
# EZsBRc3VT2d/iVd7OTLpSH9yCORV3oIZQB/Qr4nD4YT/lWkhVtw2v2s0TnRJubL/
# hFMIQa86rcaGMhNsJrhysLNNMeBhiMezU1s5zpusf54qlYu2v5sZ5zL0KvBDLHtL
# 8F9gn6jOy3v7Jm0bbBHjrW5yQW7S36ALAt03QDpwW1JG1Hxu/FUXJbBO2AwwVG4F
# re+ZQ5Od8ouwt59FpBxVOBGfN4vN2m3fZx1gqn52GvaiBz6ozorgIEjn+PhUXILh
# AV5Q/ZgCJ0u2+ldFGjcCAwEAAaOCAjUwggIxMA4GA1UdDwEB/wQEAwIBhjAQBgkr
# BgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU2UEpsA8PY2zvadf1zSmepEhqMOYwVAYD
# VR0gBE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFMh+0mqF
# KhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJZGVudGl0eSUyMFZl
# cmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIw
# MjAuY3JsMIHDBggrBgEFBQcBAQSBtjCBszCBgQYIKwYBBQUHMAKGdWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwSWRlbnRp
# dHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3Jp
# dHklMjAyMDIwLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9z
# b2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQB/JSqe/tSr6t1mCttXI0y6
# XmyQ41uGWzl9xw+WYhvOL47BV09Dgfnm/tU4ieeZ7NAR5bguorTCNr58HOcA1tcs
# HQqt0wJsdClsu8bpQD9e/al+lUgTUJEV80Xhco7xdgRrehbyhUf4pkeAhBEjABvI
# UpD2LKPho5Z4DPCT5/0TlK02nlPwUbv9URREhVYCtsDM+31OFU3fDV8BmQXv5hT2
# RurVsJHZgP4y26dJDVF+3pcbtvh7R6NEDuYHYihfmE2HdQRq5jRvLE1Eb59PYwIS
# FCX2DaLZ+zpU4bX0I16ntKq4poGOFaaKtjIA1vRElItaOKcwtc04CBrXSfyL2Op6
# mvNIxTk4OaswIkTXbFL81ZKGD+24uMCwo/pLNhn7VHLfnxlMVzHQVL+bHa9KhTyz
# wdG/L6uderJQn0cGpLQMStUuNDArxW2wF16QGZ1NtBWgKA8Kqv48M8HfFqNifN6+
# zt6J0GwzvU8g0rYGgTZR8zDEIJfeZxwWDHpSxB5FJ1VVU1LIAtB7o9PXbjXzGifa
# IMYTzU4YKt4vMNwwBmetQDHhdAtTPplOXrnI9SI6HeTtjDD3iUN/7ygbahmYOHk7
# VB7fwT4ze+ErCbMh6gHV1UuXPiLciloNxH6K4aMfZN1oLVk6YFeIJEokuPgNPa6E
# nTiOL60cPqfny+Fq8UiuZzGCFzIwghcuAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwAFwRKMSLAa11DP/wAAAAXBEjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCDAiliXfEkur23iWCo7rUguZjtL
# g5sz05/tplDkg49OdTANBgkqhkiG9w0BAQEFAASCAYBPt9Bd+naQzeIjqjz3ALHt
# +R5UJgSylxTtOA0xjx6UjNn37CY2eStdxdeYr/VRqSORZy3K97eGJPR+5vglFySe
# 4kzJUbwGRVOLBp2fim6i0ytHnFAiS+uDDa9GoXRXekpFWRcyF//osYo8nzw1/Oro
# bvucOxCKfyk7RgXolXdRIgbY8+LtduGQYxqevhGCT3eeP8DRDC5G3R5Og3K3JNEO
# LM5BFR5hh+GrVtzrV315Tp+klnQ8T4mnwuUHybc7qNYrbsQORrwftXSl72rKmMbG
# oltI1MN8Em6Cr60utqVw2kdTCzb899lmoCZC+V5cwqYEuTW5aGimemxA/QclHnQd
# 8WO60MUjuqBRpmjigBgoLqtg97dzcsN0uGUKtRrOdoa49l2VIAdFCmNLL4Xl2Q5Z
# HB4WFiuxtc2mEfYT27E2hxMMNi9T//wVbXDSmNq/Ifs4OhNkmrv2kaO3dXDCCh8r
# 6soeUBMC1iVc7DoRVbnIO0nZlq4Se+izvU9u13xFPkShghSyMIIUrgYKKwYBBAGC
# NwMDATGCFJ4wghSaBgkqhkiG9w0BBwKgghSLMIIUhwIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBagYLKoZIhvcNAQkQAQSgggFZBIIBVTCCAVECAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgAhLGb8glCyH/tgFkqepyD3R+PeSWY/pDc1u6yPzx
# LtACBmjCIsoyQBgTMjAyNTEwMTAxNTM5MTIuOTY0WjAEgAIB9KCB6aSB5jCB4zEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hp
# ZWxkIFRTUyBFU046N0IxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5oIIPKTCCB4IwggVqoAMC
# AQICEzMAAAAF5c8P/2YuyYcAAAAAAAUwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/
# TWljcm9zb2Z0IElkZW50aXR5IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRl
# IEF1dGhvcml0eSAyMDIwMB4XDTIwMTExOTIwMzIzMVoXDTM1MTExOTIwNDIzMVow
# YTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIw
# MjAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCefOdSY/3gxZ8FfWO1
# BiKjHB7X55cz0RMFvWVGR3eRwV1wb3+yq0OXDEqhUhxqoNv6iYWKjkMcLhEFxvJA
# eNcLAyT+XdM5i2CgGPGcb95WJLiw7HzLiBKrxmDj1EQB/mG5eEiRBEp7dDGzxKCn
# TYocDOcRr9KxqHydajmEkzXHOeRGwU+7qt8Md5l4bVZrXAhK+WSk5CihNQsWbzT1
# nRliVDwunuLkX1hyIWXIArCfrKM3+RHh+Sq5RZ8aYyik2r8HxT+l2hmRllBvE2Wo
# k6IEaAJanHr24qoqFM9WLeBUSudz+qL51HwDYyIDPSQ3SeHtKog0ZubDk4hELQSx
# nfVYXdTGncaBnB60QrEuazvcob9n4yR65pUNBCF5qeA4QwYnilBkfnmeAjRN3LVu
# Lr0g0FXkqfYdUmj1fFFhH8k8YBozrEaXnsSL3kdTD01X+4LfIWOuFzTzuoslBrBI
# LfHNj8RfOxPgjuwNvE6YzauXi4orp4Sm6tF245DaFOSYbWFK5ZgG6cUY2/bUq3g3
# bQAqZt65KcaewEJ3ZyNEobv35Nf6xN6FrA6jF9447+NHvCjeWLCQZ3M8lgeCcnnh
# TFtyQX3XgCoc6IRXvFOcPVrr3D9RPHCMS6Ckg8wggTrtIVnY8yjbvGOUsAdZbeXU
# IQAWMs0d3cRDv09SvwVRd61evQIDAQABo4ICGzCCAhcwDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRraSg6NS9IY0DPe9ivSek+2T3b
# ITBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMA8GA1UdEwEB
# /wQFMAMBAf8wHwYDVR0jBBgwFoAUyH7SaoUqG8oZmAQHJ89QEE9oqKIwgYQGA1Ud
# HwR9MHsweaB3oHWGc2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
# L01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENl
# cnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcmwwgZQGCCsGAQUFBwEBBIGH
# MIGEMIGBBggrBgEFBQcwAoZ1aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJZGVudGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJv
# b3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIwMjAuY3J0MA0GCSqGSIb3
# DQEBDAUAA4ICAQBfiHbHfm21WhV150x4aPpO4dhEmSUVpbixNDmv6TvuIHv1xIs1
# 74bNGO/ilWMm+Jx5boAXrJxagRhHQtiFprSjMktTliL4sKZyt2i+SXncM23gRezz
# soOiBhv14YSd1Klnlkzvgs29XNjT+c8hIfPRe9rvVCMPiH7zPZcw5nNjthDQ+zD5
# 63I1nUJ6y59TbXWsuyUsqw7wXZoGzZwijWT5oc6GvD3HDokJY401uhnj3ubBhbkR
# 83RbfMvmzdp3he2bvIUztSOuFzRqrLfEvsPkVHYnvH1wtYyrt5vShiKheGpXa2AW
# psod4OJyT4/y0dggWi8g/tgbhmQlZqDUf3UqUQsZaLdIu/XSjgoZqDjamzCPJtOL
# i2hBwL+KsCh0Nbwc21f5xvPSwym0Ukr4o5sCcMUcSy6TEP7uMV8RX0eH/4JLEpGy
# ae6Ki8JYg5v4fsNGif1OXHJ2IWG+7zyjTDfkmQ1snFOTgyEX8qBpefQbF0fx6URr
# YiarjmBprwP6ZObwtZXJ23jK3Fg/9uqM3j0P01nzVygTppBabzxPAh/hHhhls6kw
# o3QLJ6No803jUsZcd4JQxiYHHc+Q/wAMcPUnYKv/q2O444LO1+n6j01z5mggCSlR
# wD9faBIySAcA9S8h22hIAcRQqIGEjolCK9F6nK9ZyX4lhthsGHumaABdWzCCB58w
# ggWHoAMCAQICEzMAAABPNLUHwSuXVPwAAAAAAE8wDQYJKoZIhvcNAQEMBQAwYTEL
# MAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
# A1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAw
# HhcNMjUwMjI3MTk0MDE5WhcNMjYwMjI2MTk0MDE5WjCB4zELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046
# N0IxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWUgU3RhbXBpbmcgQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAwmCmWsbLOhC6M+J3M2a5zVASVviz0eHoMWN9nSJIMMZE7eUVXBLho750
# BXaRbMzpkw9S7nEIIf+0tYhKlWKtYc7LTBw9545MjU8wy7D+MYaCijPU3wqFWSEY
# ORHDOZVqWnx5z9JBLOK5jgKfo+XHaOnybcQ7hw1K/Weq/Vjf4OcnPCKexj5y1ZeU
# QlrdHN2VFwPp74e4FFcFRT9SEyGk7VhRA2UWE7bYKo03KW0KhhcOmLMLU+nbV+Ty
# 45hgw7JENaAmVZwQb/wxYRtAXh0bXjZ+kUjJX56wNY8yffl0HcnBntuBsm//ojmc
# 04axiOqPM3de78WQBi4EvP5dgRej3K+2tabV/KUSXnYS7ulvxyYja7z1M+ohPSBJ
# 2r2jwvQNlPvEAszkSrebqvXu6XadryLxctreIt8DMQ97WuP+iDdIdVmhyIe9sXNG
# SN4WguzK39J0ZwzAQF7X3a+VYnU5cij/8BdBuFxb5q+DPlMzI89Z4kSePOA2tmPL
# hysQkGsdz6DVu51G8GaPzX7B4UwGS14vT8CRnNV6oIekipZDgF5icbpGdzk/xp4V
# AQPCD/Dt3uEhXBstOjUvWZGP53FWBRi9wD3EwniGrKyP4D0ii8oHdNDlHYAicNFo
# JGQ1jJqYW/wEae+mA1DzDkmLLtT5gcwrVIpKjifmNyxAaltCpSECAwEAAaOCAcsw
# ggHHMB0GA1UdDgQWBBS/otO37Pxmnnm2R0jR7odURuo3MDAfBgNVHSMEGDAWgBRr
# aSg6NS9IY0DPe9ivSek+2T3bITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBS
# U0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0w
# azBpBggrBgEFBQcwAoZdaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# ZXJ0cy9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBD
# QSUyMDIwMjAuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEw
# PwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9j
# cy9SZXBvc2l0b3J5Lmh0bTAIBgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBADaz
# NodUNiVhVdK51WV2Eb3iPz2XW3rf76Cy27kqn+0xGmIO5s/xg3l7YSXaEorO8JXo
# HyhhLpt+nQBTry4Ih9hpSGAXJzFQjBhONVLm4wTiO6bu8F+zrodhYrNMMiEgFpDE
# C5WiKrm7c9NZYdzs006V7g1itVPft98AnKxp/BvqBqX3BKltnWBawJN7jEA4a62B
# Vtvb7ywY25ygTcgjLDIAfkRt182R7rd8UA6jH5WQ93berfIxgWVRWXeQcExKR6al
# b8oaWg1iaOHcYRHWOsNODID2qz1yJSQDyFzuU21mIHHh2OkwnID9wto1s1tRKxdj
# /o9cF28cE/o1acqKEkCU6ImvXgzijlJCRCelKEcHAhyeIt9uhBWQ7jmKPyryPaem
# DKMY/WvGcluH6FCASD1Q0Bykq3jiaJqEi5E7McCiejaPhw8fqaEh6kITMVFmIX9X
# cz2pH+XHWjXHi+lCcatjUf18UalP6QKoocMR29d0EDOvmrerIo0h8ORR3+IT3Iz6
# qCsqwOvJx15Tm0Z4HEH7SDRd9dUUaaJFPJ1pQT8SNyvksCzi7d3mKwNy7VhK/D3o
# +1a6pnGksw5HhgJzM2y795gD9UB1aJtwYglsa1J/eKiVAjrANqGxLEXvOUdXIEIO
# bQJqgTPbMU0V5oEzG5F3KjBIsWLOW86SlxZ3d/FkMYID1DCCA9ACAQEweDBhMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAIT
# MwAAAE80tQfBK5dU/AAAAAAATzANBglghkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcN
# AQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDhWJqC1SOoTIp4o+59
# +QJ+lWZaRgIu4SbgKw0HbaWXbjCB3QYLKoZIhvcNAQkQAi8xgc0wgcowgccwgaAE
# IEFmK0YPkh60cq0douR9sQ12gnOMVyDQNoCykuAvguoOMHwwZaRjMGExCzAJBgNV
# BAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
# KU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAA
# TzS1B8Erl1T8AAAAAABPMCIEICHztmY0zyOFK8Gt2pfQ2t+E0cOOYLxhDASqgiPM
# MEaYMA0GCSqGSIb3DQEBCwUABIICAJ+9ogqgEe0D6BxFFLNV9/uNANbo/JdIBp9n
# 6U4SSEAmndX9epYg1o4k2Lf6vfS1zhgv31iU62+qsLixOHEZpUBqOeU0VeJlJhIZ
# 40gnrX5Vr9tUzV0LLbQfWzF26rvIIEMZ6emuX5YfPJ2gk70joODLxChUSBH3XMgf
# VD6y/5CDC8i2K22JjAk4WpmGbRCqz/HgfmX2apHDlQC6sFF5xLtPz6S4cjaz79nI
# hXc/hkhopcIb/XnnPFtUXhRBxM5LiIYRgXgQtGe9ylopDnAirA08YeVZRCpkaCkK
# U5UlX5ra/vu5lEed+xvPKkzuRlrYaYF19w2wZNm9B9ZsRZ3TNKSXf5SS5HtF1tCH
# /xmziU1LchPnvToolKHS4FUEErMZtxH/8FayFR0+3Slonq++fRlRTEBILSyTtCrq
# R8AhGJ4ARJwnVWbC6HhwHkM/wdkLM8i1fw4IBdQqTvJ7PnWc7vgva3yeUNzOF9kp
# 1M6S4JhqIzVzrBifKwpFXLBI3m7WMOdYixYU6psO3Nr2da52g3JXveP3dUlEnnZQ
# HFOMfgefeZ5QTH82MkNOohxAz76Jmr2/MXriQ5hwbfJcmtO9B3klz8GRjQONesEY
# 5Rn14DRBGn5REtQFJk774VaIpc3Hn2rqdozFDYU+p+a2N/9Jd0Oie8ZvoYoA87tD
# X+CK4FAO
# SIG # End signature block
