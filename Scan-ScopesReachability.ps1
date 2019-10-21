###############Script##################

$scopes=Get-DhcpServerv4Scope
foreach ($scope in $scopes)
{
    $scopename=$scope.Name
    $scopeRouter=$scope | Get-DhcpServerv4Optionvalue -Optionid 003 -ErrorAction SilentlyContinue
    if ($scopeRouter -ne $null)
    {
        $result=Test-NetConnection $($scopeRouter.Value)

        if ($result.PingSucceeded -ne "True")
        {
            write-host $scopename -BackgroundColor Red -ForegroundColor White
        }
    }
    else
    {
        Write-Host "$scopename scopeunda scope option eksiği var" -BackgroundColor Red -ForegroundColor White
    }
} 
