$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName -Force

InModuleScope $ProjectName {
    Describe 'Get-ModuleScriptResourceName' {
        BeforeAll {
            $resourceName1 = 'TestResource1'
            $resourceName2 = 'TestResource2'
            $resourcesPath = Join-Path -Path $TestDrive -ChildPath 'DscResources'
            $testResourcePath1 = (Join-Path -Path $resourcesPath -ChildPath $resourceName1)
            $testResourcePath2 = (Join-Path -Path $resourcesPath -ChildPath $resourceName2)

            New-Item -Path $resourcesPath -ItemType Directory
            New-Item -Path $testResourcePath1 -ItemType Directory
            New-Item -Path $testResourcePath2 -ItemType Directory

            'resource_schema1' | Out-File -FilePath ('{0}.schema.mof' -f $testResourcePath1) -Encoding ascii
            'resource_schema2' | Out-File -FilePath ('{0}.schema.mof' -f $testResourcePath2) -Encoding ascii
        }

        Context 'When a module contains resources' {
            It 'Should return all the resource names' {
                $result = Get-ModuleScriptResourceName -ModulePath $TestDrive
                $result.Count | Should -Be 2
                $result[0] | Should -Be $resourceName1
                $result[1] | Should -Be $resourceName2
            }
        }
    }
}