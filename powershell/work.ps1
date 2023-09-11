function ConvertTo-Xml {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$InputObject,
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlDocument]$XmlDocument,
        [Parameter(Mandatory=$false)]
        $ParentNode
    )

    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Value -is [PSCustomObject]) {
            $element = $XmlDocument.CreateElement($property.Name)
            ConvertTo-Xml -InputObject $property.Value -XmlDocument $XmlDocument -ParentNode $element
            $ParentNode.AppendChild($element)
        }
        elseif ($property.Value -is [Array]) {
            foreach ($item in $property.Value) {
                $subElement = $XmlDocument.CreateElement($property.Name)
                ConvertTo-Xml -InputObject $item -XmlDocument $XmlDocument -ParentNode $subElement
                $ParentNode.AppendChild($subElement)
            }
        }
        else {
            $element = $XmlDocument.CreateElement($property.Name)
            $element.InnerText = $property.Value
            $ParentNode.AppendChild($element)
        }
    }
}

$json = @"
{
    "notes":  {
        "note":  [
            {
                "to":  "Tove",
                "from":  "Jani",
                "heading":  "Reminder",
                "body":  "Don't forget me this weekend!"
            },
            {
                "to":  "to",
                "from":  "from",
                "heading":  "head",
                "body":  "body"
            }
        ]
    }
}
"@

$data = ConvertFrom-Json $json
$XmlDocument = New-Object System.Xml.XmlDocument

ConvertTo-Xml -InputObject $data -XmlDocument $XmlDocument -ParentNode $XmlDocument

$XmlDocument.OuterXml
