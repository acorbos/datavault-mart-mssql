#Requires -Version 7

param (
	[Parameter()][string] $ServerName,
	[Parameter()][string] $UserName,
	[Parameter()][string] $Password,
	[Parameter()][string] $ArtifactInputPath,
	[Parameter()][switch] $Help
)

Remove-Variable * -Exclude ServerName, UserName, Password, ArtifactInputPath, Help -ErrorAction SilentlyContinue



# Check if SqlCmd is installed
try
{
	$null = sqlcmd -? # trivial command to check if SqlCmd is installed
}
catch
{
	# Output an error message if the command fails
	Write-Error "SqlCmd is not installed, not recognized or the PATH environment variable is not properly configured"
	exit 1
}



Function Invoke-Scripts
{
	param (
		[Parameter(Mandatory)] [string[]] $Scripts,
		[Parameter(Mandatory)] [string] $ServerName,
		[Parameter()][string] $UserName,
		[Parameter()][string] $Password,
		[Parameter()][string] $DatabaseName,
		[Parameter()][switch] $UseAsQuery
	)

	#prepare sqlcmd arguments
	$SqlCmdArguments = New-Object -TypeName "System.Collections.ArrayList"
	$SqlCmdArguments.Clear()

	$SqlCmdArguments.AddRange(@("-S", $ServerName)) #ServerName -> [protocol:]server[\instance_name][,port]

	if ($UserName -and $Password)
	{
		$SqlCmdArguments.AddRange(@("-U", $UserName)) #UserName
		$SqlCmdArguments.AddRange(@("-P", $Password)) #Password
	}

	if ($DatabaseName)
	{
		$SqlCmdArguments.AddRange(@("-d", $DatabaseName)) #Database
	}

	$SqlCmdArguments.AddRange(@("-f", "65001")) #Codepage: unicode
	$SqlCmdArguments.Add("-r1") | Out-Null #Output: everything redirected to stderr
	$SqlCmdArguments.Add("-X1") | Out-Null #Scripting: disable advanced scripting

	if ($UseAsQuery.IsPresent)
	{
		$ScriptCount = @($Scripts).Count
		if (-not $ScriptCount -eq 1)
		{
			Write-Error "Exactly one SQL query script required with 'UseAsQuery'"
			exit 1
		}
		
		$Query = $Scripts | Select-Object -First 1
		$SqlCmdArguments.AddRange(@("-Q", $Query)) #Input: use query
	}
	else
	{
		$ScriptCount = @($Scripts).Count
		if (-not $ScriptCount -gt 0)
		{
			Write-Error "At least one SQL query file required"
			exit 1
		}

		foreach ($File in $Scripts)
		{
			$SqlCmdArguments.AddRange(@("-i", $File)) #Input: use file(s)
		}
	}

	#invoke sqlcmd call
	$SqlCmdArgumentsArray = $SqlCmdArguments.ToArray()
	Write-Verbose "sqlcmd $SqlCmdArgumentsArray"
	sqlcmd @SqlCmdArgumentsArray #execute using array splatting
}



$CurrentFolder = [System.IO.Directory]::GetCurrentDirectory()
$ScriptName = $MyInvocation.MyCommand.Name



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
	Write-Host 'This script will run the deploy.sql script in the generator output on a'
	Write-Host 'specified Microsoft SQL Server instance.'
	Write-Host;
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host;
	Write-Host 'Parameters:'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ServerName "<string>"'
	Write-Host 'Specify the server instance where the deployment files should be executed.'
	Write-Host 'If parameter is not specified, a prompt will appear.'
	Write-Host 'Format: [<protocol>:]<server name>[\<instance name>][,<port>] or'
	Write-Host '[<protocol>:]<ip adress>[\<instance name>][,<port>]'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-UserName "<string>"'
	Write-Host 'Specify the user name that will be used to connect to the server instance.'
	Write-Host 'If parameter is not specified, a prompt will appear.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-Password "<string>"'
	Write-Host 'Specify the password that will be used to connect to the server instance.'
	Write-Host 'If parameter is not specified, a prompt will appear.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ArtifactInputPath "<string>"'
	Write-Host 'Specify the path where the deployment files to execute are located.'
	Write-Host 'If parameter is not specified, the current folder is used.'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-Help'
	Write-Host 'If parameter is used, this help will be displayed.'
	Write-Host;
	Write-Host '--------------------------------------------------------------------------------'
	exit
}



# ServerName
if ($PSBoundParameters.ContainsKey('ServerName') -eq $false)
{
	$ServerName = Read-Host "Please specify the server or instance name"
}
if ([String]::IsNullOrWhiteSpace($ServerName))
{
	$ServerName = "localhost"
}
Write-Host "-> using server name $ServerName"



