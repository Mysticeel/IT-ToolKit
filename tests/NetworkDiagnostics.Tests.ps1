$modulePath = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"

Import-Module $modulePath -Force

Describe "NetworkDiagnostics Module" {

    Context "Module structure" {

        It "Exports Get-ITNetworkInformation" {
            Get-Command Get-ITNetworkInformation -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITInternetConnection" {
            Get-Command Test-ITInternetConnection -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITDNSResolution" {
            Get-Command Test-ITDNSResolution -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITTCPPort" {
            Get-Command Test-ITTCPPort -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Invoke-ITTraceRoute" {
            Get-Command Invoke-ITTraceRoute -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITWiFiInformation" {
            Get-Command Get-ITWiFiInformation -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }


    Context "Network information" {

        It "Returns network information" {

            $result = Get-ITNetworkInformation -IncludeVirtual

            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Returns an interface alias" {

            $result = Get-ITNetworkInformation -IncludeVirtual |
                Select-Object -First 1

            $result.InterfaceAlias |
                Should -Not -BeNullOrEmpty
        }
    }


    Context "Internet connectivity" {

        It "Returns a connectivity result" {

            $result = Test-ITInternetConnection

            $result |
                Should -Not -BeNullOrEmpty

            $result.Connected |
                Should -BeOfType [bool]
        }
    }


    Context "DNS resolution" {

        It "Successfully resolves localhost" {

            $result = Test-ITDNSResolution -Name "localhost"

            $result.Successful |
                Should -BeTrue
        }

        It "Handles an invalid DNS name" {

            $result = Test-ITDNSResolution `
                -Name "this-host-should-not-exist.invalid"

            $result.Successful |
                Should -BeFalse
        }
    }


    Context "TCP port validation" {

        It "Rejects ports greater than 65535" {

            {
                Test-ITTCPPort `
                    -ComputerName "localhost" `
                    -Port 65536
            } | Should -Throw
        }

        It "Rejects port zero" {

            {
                Test-ITTCPPort `
                    -ComputerName "localhost" `
                    -Port 0
            } | Should -Throw
        }
    }


    Context "Wi-Fi information" {

        It "Returns a Wi-Fi diagnostic object" {

            $result = Get-ITWiFiInformation

            $result |
                Should -Not -BeNullOrEmpty

            $result.Connected |
                Should -BeOfType [bool]
        }
    }
}