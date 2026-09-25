$modulePath = Join-Path $PSScriptRoot "..\src\Modules\SystemInformation.psm1"

Import-Module $modulePath -Force

Describe "Get-ITSystemInformation" {

    BeforeAll {
        $result = Get-ITSystemInformation
    }

    It "Returns an object" {
        $result | Should -Not -BeNullOrEmpty
    }

    It "Returns the computer name" {
        $result.ComputerName | Should -Not -BeNullOrEmpty
    }

    It "Returns the operating system" {
        $result.OperatingSystem | Should -Not -BeNullOrEmpty
    }

    It "Returns total memory greater than zero" {
        $result.TotalMemoryGB | Should -BeGreaterThan 0
    }

    It "Returns a system drive size greater than zero" {
        $result.DriveSizeGB | Should -BeGreaterThan 0
    }

    It "Returns a PowerShell version" {
        $result.PowerShell | Should -Not -BeNullOrEmpty
    }

    It "Returns administrator status as a boolean" {
        $result.Administrator | Should -BeOfType [bool]
    }
}