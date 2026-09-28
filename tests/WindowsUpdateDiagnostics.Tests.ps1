$modulePath = Join-Path $PSScriptRoot "..\src\Modules\WindowsUpdateDiagnostics.psm1"

Import-Module $modulePath -Force

Describe "WindowsUpdateDiagnostics Module" {

    Context "Module structure" {

        It "Exports Get-ITWindowsUpdateStatus" {
            Get-Command Get-ITWindowsUpdateStatus -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITWindowsUpdateHistory" {
            Get-Command Get-ITWindowsUpdateHistory -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Windows Update status" {

        It "Returns a status object" {
            $result = Get-ITWindowsUpdateStatus

            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Contains UpdateCount" {
            $result = Get-ITWindowsUpdateStatus

            $result.PSObject.Properties.Name |
                Should -Contain 'UpdateCount'
        }

        It "Contains Updates" {
            $result = Get-ITWindowsUpdateStatus

            $result.PSObject.Properties.Name |
                Should -Contain 'Updates'
        }

        It "Contains Error" {
            $result = Get-ITWindowsUpdateStatus

            $result.PSObject.Properties.Name |
                Should -Contain 'Error'
        }
    }

    Context "Windows Update history" {

        It "Accepts a custom MaxEntries value" {
            {
                Get-ITWindowsUpdateHistory -MaxEntries 5
            } | Should -Not -Throw
        }

        It "Rejects MaxEntries greater than 100" {
            {
                Get-ITWindowsUpdateHistory -MaxEntries 101
            } | Should -Throw
        }

        It "Rejects MaxEntries below 1" {
            {
                Get-ITWindowsUpdateHistory -MaxEntries 0
            } | Should -Throw
        }
    }
}