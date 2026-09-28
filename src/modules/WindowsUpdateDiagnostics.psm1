function Get-ITWindowsUpdateStatus {
    [CmdletBinding()]
    param()

    try {

        $session = New-Object `
            -ComObject Microsoft.Update.Session

        $searcher = $session.CreateUpdateSearcher()

        $result = $searcher.Search(
            "IsInstalled=0 and Type='Software'"
        )

        $updates = foreach ($update in $result.Updates) {

            [PSCustomObject]@{
                Title        = $update.Title
                Severity     = $update.MsrcSeverity
                KB           = $update.KBArticleIDs -join ', '
                RebootNeeded = $update.RebootRequired
            }
        }

        [PSCustomObject]@{
            UpdateCount = @($updates).Count
            Updates     = @($updates)
            Error       = $null
        }
    }
    catch {

        [PSCustomObject]@{
            UpdateCount = 0
            Updates     = @()
            Error       = $_.Exception.Message
        }
    }
}


function Get-ITWindowsUpdateHistory {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 100)]
        [int]$MaxEntries = 20
    )

    try {

        $session = New-Object `
            -ComObject Microsoft.Update.Session

        $searcher = $session.CreateUpdateSearcher()

        $count = $searcher.GetTotalHistoryCount()

        if ($count -eq 0) {
            return
        }

        $entries = [math]::Min(
            $count,
            $MaxEntries
        )

        $searcher.QueryHistory(
            0,
            $entries
        ) |
            Select-Object `
                Date,
                Title,
                ResultCode,
                HResult
    }
    catch {

        Write-Error "Unable to retrieve Windows Update history: $($_.Exception.Message)"
    }
}


Export-ModuleMember -Function @(
    'Get-ITWindowsUpdateStatus',
    'Get-ITWindowsUpdateHistory'
)