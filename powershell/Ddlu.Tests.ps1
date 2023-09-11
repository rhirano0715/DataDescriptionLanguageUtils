Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

$script:HERE = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:SUT = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$script:TARGET = (Join-Path $HERE $SUT)
Write-Host $TARGET
. $script:TARGET "dummy InputFilePath" "dummy OutputFilePath"

$script:TestdataRoot = Split-Path -Parent $script:HERE | Join-Path -ChildPath "testdata"
$script:InputRoot = Join-Path $script:TestdataRoot "input"
$script:InputJson = Join-Path $script:InputRoot "test.json"
$script:InputXml = Join-Path $script:InputRoot "test.xml"
$script:OutputRoot = Join-Path $script:TestdataRoot "output" | Join-Path -ChildPath "powershell"
$script:OutputFromJsonJson = Join-Path $script:OutputRoot "fromjson.json"
$script:OutputFromJsonXml = Join-Path $script:OutputRoot "fromjson.xml"
$script:OutputFromXmlJson = Join-Path $script:OutputRoot "fromxml.json"
$script:OutputFromXmlXml = Join-Path $script:OutputRoot "fromxml.xml"

Describe "DdluMain test" {
    It "Json2Json" {
        $expected = @(
            '[',
            '  {',
            '    "Key1": "Value1",',
            '    "Key2": "Value2",',
            '    "Key3": "Value3",',
            '    "Key4": "Value4"',
            '  },',
            '  {',
            '    "Key1": "Value1",',
            '    "Key2": "Value2",',
            '    "Key3": "Value3",',
            '    "Key4": "Value4"',
            '  }',
            ']'
        )

        DdluMain $InputJson $OutputFromJsonJson
        $actual = Get-Content $OutputFromJsonJson
        $actual | Should -Be $expected
    }
    It "Json2Xml not surported" {
        $expected = @(
            '<?xml version="1.0"?>',
            '<items>',
            '    <item>',
            '        <Key1>Value1</Key1>',
            '        <Key2>Value2</Key2>',
            '        <Key3>Value3</Key3>',
            '        <Key4>Value4</Key4>',
            '    </item>',
            '    <item>',
            '        <Key1>Value1</Key1>',
            '        <Key2>Value2</Key2>',
            '        <Key3>Value3</Key3>',
            '        <Key4>Value4</Key4>',
            '    </item>',
            '</items>'
        )

        DdluMain $InputJson $OutputFromJsonXml
        $actual = Get-Content $OutputFromJsonXml
        $actual | Should -Be $expected
    }
    It "Xml2Json" {
        $expected = @(
            '{',
            '  "notes": {',
            '    "note": [',
            '      {',
            '        "to": "Tove",',
            '        "from": "Jani",',
            '        "heading": "Reminder",',
            ('        "body": "Don' + "'" + 't forget me this weekend!"'),
            '      },',
            '      {',
            '        "to": "to",',
            '        "from": "from",',
            '        "heading": "head",',
            '        "body": "body"',
            '      }',
            '    ]',
            '  }',
            '}'
        )

        DdluMain $InputXml $OutputFromXmlJson
        $actual = Get-Content $OutputFromXmlJson
        $actual | Should -Be $expected
    }
    It "Xml2Xml" {
        $expected = @(
            "<?xml version=`"1.0`"?>",
            "<notes>",
            "    <note>",
            "        <to>Tove</to>",
            "        <from>Jani</from>",
            "        <heading>Reminder</heading>",
            "        <body>Don't forget me this weekend!</body>",
            "    </note>",
            "    <note>",
            "        <to>to</to>",
            "        <from>from</from>",
            "        <heading>head</heading>",
            "        <body>body</body>",
            "    </note>",
            "</notes>"
        )

        DdluMain $InputXml $OutputFromXmlXml
        $actual = Get-Content $OutputFromXmlXml
        $actual | Should -Be $expected
    }
}
