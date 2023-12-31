# -*- coding: utf-8 -*-

import pytest
import pathlib
import src.ddlu as ddlu

TESTDATA_ROOT = pathlib.Path(__file__).parent.parent.parent / "testdata"
INPUT_DIR = TESTDATA_ROOT / "input"
INPUT_JSON = INPUT_DIR / "test.json"
INPUT_XML = INPUT_DIR / "test.xml"
OUTPUT_DIR = TESTDATA_ROOT / "output" / "python"

def test_json_to_json():
    excepted = """[
    {
        "Key1": "Value1",
        "Key2": "Value2",
        "Key3": "Value3",
        "Key4": "Value4"
    },
    {
        "Key1": "Value1",
        "Key2": "Value2",
        "Key3": "Value3",
        "Key4": "Value4"
    }
]"""

    actual = OUTPUT_DIR / "fromjson.json"
    ddlu.run(INPUT_JSON, actual)

    assert excepted == actual.read_text()

def test_json_to_xml():
    excepted = """<?xml version="1.0" encoding="utf-8"?>
<items>
	<item>
		<Key1>Value1</Key1>
		<Key2>Value2</Key2>
		<Key3>Value3</Key3>
		<Key4>Value4</Key4>
	</item>
	<item>
		<Key1>Value1</Key1>
		<Key2>Value2</Key2>
		<Key3>Value3</Key3>
		<Key4>Value4</Key4>
	</item>
</items>"""

    actual = OUTPUT_DIR / "fromjson.xml"
    ddlu.run(INPUT_JSON, actual)

    assert excepted == actual.read_text()

def test_xml_to_json():
    excepted = """{
    "notes": {
        "note": [
            {
                "to": "Tove",
                "from": "Jani",
                "heading": "Reminder",
                "body": "Don't forget me this weekend!"
            },
            {
                "to": "to",
                "from": "from",
                "heading": "head",
                "body": "body"
            }
        ]
    }
}"""

    actual = OUTPUT_DIR / "fromxml.json"
    ddlu.run(INPUT_XML, actual)

    assert excepted == actual.read_text()

def test_xml_to_xml():
    excepted = """<?xml version="1.0" encoding="utf-8"?>
<notes>
	<note>
		<to>Tove</to>
		<from>Jani</from>
		<heading>Reminder</heading>
		<body>Don't forget me this weekend!</body>
	</note>
	<note>
		<to>to</to>
		<from>from</from>
		<heading>head</heading>
		<body>body</body>
	</note>
</notes>"""

    actual = OUTPUT_DIR / "fromxml.xml"
    ddlu.run(INPUT_XML, actual)

    assert excepted == actual.read_text()
