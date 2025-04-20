# Invoke-Brute

I wanted a quick tool that runs a brute force over azure and that's why i created this tool. It's a PowerShell-based tool designed to perform password brute-force attacks against Azure AD user accounts. It automates authentication attempts against a target user, testing common or custom password lists to identify weak credentials.

## Features
- Targets single Azure AD user accounts
- Supports custom password dictionaries
- Delay options

## Usage
```powershell
. .\Invoke-Brute.ps1
Invoke-Brute -User target@domain.com -Wordlist passwords.txt -Delay 15
```
<p><p>-</p></p>
<p align="center">
<img src="https://raw.githubusercontent.com/yanalabuseini/Invoke-Brute/refs/heads/main/image.png">
 </p>
## Contact

[@_enigma146](https://twitter.com/_enigma146) - yoabuseini@gmail.com

Project Link: [https://github.com/yanalabuseini/Invoke-Brute](https://github.com/yanalabuseini/Invoke-Brute)
