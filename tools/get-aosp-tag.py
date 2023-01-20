import xml.etree.ElementTree as ET
import os
root = ET.parse(os.path.dirname(os.path.abspath(__file__)) + '/../../../.repo/manifest.xml').getroot()
for type_tag in root.findall('remote'):
    if type_tag.get('name') == 'aosp':
        print(type_tag.get('revision'))
