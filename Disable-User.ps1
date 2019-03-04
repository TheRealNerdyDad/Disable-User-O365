#(Module 2.02)
Import-Module activedirectory
Import-Module MSOnline

$un = Read-Host "Who are we disabling today? (Login Credentials)" #(Module 2.03)
$man = Read-Host "Who are we forwarding mail to? (Login Credentials)" #(Module 2.04)
$auth = Read-Host "Who are you? (Login Credentials)" #(Module 2.05)

#Resets the old user's password (Module 2.06)
Set-ADAccountPassword -Identity $un -Reset -NewPassword (Read-Host -AsSecureString "Account Password")

#Connects to the Exchange box, forwards the users email account to their supervisor/manager, then disconnects from the Exchange box
$mail = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Authentication Basic -Credential $cred -AllowRedirection #(Module 2.07-Part 1)
Import-PSSession $mail -WarningAction SilentlyContinue | Out-Null #(Module 2.07-Part 2)
Set-Mailbox $un -ForwardingAddress $man -RemovePicture #Sets the forwarding address to the manager and removes their picture (Module 2.08)
Remove-PSSession -Session $mail #Disconnects from the Exchange box (Module 2.09)

#Removes License in O365
Connect-MsolService #(Module 2.10)
Set-MsolUserLicense -UserPrincipalName (-join($un,'@<MyDomain>.com')) -RemoveLicenses #(Module 2.11)

$dt = get-date #Gets Date & Time (Module 2.12)
$authn = Get-ADUser $auth -Properties DisplayName | select -ExpandProperty DisplayName #Gets the administrators name
$unn = Get-ADUser $un -Properties DisplayName | select -ExpandProperty DisplayName #Gets the disabled users name
$mann = Get-ADUser $man -Properties DisplayName | select -ExpandProperty DisplayName #Gets the managers name

$report = "Human Resources,

The user account for $unn ($un) has been disabled from the company network as of $dt. All email messages will be forwarded to $mann ($man) for now on.

Regards,

$authn ($auth)" #(Module 2.13)

Send-MailMessage -To HR@<MyDomain>.com, IT@<MyDomain>.com -Subject "Disconnected User Report" -Body $report -From IT@<MyDomain>.com -SmtpServer <YourExchangeURI> #(Module 2.14)
