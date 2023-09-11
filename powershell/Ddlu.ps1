Param(
    [Parameter(Mandatory = $true, HelpMessage = "Input file path")]
    [string]$InputFilePath,
    [Parameter(Mandatory = $true, HelpMessage = "Output file path")]
    [string]$OutputFilePath
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

$UTF8 = [System.Text.Encoding]::GetEncoding("utf-8")

function script:DdluMain {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Input file path")]
        [string]$InputFilePath,
        [Parameter(Mandatory = $true, HelpMessage = "Output file path")]
        [string]$OutputFilePath
    )
    
    try {
        Validate $InputFilePath $OutputFilePath
        $private:data = ReadFile $InputFilePath
        WriteFile $OutputFilePath  $private:data
    }
    catch {
        Write-Error ($_.Exception.Message + " " + $PSItem.ScriptStackTrace)
    }
}

function script:Validate {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Input file path")]
        [string]$InputFilePath,
        [Parameter(Mandatory = $true, HelpMessage = "Output file path")]
        [string]$OutputFilePath
    )

    if (![System.IO.File]::Exists($InputFilePath)) {
        Write-Error "Input file is not exists."
    }

    $private:outputDirectoryPath = Split-Path -Parent $OutputFilePath
    if (![System.IO.Directory]::Exists($private:outputDirectoryPath)) {
        Write-Error "Output directory is not exists."
    }
}

function script:ReadFile {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Input file path")]
        [string]$InputFilePath
    )

    $private:extension = [System.IO.Path]::GetExtension($InputFilePath)
    if ($private:extension -eq ".json") {
        $private:data = Get-Content $InputFilePath | ConvertFrom-Json
        return $private:data
    }
    if ($private:extension -eq ".xml") {
        $private:data = [xml](Get-Content $InputFilePath)
        $private:convedData = Convert-XmlToHashTable $private:data
        return $private:convedData
    }

    Write-Error "Reading $private:extension is not supported."
}

function script:Convert-XmlToHashTable {
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode] $XmlNode
    )

    $hashTable = [ordered] @{}

    foreach ($attribute in $XmlNode.Attributes) {
        $hashTable[$attribute.Name] = $attribute.Value
    }

    foreach ($childNode in $XmlNode.ChildNodes) {
        if ($childNode.NodeType -eq 'Element') {
            $childData = Convert-XmlToHashTable -XmlNode $childNode

            if ($childData.Count -eq 1 -and $childData.Contains('#text')) {
                $childData = $childData['#text']
            }

            if ($hashTable.Contains($childNode.Name)) {
                if ($hashTable[$childNode.Name] -isnot [Array]) {
                    $hashTable[$childNode.Name] = @($hashTable[$childNode.Name])
                }
                $hashTable[$childNode.Name] += $childData
            }
            else {
                $hashTable[$childNode.Name] = $childData
            }
        }
        elseif ($childNode.NodeType -eq 'Text') {
            $hashTable['#text'] = $childNode.Value
        }
    }

    return $hashTable
}

function script:WriteFile {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Output file path")]
        [string]$OutputFilePath,
        [Parameter(Mandatory = $true, HelpMessage = "Output data")]
        $OutputData
    )

    $private:extension = [System.IO.Path]::GetExtension($OutputFilePath)
    if ($private:extension -eq ".json") {
        $private:json = $OutputData | ConvertTo-Json -Depth 100
        $private:json | Set-Content $OutputFilePath
        return
    }
    if ($private:extension -eq ".xml") {
        $private:xml = New-Object System.Xml.XmlDocument

        if ($OutputData -is [Array]) {
            $private:parentNode = $private:xml.CreateElement("items")
            $private:xml.AppendChild($private:parentNode)
            $private:data = [ordered] @{"item" = $OutputData }
            ConvertTo-Xml -InputObject $private:data -XmlDocument $private:xml -ParentNode $private:parentNode
        }
        else {
            ConvertTo-Xml -InputObject $OutputData -XmlDocument $private:xml -ParentNode $private:xml
        }
    
        $xmlwriter = New-Object System.Xml.XmlTextWriter($OutputFilePath, $UTF8)
        $xmlwriter.Formatting = [System.Xml.Formatting]::Indented
        $xmlwriter.IndentChar = " "
        $xmlwriter.Indentation = 4
        $private:xml.Save($xmlwriter)
        $xmlwriter.Close()
        return
    }

    Write-Error "Writing $private:extension is not supported."
}

function script:ConvertTo-Xml {
    param (
        [Parameter(Mandatory = $true)]
        $InputObject,
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$XmlDocument,
        [Parameter(Mandatory = $false)]
        $ParentNode
    )

    if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
        foreach ($entry in $InputObject.GetEnumerator()) {
            ProcessEntry -Entry $entry -XmlDocument $XmlDocument -ParentNode $ParentNode
        }
    }
    else {
        foreach ($property in $InputObject.PSObject.Properties) {
            ProcessEntry -Entry $property -XmlDocument $XmlDocument -ParentNode $ParentNode
        }
    }
}

function script:ProcessEntry {
    param (
        [Parameter(Mandatory = $true)]
        $Entry,
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$XmlDocument,
        [Parameter(Mandatory = $true)]
        $ParentNode
    )

    if ($Entry.Value -is [Hashtable] -or $Entry.Value -is [PSCustomObject] -or $Entry.Value -is [System.Collections.Specialized.OrderedDictionary]) {
        $element = $XmlDocument.CreateElement($Entry.Name)
        ConvertTo-Xml -InputObject $Entry.Value -XmlDocument $XmlDocument -ParentNode $element
        $null = $ParentNode.AppendChild($element)
    }
    elseif ($Entry.Value -is [Array]) {
        foreach ($item in $Entry.Value) {
            $subElement = $XmlDocument.CreateElement($Entry.Name)
            ConvertTo-Xml -InputObject $item -XmlDocument $XmlDocument -ParentNode $subElement
            $null = $ParentNode.AppendChild($subElement)
        }
    }
    else {
        $element = $XmlDocument.CreateElement($Entry.Name)
        $element.InnerText = $Entry.Value
        $null = $ParentNode.AppendChild($element)
    }
}

If ((Resolve-Path -Path $MyInvocation.InvocationName).ProviderPath -eq $MyInvocation.MyCommand.Path) {
    DdluMain $InputFilePath $OutputFilePath
}
