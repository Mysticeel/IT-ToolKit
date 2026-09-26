$systemModulePath = Join-Path $PSScriptRoot "Modules\SystemInformation.psm1"
$networkModulePath = Join-Path $PSScriptRoot "Modules\NetworkDiagnostics.psm1"

Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force


function Wait-ITToolkit {
    Write-Host ""
    Read-Host "Press Enter to continue"
}


function Show-Header {
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Clear-Host

    Write-Host ""
    Write-Host "============================================"
    Write-Host "               IT-Toolkit"
    Write-Host "============================================"
    Write-Host " $Title"
    Write-Host "============================================"
    Write-Host ""
}


function Show-MainMenu {

    do {

        Show-Header -Title "Windows Support Toolkit"

        Write-Host "1. System Information"
        Write-Host "2. Network Diagnostics"
        Write-Host ""
        Write-Host "Q. Exit"
        Write-Host ""

        $selection = Read-Host "Select an option"

        switch ($selection.ToUpper()) {

            "1" {
                Show-SystemInformation
            }

            "2" {
                Show-NetworkDiagnosticsMenu
            }

            "Q" {
                return
            }

            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }

    } while ($true)
}


function Show-SystemInformation {

    Show-Header -Title "System Information"

    Write-Host "Collecting system information..."
    Write-Host ""

    Get-ITSystemInformation | Format-List

    Wait-ITToolkit
}


function Show-NetworkDiagnosticsMenu {

    do {

        Show-Header -Title "Network Diagnostics"

        Write-Host "1. Network adapters"
        Write-Host "2. Network adapters (include virtual)"
        Write-Host "3. Internet connectivity"
        Write-Host "4. DNS resolution"
        Write-Host "5. TCP port test"
        Write-Host "6. Trace route"
        Write-Host "7. Wi-Fi information"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""

        $choice = Read-Host "Select an option"

        switch ($choice.ToUpper()) {

            "1" {

                Show-Header -Title "Network Adapters"

                Write-Host "Active physical network adapters"
                Write-Host ""

                Get-ITNetworkInformation |
                    Format-List

                Wait-ITToolkit
            }

            "2" {

                Show-Header -Title "All Network Adapters"

                Write-Host "Active physical and virtual network adapters"
                Write-Host ""

                Get-ITNetworkInformation -IncludeVirtual |
                    Format-List

                Wait-ITToolkit
            }

            "3" {

                Show-Header -Title "Internet Connectivity"

                Write-Host "Testing internet connectivity..."
                Write-Host ""

                Test-ITInternetConnection |
                    Format-List

                Wait-ITToolkit
            }

            "4" {

                Show-Header -Title "DNS Resolution"

                $hostname = Read-Host "Enter hostname (default: github.com)"

                if ([string]::IsNullOrWhiteSpace($hostname)) {
                    $hostname = "github.com"
                }

                Write-Host ""
                Write-Host "Resolving $hostname..."
                Write-Host ""

                Test-ITDNSResolution -Name $hostname |
                    Format-List

                Wait-ITToolkit
            }

            "5" {

                Show-Header -Title "TCP Port Test"

                $hostname = Read-Host "Enter hostname or IP address"

                if ([string]::IsNullOrWhiteSpace($hostname)) {

                    Write-Host ""
                    Write-Host "A hostname or IP address is required."

                    Wait-ITToolkit
                    continue
                }

                $portInput = Read-Host "Enter TCP port"

                if ($portInput -notmatch '^\d+$') {

                    Write-Host ""
                    Write-Host "Invalid port number."

                    Wait-ITToolkit
                    continue
                }

                $port = [int]$portInput

                if ($port -lt 1 -or $port -gt 65535) {

                    Write-Host ""
                    Write-Host "Port must be between 1 and 65535."

                    Wait-ITToolkit
                    continue
                }

                Write-Host ""
                Write-Host "Testing $hostname on TCP port $port..."
                Write-Host ""

                Test-ITTCPPort `
                    -ComputerName $hostname `
                    -Port $port |
                    Format-List

                Wait-ITToolkit
            }

            "6" {

                Show-Header -Title "Trace Route"

                $hostname = Read-Host "Enter hostname or IP address"

                if ([string]::IsNullOrWhiteSpace($hostname)) {

                    Write-Host ""
                    Write-Host "A hostname or IP address is required."

                    Wait-ITToolkit
                    continue
                }

                Write-Host ""
                Write-Host "Tracing route to $hostname..."
                Write-Host ""

                $result = Invoke-ITTraceRoute -ComputerName $hostname

                Write-Host "Computer Name  : $($result.ComputerName)"
                Write-Host "Remote Address : $($result.RemoteAddress)"
                Write-Host "Successful     : $($result.Successful)"
                Write-Host ""

                if ($result.TraceRoute) {

                    Write-Host "Route:"
                    Write-Host ""

                    $hop = 1

                    foreach ($address in $result.TraceRoute) {
                        Write-Host ("{0,3}. {1}" -f $hop, $address)
                        $hop++
                    }
                }

                if ($result.Error) {

                    Write-Host ""
                    Write-Host "Error: $($result.Error)"
                }

                Wait-ITToolkit
            }

            "7" {

                Show-Header -Title "Wi-Fi Information"

                $wifi = Get-ITWiFiInformation

                if ($wifi.Connected) {

                    $wifi |
                        Select-Object `
                            Name,
                            Description,
                            SSID,
                            BSSID,
                            RadioType,
                            Channel,
                            Signal,
                            ReceiveRate,
                            TransmitRate |
                        Format-List
                }
                else {

                    Write-Host "No active Wi-Fi connection was detected."

                    if ($wifi.Error) {
                        Write-Host ""
                        Write-Host "Details: $($wifi.Error)"
                    }
                }

                Wait-ITToolkit
            }

            "B" {
                return
            }

            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }

    } while ($true)
}


Show-MainMenu