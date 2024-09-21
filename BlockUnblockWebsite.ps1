param(
    [Parameter(Mandatory=$true)]
    [string]$action
)

$scriptFolderPath = "..\websiteBlocking"
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$content = Get-Content $hostsPath | Where-Object { $_ -ne $null -and $_ -ne '' }
$websiteCSVPath = "$scriptFolderPath\websites.csv"
$websites = Import-Csv -Path $websiteCSVPath | ForEach-Object { $_.Website }

function Block-Website {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$websites,
        [Parameter(Mandatory=$true)]
        [string[]]$content
    )

    foreach ($website in $websites){
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match $website) {
                $content[$i] = $content[$i].TrimStart('#').TrimStart()
            }
        }
    }
    
    return $content
}

function Unblock-Website {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$websites,
        [Parameter(Mandatory=$true)]
        [string[]]$content
    )

    foreach ($website in $websites) {
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match "$website" -and $content[$i] -notmatch "#") {
                $content[$i] = "# " + $content[$i]
            }
        }
    }

    return $content
}

switch ($action) {
    "block" { $content = Block-Website -websites $websites -content $content }
    "unblock" { $content = Unblock-Website -websites $websites -content $content }
    default { Write-Host "Invalid action: $action. Use 'block' or 'unblock'." }
}

$content | Set-Content $hostsPath