# UserName and Password
if ($PSBoundParameters.ContainsKey('UserName') -eq $false)
{
	$UserName = Read-Host "Please specify the user name"
}
if (-not [String]::IsNullOrWhiteSpace($UserName))
{
	
	if ($PSBoundParameters.ContainsKey('Password') -eq $false)
	{
		$Password = Read-Host "Please specify the password"
	}

	Write-Host "-> using user name $UserName and password"
}
else
{
	$UserName = ""
	$Password = ""
	Write-Host "-> using no user name and password"
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



Write-Host
Write-Host '--------------------------------------------------------------------------------'

#deploy
Write-Host
Write-Host "Processing deployment script in $ArtifactInputPath ..."

$Scripts = [System.IO.Directory]::GetFiles($ArtifactInputPath, "deploy.sql", [System.IO.SearchOption]::TopDirectoryOnly) #compile script list (using deploy.sql)
if ($Scripts.Count -gt 0) #check if any script was found
{
	Invoke-Scripts $Scripts -ServerName $ServerName -UserName $UserName -Password $Password #run scripts
}
else
{
	Write-Warning "No deployment script found in $ArtifactInputPath"
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished"

# SIG # Begin signature block
# MII6ggYJKoZIhvcNAQcCoII6czCCOm8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDzAkf2q/gNACpI
# bCh/UIH6joFpxDC7xQ0/ypNzhIHbQKCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCCDNucmeUmGBC70MO0AoIxAS5ZY
# AGJr8KJegIVIHhj+izANBgkqhkiG9w0BAQEFAASCAYCV/hRgInQIbB3pUHnt+I9d
# dOW1cxfO6OSdy5/M5bP7hpRl/CISHB0F0Qb/j7ZpHcl+GEuJtr3aEd1JLT60vDcH
# tRle/BJN4br/R058mYk0OGByev+rPbVDbfRZ4d/i8l2ea0eV7NrlIBbWaPm9xC04
# iRZB3+jq0iaH9eKXtF4AUYzMhuhjDFks36a7UEbFXBbLkntz9lsFuRFZ7YiGWjxQ
# JWpQxDlG/6ZOsygjJ/HY2z8pKWiNsYRG/zfF/szzyEA7QELoaxBaGVvLTHN+Vhx+
# 1o/qYETC/nbFYrV8FrpYXLxzUSKTMhfHP7q1UDp5mzmkYtjwsJyUYK8BIACgLhSr
# uCWmdBzcdkTtTfOkoNTmyQ352eYCaFpTW1zzoOf30JDH4kzEJXwvHVvkRwBHvdLV
# MS5i4I+xc5CHlcC8sNDwrIIKj5uBu50ocMnUspnWKQ6ED7Xh4BTme4tKeav9XtOx
# mrYv/CFvZpVAeAs/w4+O3HBcb/LIKu9ex6QQoBG6RwihghSyMIIUrgYKKwYBBAGC
# NwMDATGCFJ4wghSaBgkqhkiG9w0BBwKgghSLMIIUhwIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBagYLKoZIhvcNAQkQAQSgggFZBIIBVTCCAVECAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgYLwiJTKg+UCMmQrx8Hut+SNtuQm0eEwkWazF5qab
# 1C4CBmjCMqHZOBgTMjAyNTEwMTAxNTM3MzMuMDk1WjAEgAIB9KCB6aSB5jCB4zEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hp
# ZWxkIFRTUyBFU046NDUxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQ
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
# ggWHoAMCAQICEzMAAABUP/IAPr6h2KYAAAAAAFQwDQYJKoZIhvcNAQEMBQAwYTEL
# MAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
# A1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAw
# HhcNMjUwMjI3MTk0MDI3WhcNMjYwMjI2MTk0MDI3WjCB4zELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046
# NDUxQS0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWUgU3RhbXBpbmcgQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEArtaeeOXDn3qKAPNDtHRfbe9BVr6tco0gAJ3fk4/4wPULvIClKbFNDusA
# ewEXrqXGT7WkBTmrtTNpY5busWuQ9VeF31nNwJD7JcqALBgQjtzOyeqHIdXmtcl4
# 3ScFLXRzvGTniE5CLskafwxGbmN1bpTuUzElua+v6tOQ7uWox70NydE4PT0ysrTd
# WAbM2W9q4wr2umor+ENQkeyWCLyn1SQFR55FJlz5z1ZwfM0XEEe/uM0H1k+doisa
# bIGq8XXdpJdCwDc4snkSsBb60+iICF4ClC5CUof2XIsXQen7gN7K3tX5n1r7hSJg
# 18wsSqX3rgEVSo+AOb2JyvyjRJQCBziK1z/5dnpCbg+i4Q8rpXz26ikNLPCGU7G1
# 6GrU2XNLf+dyqVx20PWvq6oolJjLOvfjPpBf50A5BWtb4gW1UkDvEiiwLpR/cxPy
# Y7p2vU+EZHwZXg0nX8FAFeDzeNh4r0RvKLtSUZ9doYib6feuTlvaO4gEFp1yaFCc
# yWN7pJPC4KSeF4W7pRD9lQtjFxfbQj1GLeuKYHSejENSwzZ7eg2MKqMFJ9m7gbkp
# E5GX7ywREKjBrBpuBEpwkojTmAWtJXYDFzT408XEklwkYdNZceZ7LFQAe5bdDaWh
# JV/GwiypkwaeGJBfh/zG2pHb50m71MrWS5YNIq/sMqFIwcH3wjsCAwEAAaOCAcsw
# ggHHMB0GA1UdDgQWBBTSaTaC27NqQBAWpuaBdYBuZzdd2TAfBgNVHSMEGDAWgBRr
# aSg6NS9IY0DPe9ivSek+2T3bITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBS
# U0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0w
# azBpBggrBgEFBQcwAoZdaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# ZXJ0cy9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBD
# QSUyMDIwMjAuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEw
# PwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9j
# cy9SZXBvc2l0b3J5Lmh0bTAIBgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBAHPY
# FN+GUlaVAVOamZeYg+H0OGwoyaATpqYlbJzjbM0xcTYpsq0FAKRwcUKgtOsE5G3n
# amweabQsx1SoTF88vMiA/v6+3IGLTcFSQFOvR/URyAwfDNj/xpYI793HkFK2Kn/d
# jPA8sd5sJqj+8gc2ynC/GYpk+fPrwGyXgZvG16zwnuEgf2ZpsdRj/aMnTIwa3vXr
# gBdoCAyDOI78PxlHq8imm0qwBwsCVbQH4XrigU5V/kaFViyzzqEPZA35QrSdM/ey
# dTj6utZkCXHBrDY6ytTwATJvuvpajNtXBPFE0hNIuuWKZtT4vWNEwV/eTN9r+E4C
# oQYBFbmk3hQ5T5TqcU2n7iOmuLWJKUaSdrf5BkSlEu7O7l+cw1XyA1QGHQ8yTSmr
# qUwQqBqqubqwHZFW4b47/VYlABzym30Qcf+jC5kPprhDg2FWpRldarDN+5L7PqhP
# zypxQiib0BjRYOwyMDdzie9QtLqD3kU1DG+cmEOGrEkRV5/zjnbAROxGVjFgT4Hr
# hQ9phYFLMkITY55rnk9LLN4EwG2w+XWGCWaijfIkpY5LcQGbrCi45uN+ODSjL2R5
# s9RxTNaz7nvrs0TxX8Gso66W9lbJP6omCZFcKJAFWBv/L+5oILyl7LHRBC6gOwn1
# WGdDlxWX37fKt1diGP2W2XJ32bVOWbg9XAGuSg4UMYID1DCCA9ACAQEweDBhMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAIT
# MwAAAFQ/8gA+vqHYpgAAAAAAVDANBglghkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcN
# AQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCBGVD82veFaCpp2rk50
# 5kPz3RDp5pjnUJwclBIi0SrfLDCB3QYLKoZIhvcNAQkQAi8xgc0wgcowgccwgaAE
# INSBqnpiWZhJb9YgX/6ts2MkRk0up9w0QKjumhCYSbALMHwwZaRjMGExCzAJBgNV
# BAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
# KU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAA
# VD/yAD6+odimAAAAAABUMCIEIBsciWjiq9ENseU6V/tzAFQzXj1TgRx5+G1QtxWQ
# BWJ7MA0GCSqGSIb3DQEBCwUABIICAAZBok/S0ONI7LFjpoZfwfW6Aj0VqoX4Xb3T
# u0Uo9ILJBgYlns6jWcDvoMiQheemXpYenskrxqI7othE+TbP5t2LE4R+ks6+54KP
# LK98OOY4RMq8L05NFlgm/esuHfU/9pjtD3yBrJH50YMryMU+U3xriWcQdGWL67Xf
# F9FXCGkDk1S1b7V6WLmR85xFj6PZXRFJdHomqcp2sG3sMxVzoVU+aBrt5l5faRhm
# uNv5zKWC+3GBhXIkxiFmgVT3cHkvgSFvBnNRIyTYdM9GYBjAtLCIT9b7IEE1zpMH
# y6rgkQdXNTNRefrwfhIC6UsThjd0ipaiZYsc2NpcALqFD1AmiBKN+ESlWVott018
# Gns7WNCyKjIj11ZTagpgv9tSWWbsoq09y6b7zNu9larzimLZvRr5hmlqnMp7wu9o
# 5IhenvSlqIinK1JukqVA1DD8/LWreoAHQ3/w4m+lsRz+zfBS59ohBbyyrfcpdvM/
# h8Tz2qIFSiwukdTwXuAmzpGuBfkNIB/7QobXc7KUq9p5uCYwa1VKLv0S+oxdw7fN
# AtbiQ2YVBSzzu6RDI10mViP8pqfE7opN52Q6alrXGCSoizepgMPv4rcHjrvRcdFB
# wHC8ha5sO5IzsVKNPl3U0nJwXF1OFyDGaBrj8u9Vi01Iouc0MKmghx65klKBvExP
# K+JqlyuF
# SIG # End signature block
