$modulePath = Join-Path $PSScriptRoot "..\src\Modules\StorageDiagnostics.psm1"

Import-Module $modulePath -Force

Describe "StorageDiagnostics Module" {

    Context "Module structure" {

        It "Exports Get-ITStorageHealth" {
            Get-Command Get-ITStorageHealth -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITPhysicalDiskHealth" {
            Get-Command Get-ITPhysicalDiskHealth -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Logical drive health" {

        BeforeAll {
            $drives = Get-ITStorageHealth
        }

        It "Returns at least one fixed drive" {
            $drives |
                Should -Not -BeNullOrEmpty
        }

        It "Returns valid free-space percentages" {
            foreach ($drive in $drives) {
                $drive.FreePercent |
                    Should -BeGreaterOrEqual 0

                $drive.FreePercent |
                    Should -BeLessOrEqual 100
            }
        }

        It "Uses a valid storage status" {
            foreach ($drive in $drives) {
                $drive.Status |
                    Should -BeIn @(
                        'Healthy',
                        'Warning',
                        'Critical'
                    )
            }
        }
    }

    Context "Physical disk health" {

        It "Runs without throwing" {
            {
                Get-ITPhysicalDiskHealth
            } | Should -Not -Throw
        }
    }
}