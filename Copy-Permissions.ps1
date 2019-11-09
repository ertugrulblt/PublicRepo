Param
(
[String][Parameter(Mandatory=$true)]$SourcePath,
[String][Parameter(Mandatory=$true)]$TargetPath,
[Switch]$LogEnabled
)

$list=gci "$SourcePath" -recurse
foreach ($item in $list)
{
    $itemAcl=get-acl $item.PSPath 
    $AlteredItemPath=$item.PSPath.ToString() -replace "$SourcePath", "$TargetPath"
    if (Test-Path $AlteredItemPath)
    {
        Set-Acl -Path $AlteredItemPath -AclObject $itemAcl
        if ($LogEnabled)
        {
            Write-Host "$($item.PSPath.ToString()) folder permissions replicated to $AlteredItemPath" -ForegroundColor Cyan    
        }
    }else
    {
        Write-Host "$AlteredItemPath does not exist" -ForegroundColor Red
    }
}

