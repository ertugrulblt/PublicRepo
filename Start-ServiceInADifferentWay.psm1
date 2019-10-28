function Check-Service
{
    Param(
        [string]$serviceName,
        [switch]$InformMe,
        [Parameter(ParameterSetName="MailEnabled")][string]$to,
        [Parameter(ParameterSetName="MailEnabled")][string]$from,
        [Parameter(ParameterSetName="MailEnabled")][string]$SmtpServer,
        [Parameter(ParameterSetName="MailEnabled")][System.ServiceModel.Description.ClientCredentials]$cred
        
        )
        $ScriptStartDate=Date
        $ReturnThis=New-Object psobject -Property @{Error="0";Value="0"}
        
        $service=Get-Service -Name $serviceName
        if ($service.Status -ne "Running")
        {
            $Result=start-ControlledService.ps1
      
        
            if ($InformMe)
            {
                $events=get-eventlog Application -after $ScriptStartDate.AddMinutes(-5) -before $ScriptStartDate.AddMinutes(1) -EntryType Error,Warning
                $TipMessage=$events | format-list TimeGenerated,Message
        
                Send-MailMessage -to $to -Body $TipMessage -from $from -SmtpServer $SmtpServer -Subject "$serviceName service is stopped on $(Hostname)" -Credential $cred
                $ReturnThis.Value="ServiceRestartedEmailSent"
            }       
            $ReturnThis.Value="ServiceRestarted"
        }  
        $ReturnThis.Value="ServiceOK"
        $ReturnThis.Error=$Result.Value
        
        $ReturnThis
}

function Set-RegistryKey
{
param(
[Parameter(Position=0,mandatory=$true)][String]$RegPath,
[Parameter(Position=0,mandatory=$true)][String]$RegProperty,
[Parameter(Position=1,mandatory=$true)][String]$RegValue,
[String]$RegKey="."
)

if (!$(Test-Path -path $RegPath\$RegKey))
{
    New-Item -Path $RegPath -Name $RegKey
}
Set-ItemProperty -Path $RegPath\$RegKey -Name $RegProperty -Value $RegValue
}

function Start-ControlledService
{
    Param([Parameter(Mandatory=$True)][String]$ServiceName)

    $ReturnThis=New-Object psobject -Property @{Error="0";Value="0"}
    
    $RegValue=Get-RegistryKey.ps1 -RegProperty Ongoing -RegPath HKLM:\SOFTWARE\ -RegKey TSE
        if ($RegValue.Value -eq "0")
        {
            Set-RegistryKey.ps1 -RegPath HKLM:\SOFTWARE\ -RegKey TSE -RegProperty OnGoing -RegValue 1
            Start-Service $service.DisplayName
            Set-RegistryKey.ps1 -RegPath HKLM:\SOFTWARE\ -RegKey TSE -RegProperty OnGoing -RegValue 0
            if ($service.Status -ne "Running")
            {
               $ReturnThis.Value="FailedToStart"
            }
        }
        else
        {
            $ReturnThis.Value="OngoingOperation"
        }
    
    $ReturnThis
}

function Get-RegistryKey
{
    param(
    [Parameter(Position=0,mandatory=$true)][String]$RegProperty,
    [Parameter(Position=0,mandatory=$true)][String]$RegPath,
    [String]$RegKey="."
    )
    
    $ReturnThis=New-Object psobject -Property @{Error="0";Value="0"}
    
    if (!$(Test-Path -path $RegPath\$RegKey))
    {
       Write-RegistryKey.ps1 -RegProperty $RegProperty -RegPath $RegPath -RegValue "0"
    }
    
    $ReturnThis.Value=(Get-ItemProperty -Path $RegPath\$RegKey\).$RegProperty
    
    if ($Null -eq $ReturnThis.Value)
    {
        Write-RegistryKey.ps1 -RegProperty $RegProperty -RegPath $RegPath -RegValue "0"
        $ReturnThis.Value="0"
    }
    
    $ReturnThis
}

