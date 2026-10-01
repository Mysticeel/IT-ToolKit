$modulePath = Join-Path $PSScriptRoot "..\src\Modules\WindowsDiagnostics.psm1"
Import-Module $modulePath -Force

Describe "WindowsDiagnostics Module" {
    Context "Module structure" {
        It "Exports Get-ITPendingReboot" {
            Get-Command Get-ITPendingReboot -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Get-ITServiceHealth" {
            Get-Command Get-ITServiceHealth -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Get-ITRecentSystemErrors" {
            Get-Command Get-ITRecentSystemErrors -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Get-ITEventCorrelation" {
            Get-Command Get-ITEventCorrelation -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Get-ITServiceDependency" {
            Get-Command Get-ITServiceDependency -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Pending reboot detection" {
        It "Returns a diagnostic object" {
            $result = Get-ITPendingReboot
            $result |
                Should -Not -BeNullOrEmpty
        }
        It "Returns RebootRequired as a boolean" {
            $result = Get-ITPendingReboot
            $result.RebootRequired |
                Should -BeOfType [bool]
        }
        It "Contains a Reasons property" {
            $result = Get-ITPendingReboot
            $result.PSObject.Properties.Name |
                Should -Contain "Reasons"
        }
    }

    Context "Service health" {
        It "Runs without throwing an exception" {
            {
                Get-ITServiceHealth
            } | Should -Not -Throw
        }
    }

    Context "Recent system errors" {
        It "Runs with the default parameters" {
            {
                Get-ITRecentSystemErrors
            } | Should -Not -Throw
        }
        It "Accepts a custom hour range" {
            {
                Get-ITRecentSystemErrors -Hours 1
            } | Should -Not -Throw
        }
        It "Accepts a custom MaxEvents value" {
            {
                Get-ITRecentSystemErrors -MaxEvents 10
            } | Should -Not -Throw
        }
        It "Rejects an hour range greater than 168" {
            {
                Get-ITRecentSystemErrors -Hours 169
            } | Should -Throw
        }
        It "Rejects an hour range below 1" {
            {
                Get-ITRecentSystemErrors -Hours 0
            } | Should -Throw
        }
        It "Rejects MaxEvents greater than 500" {
            {
                Get-ITRecentSystemErrors -MaxEvents 501
            } | Should -Throw
        }
        It "Rejects MaxEvents below 1" {
            {
                Get-ITRecentSystemErrors -MaxEvents 0
            } | Should -Throw
        }
    }

    Context "Event correlation" {
        It "Runs with the default parameters" {
            {
                Get-ITEventCorrelation
            } | Should -Not -Throw
        }
        It "Accepts a custom hour range" {
            {
                Get-ITEventCorrelation -Hours 1
            } | Should -Not -Throw
        }
        It "Accepts a custom MaxEvents value" {
            {
                Get-ITEventCorrelation -MaxEvents 10
            } | Should -Not -Throw
        }
        It "Rejects an hour range greater than 168" {
            {
                Get-ITEventCorrelation -Hours 169
            } | Should -Throw
        }
        It "Rejects an hour range below 1" {
            {
                Get-ITEventCorrelation -Hours 0
            } | Should -Throw
        }
        It "Rejects MaxEvents greater than 500" {
            {
                Get-ITEventCorrelation -MaxEvents 501
            } | Should -Throw
        }
        It "Rejects MaxEvents below 1" {
            {
                Get-ITEventCorrelation -MaxEvents 0
            } | Should -Throw
        }
        It "Returns the expected properties when events are found" {
            $result = @(Get-ITEventCorrelation -Hours 24 -MaxEvents 500)

            if ($result.Count -gt 0) {
                $result[0].PSObject.Properties.Name | Should -Contain "ProviderName"
                $result[0].PSObject.Properties.Name | Should -Contain "EventId"
                $result[0].PSObject.Properties.Name | Should -Contain "Level"
                $result[0].PSObject.Properties.Name | Should -Contain "Count"
                $result[0].PSObject.Properties.Name | Should -Contain "FirstSeen"
                $result[0].PSObject.Properties.Name | Should -Contain "LastSeen"
            }
            else {
                $result.Count | Should -Be 0
            }
        }
        It "Returns a positive count for correlated events" {
            $result = @(Get-ITEventCorrelation -Hours 24 -MaxEvents 500)

            if ($result.Count -gt 0) {
                foreach ($item in $result) {
                    $item.Count |
                        Should -BeGreaterThan 0
                }
            }
            else {
                $result.Count |
                    Should -Be 0
            }
        }
        It "Returns FirstSeen before or equal to LastSeen" {
            $result = @(Get-ITEventCorrelation -Hours 24 -MaxEvents 500)

            if ($result.Count -gt 0) {
                foreach ($item in $result) {
                    $item.FirstSeen |
                        Should -BeLessOrEqual $item.LastSeen
                }
            }
            else {
                $result.Count |
                    Should -Be 0
            }
        }
    }

    Context "Service dependency analysis" {
        BeforeAll {
            $testService = Get-Service |
                Select-Object -First 1
            $serviceResult = Get-ITServiceDependency -Name $testService.Name
        }

        It "Returns a service dependency object" {
            $serviceResult |
                Should -Not -BeNullOrEmpty
        }
        It "Returns the requested service name" {
            $serviceResult.ServiceName |
                Should -Be $testService.Name
        }
        It "Returns a display name" {
            $serviceResult.DisplayName |
                Should -Not -BeNullOrEmpty
        }
        It "Returns a status" {
            $serviceResult.Status |
                Should -Not -BeNullOrEmpty
        }
        It "Returns a start type" {
            $serviceResult.StartType |
                Should -Not -BeNullOrEmpty
        }
        It "Contains DependsOn" {
            $serviceResult.PSObject.Properties.Name |
                Should -Contain "DependsOn"
        }
        It "Contains DependentServices" {
            $serviceResult.PSObject.Properties.Name |
                Should -Contain "DependentServices"
        }
        It "Contains an Error property" {
            $serviceResult.PSObject.Properties.Name |
                Should -Contain "Error"
        }
        It "Returns no error for an existing service" {
            $serviceResult.Error |
                Should -BeNullOrEmpty
        }
        It "Returns a structured error for a missing service" {
            $result = Get-ITServiceDependency -Name "DefinitelyNotARealService"

            $result |
                Should -Not -BeNullOrEmpty

            $result.Error |
                Should -Not -BeNullOrEmpty
        }
        It "Preserves the requested missing service name" {
            $result = Get-ITServiceDependency -Name "DefinitelyNotARealService"

            $result.ServiceName |
                Should -Be "DefinitelyNotARealService"
        }
        It "Rejects an empty service name" {
            {
                Get-ITServiceDependency -Name ""
            } | Should -Throw
        }
    }
}