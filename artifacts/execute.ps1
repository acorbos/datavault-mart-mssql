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
	Write-Host 'This script will run the execute.sql script in the generator output on a'
	Write-Host 'specified Microsoft SQL Server instance.'
	Write-Host;
	Write-Host '--------------------------------------------------------------------------------'
	Write-Host;
	Write-Host 'Parameters:'
	Write-Host;
	Write-Host -ForegroundColor DarkGreen '-ServerName "<string>"'
	Write-Host 'Specify the server instance where the execution files should be executed.'
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
	Write-Host 'Specify the path where the execution files to execute are located.'
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

#execute
Write-Host
Write-Host "Processing execution script in $ArtifactInputPath ..."

$Scripts = [System.IO.Directory]::GetFiles($ArtifactInputPath, "execute.sql", [System.IO.SearchOption]::TopDirectoryOnly) #compile script list (using execute.sql)
if ($Scripts.Count -gt 0) #check if any script was found
{
	Invoke-Scripts $Scripts -ServerName $ServerName -UserName $UserName -Password $Password #run scripts
}
else
{
	Write-Warning "No execution script found in $ArtifactInputPath"
}

Write-Host
Write-Host '--------------------------------------------------------------------------------'
Write-Host
Write-Host "Finished"

# SIG # Begin signature block
# MII6gQYJKoZIhvcNAQcCoII6cjCCOm4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAMy0WFKoswY1tZ
# t4XaxNGeAWJzfNmK18XvIbG6xnU+C6CCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# nTiOL60cPqfny+Fq8UiuZzGCFzEwghctAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwAFwRKMSLAa11DP/wAAAAXBEjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCADU5pLEY1ofIVPZ3rZRW5WgxxE
# WOssl0RSlXS8HFSBojANBgkqhkiG9w0BAQEFAASCAYBxpW/KFTuX+BrxHnAd85YX
# 8/3Bir2PccY0dz5Q4PmIkWAGmLJh16r0986XXaCdtFG3v0XHVZ6ookVBnjDtFDnv
# 5ieLEzX28Qw4oUr28rHZ83vt9GcRf80ERn1TJcGroWJoONMoWTN66ZB98CM4AZcx
# hiWXdu1Z6rbwHGiffQ2+wLvixBYth3eIktbsb9OQl7J30lSwlySZfuhGoR11275m
# 5tJP8kq/cEAGANsq0M81xclwXvwg2kGM1qZ2UpdpWmVv1wVpfT4Q2BKPxHtItx5d
# l/eackHYWwUa2+k4WL6r4PxjZQW7F99IIOa67/MNgctxgaRJwbTMTz0TCkVysS5R
# FkwGCBuXaLuSsUcLvcbVTpZtgyukEEBqmekRzEvhMTP4Qgiv3p7iHOSI3l2V3o1P
# dxeDPZADjRNeTpGvZmdckT3ZLyfj6ItqDVuI+jj5Paeb4QiNOwlWyXD638VuPT4m
# rBBLpje4DwPVp700R6ySMcRNWF9/Le/K4S1FQez/QQ2hghSxMIIUrQYKKwYBBAGC
# NwMDATGCFJ0wghSZBgkqhkiG9w0BBwKgghSKMIIUhgIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBaQYLKoZIhvcNAQkQAQSgggFYBIIBVDCCAVACAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgG5mUxwgdYYsGJCt4TQA5EuibRSYlzM9ilRJVsYsq
# wBYCBmjCMqHbbxgSMjAyNTEwMTAxNTQwNDAuMjFaMASAAgH0oIHppIHmMIHjMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNy
# b3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGll
# bGQgVFNTIEVTTjo0NTFBLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmggg8pMIIHgjCCBWqgAwIB
# AgITMwAAAAXlzw//Zi7JhwAAAAAABTANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQG
# EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9N
# aWNyb3NvZnQgSWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUg
# QXV0aG9yaXR5IDIwMjAwHhcNMjAxMTE5MjAzMjMxWhcNMzUxMTE5MjA0MjMxWjBh
# MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
# MAYDVQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAy
# MDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ5851Jj/eDFnwV9Y7UG
# IqMcHtfnlzPREwW9ZUZHd5HBXXBvf7KrQ5cMSqFSHGqg2/qJhYqOQxwuEQXG8kB4
# 1wsDJP5d0zmLYKAY8Zxv3lYkuLDsfMuIEqvGYOPURAH+Ybl4SJEESnt0MbPEoKdN
# ihwM5xGv0rGofJ1qOYSTNcc55EbBT7uq3wx3mXhtVmtcCEr5ZKTkKKE1CxZvNPWd
# GWJUPC6e4uRfWHIhZcgCsJ+sozf5EeH5KrlFnxpjKKTavwfFP6XaGZGWUG8TZaiT
# ogRoAlqcevbiqioUz1Yt4FRK53P6ovnUfANjIgM9JDdJ4e0qiDRm5sOTiEQtBLGd
# 9Vhd1MadxoGcHrRCsS5rO9yhv2fjJHrmlQ0EIXmp4DhDBieKUGR+eZ4CNE3ctW4u
# vSDQVeSp9h1SaPV8UWEfyTxgGjOsRpeexIveR1MPTVf7gt8hY64XNPO6iyUGsEgt
# 8c2PxF87E+CO7A28TpjNq5eLiiunhKbq0XbjkNoU5JhtYUrlmAbpxRjb9tSreDdt
# ACpm3rkpxp7AQndnI0Shu/fk1/rE3oWsDqMX3jjv40e8KN5YsJBnczyWB4JyeeFM
# W3JBfdeAKhzohFe8U5w9WuvcP1E8cIxLoKSDzCCBOu0hWdjzKNu8Y5SwB1lt5dQh
# ABYyzR3dxEO/T1K/BVF3rV69AgMBAAGjggIbMIICFzAOBgNVHQ8BAf8EBAMCAYYw
# EAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFGtpKDo1L0hjQM972K9J6T7ZPdsh
# MFQGA1UdIARNMEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAww
# CgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/
# BAUwAwEB/zAfBgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0f
# BH0wezB5oHegdYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwv
# TWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2Vy
# dGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIwLmNybDCBlAYIKwYBBQUHAQEEgYcw
# gYQwgYEGCCsGAQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L2NlcnRzL01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9v
# dCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcnQwDQYJKoZIhvcN
# AQEMBQADggIBAF+Idsd+bbVaFXXnTHho+k7h2ESZJRWluLE0Oa/pO+4ge/XEizXv
# hs0Y7+KVYyb4nHlugBesnFqBGEdC2IWmtKMyS1OWIviwpnK3aL5JedwzbeBF7POy
# g6IGG/XhhJ3UqWeWTO+Czb1c2NP5zyEh89F72u9UIw+IfvM9lzDmc2O2END7MPnr
# cjWdQnrLn1Ntday7JSyrDvBdmgbNnCKNZPmhzoa8PccOiQljjTW6GePe5sGFuRHz
# dFt8y+bN2neF7Zu8hTO1I64XNGqst8S+w+RUdie8fXC1jKu3m9KGIqF4aldrYBam
# yh3g4nJPj/LR2CBaLyD+2BuGZCVmoNR/dSpRCxlot0i79dKOChmoONqbMI8m04uL
# aEHAv4qwKHQ1vBzbV/nG89LDKbRSSvijmwJwxRxLLpMQ/u4xXxFfR4f/gksSkbJp
# 7oqLwliDm/h+w0aJ/U5ccnYhYb7vPKNMN+SZDWycU5ODIRfyoGl59BsXR/HpRGti
# JquOYGmvA/pk5vC1lcnbeMrcWD/26ozePQ/TWfNXKBOmkFpvPE8CH+EeGGWzqTCj
# dAsno2jzTeNSxlx3glDGJgcdz5D/AAxw9Sdgq/+rY7jjgs7X6fqPTXPmaCAJKVHA
# P19oEjJIBwD1LyHbaEgBxFCogYSOiUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHnzCC
# BYegAwIBAgITMwAAAFQ/8gA+vqHYpgAAAAAAVDANBgkqhkiG9w0BAQwFADBhMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAe
# Fw0yNTAyMjcxOTQwMjdaFw0yNjAyMjYxOTQwMjdaMIHjMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
# ZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo0
# NTFBLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGlt
# ZSBTdGFtcGluZyBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQCu1p545cOfeooA80O0dF9t70FWvq1yjSAAnd+Tj/jA9Qu8gKUpsU0O6wB7
# AReupcZPtaQFOau1M2ljlu6xa5D1V4XfWc3AkPslyoAsGBCO3M7J6och1ea1yXjd
# JwUtdHO8ZOeITkIuyRp/DEZuY3VulO5TMSW5r6/q05Du5ajHvQ3J0Tg9PTKytN1Y
# BszZb2rjCva6aiv4Q1CR7JYIvKfVJAVHnkUmXPnPVnB8zRcQR7+4zQfWT52iKxps
# garxdd2kl0LANziyeRKwFvrT6IgIXgKULkJSh/ZcixdB6fuA3sre1fmfWvuFImDX
# zCxKpfeuARVKj4A5vYnK/KNElAIHOIrXP/l2ekJuD6LhDyulfPbqKQ0s8IZTsbXo
# atTZc0t/53KpXHbQ9a+rqiiUmMs69+M+kF/nQDkFa1viBbVSQO8SKLAulH9zE/Jj
# una9T4RkfBleDSdfwUAV4PN42HivRG8ou1JRn12hiJvp965OW9o7iAQWnXJoUJzJ
# Y3ukk8LgpJ4XhbulEP2VC2MXF9tCPUYt64pgdJ6MQ1LDNnt6DYwqowUn2buBuSkT
# kZfvLBEQqMGsGm4ESnCSiNOYBa0ldgMXNPjTxcSSXCRh01lx5nssVAB7lt0NpaEl
# X8bCLKmTBp4YkF+H/MbakdvnSbvUytZLlg0ir+wyoUjBwffCOwIDAQABo4IByzCC
# AccwHQYDVR0OBBYEFNJpNoLbs2pAEBam5oF1gG5nN13ZMB8GA1UdIwQYMBaAFGtp
# KDo1L0hjQM972K9J6T7ZPdshMGwGA1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJT
# QSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBr
# MGkGCCsGAQUFBzAChl1odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Nl
# cnRzL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENB
# JTIwMjAyMC5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDAOBgNVHQ8BAf8EBAMCB4AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/
# BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2Nz
# L1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEEAjANBgkqhkiG9w0BAQwFAAOCAgEAc9gU
# 34ZSVpUBU5qZl5iD4fQ4bCjJoBOmpiVsnONszTFxNimyrQUApHBxQqC06wTkbedq
# bB5ptCzHVKhMXzy8yID+/r7cgYtNwVJAU69H9RHIDB8M2P/Glgjv3ceQUrYqf92M
# 8Dyx3mwmqP7yBzbKcL8ZimT58+vAbJeBm8bXrPCe4SB/Zmmx1GP9oydMjBre9euA
# F2gIDIM4jvw/GUeryKabSrAHCwJVtAfheuKBTlX+RoVWLLPOoQ9kDflCtJ0z97J1
# OPq61mQJccGsNjrK1PABMm+6+lqM21cE8UTSE0i65Ypm1Pi9Y0TBX95M32v4TgKh
# BgEVuaTeFDlPlOpxTafuI6a4tYkpRpJ2t/kGRKUS7s7uX5zDVfIDVAYdDzJNKaup
# TBCoGqq5urAdkVbhvjv9ViUAHPKbfRBx/6MLmQ+muEODYValGV1qsM37kvs+qE/P
# KnFCKJvQGNFg7DIwN3OJ71C0uoPeRTUMb5yYQ4asSRFXn/OOdsBE7EZWMWBPgeuF
# D2mFgUsyQhNjnmueT0ss3gTAbbD5dYYJZqKN8iSljktxAZusKLjm4344NKMvZHmz
# 1HFM1rPue+uzRPFfwayjrpb2Vsk/qiYJkVwokAVYG/8v7mggvKXssdEELqA7CfVY
# Z0OXFZfft8q3V2IY/ZbZcnfZtU5ZuD1cAa5KDhQxggPUMIID0AIBATB4MGExCzAJ
# BgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNV
# BAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMz
# AAAAVD/yAD6+odimAAAAAABUMA0GCWCGSAFlAwQCAQUAoIIBLTAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIJYBW3wxJWAX/2f3EABG
# eMLCvjVc5lcclLFFr0VCBKthMIHdBgsqhkiG9w0BCRACLzGBzTCByjCBxzCBoAQg
# 1IGqemJZmElv1iBf/q2zYyRGTS6n3DRAqO6aEJhJsAswfDBlpGMwYTELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
# TWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAABU
# P/IAPr6h2KYAAAAAAFQwIgQgGxyJaOKr0Q2x5TpX+3MAVDNePVOBHHn4bVC3FZAF
# YnswDQYJKoZIhvcNAQELBQAEggIALiVzNVF68iQYygTqzJFVC3CJaEQp/sBLjJjp
# 7QO5r4LqGK9LdKHVast/ygKcw/nO90JfhQzdqintNtgkumY1fieEMTkESmWarTZU
# 5NebyCQ53F+eGDW+CrNBpPior2r24JcWb/dsTTy6SI1y2uA+J2CgKLWFcVEYFaUD
# /p7RHWSAMN5KELjXEcRH3l3NflsSAtC8ua9Cnaxhb6ZlCgSHorqqIQiLSOBiiz6B
# NfxY7Rtksb84HSUELWKD3YKTzQMjWXfRLr8w9FucRObNo71VVIOknmuYwTaXMoL9
# oQXDzULxeD3spaskc7njgRIFKB8p5kES3w8Q0155NQ/Q/yUBBksx3Vv09JKllwkv
# vJTdD+BIcBuWeM8lrF8DmcHVJHhIglPtl2+GdyAzvCz2ek1Gf+VH7pCMTdQBazbY
# kDxQbb+6+0Qpx4Yh/M+mSzj17uK6XvZGIXofw46OVwfqhGU0YstQfx73EnbEND64
# mRCGLNNgXGIiVsXsPodfsQx5BUkjB2iq+vzdxKCnJOLZrkeIOSF/1kEyQ1DnJ2oK
# 3zvMTHNDWKDet8nSY2ovyrrN3ZIFZhHKpy3HbDqIAZUrzqk1/Lg4rZNXwrnJTcvT
# 0Wwv6XUFeJZCxU5stI9rY/auZdvayN0TDv3r9gsY/WTxyJfb4Z2sb4G5DM1+ToCM
# 4lXoQZQ=
# SIG # End signature block
