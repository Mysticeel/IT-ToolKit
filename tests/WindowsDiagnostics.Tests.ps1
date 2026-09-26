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
    }
}