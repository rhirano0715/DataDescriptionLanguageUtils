$HERE = Split-Path -Parent $MyInvocation.MyCommand.Path
$SUT = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$HERE\$SUT" "dummy InputFilePath" "dummy OutputFilePath"

$TestdataRoot = Split-Path -Parent $HERE | Join-Path -ChildPath "testdata"
$InputRoot = Join-Path $TestdataRoot "input"
$InputJson = Join-Path $InputRoot "test.json"
$InputXml = Join-Path $InputRoot "test.xml"
$OutputRoot = Join-Path $TestdataRoot "output" | Join-Path -ChildPath "powershell"
$OutputFromJsonJson = Join-Path $OutputRoot "fromjson.json"
$OutputFromJsonXml = Join-Path $OutputRoot "fromjson.xml"
$OutputFromXmlJson = Join-Path $OutputRoot "fromxml.json"
$OutputFromXmlXml = Join-Path $OutputRoot "fromxml.xml"

Describe "DdluMain test" {
    It "Json2Json" {
        $expected = @(
            '[',
            '    {',
            '        "Key1":  "Value1",',
            '        "Key2":  "Value2",',
            '        "Key3":  "Value3",',
            '        "Key4":  "Value4"',
            '    },',
            '    {',
            '        "Key1":  "Value1",',
            '        "Key2":  "Value2",',
            '        "Key3":  "Value3",',
            '        "Key4":  "Value4"',
            '    }',
            ']'
        )

        DdluMain $InputJson $OutputFromJsonJson
        $actual = Get-Content $OutputFromJsonJson
        $actual | Should  Be $expected
    }
    It "Json2Xml not surported" {
        $expected = @(
            '<?xml version="1.0" encoding="utf-8"?>',
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
        $actual | Should  Be $expected
    }
    It "Xml2Json" {
        $expected = @(
            '{',
            '    "notes":  {',
            '                  "note":  [',
            '                               {',
            '                                   "to":  "Tove",',
            '                                   "from":  "Jani",',
            '                                   "heading":  "Reminder",',
            '                                   "body":  "Don\u0027t forget me this weekend!"',
            '                               },',
            '                               {',
            '                                   "to":  "to",',
            '                                   "from":  "from",',
            '                                   "heading":  "head",',
            '                                   "body":  "body"',
            '                               }',
            '                           ]',
            '              }',
            '}',
            ']'
        )

        DdluMain $InputXml $OutputFromXmlJson
        $actual = Get-Content $OutputFromXmlJson
        $actual | Should  Be $expected
    }
    It "Xml2Xml" {
        $expected = @(
            "<?xml version=`"1.0`" encoding=`"utf-8`"?>",
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
        $actual | Should  Be $expected
    }
}
