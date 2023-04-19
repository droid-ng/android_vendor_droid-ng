import xml.etree.ElementTree as ET
import os
def gettag():
    root = ET.parse(os.path.dirname(os.path.abspath(__file__)) + '/../../../.repo/manifests/default.xml').getroot()
    result = None
    for type_tag in root.findall('default'):
        if type_tag.get('remote') == 'aosp' and result is None:
            result = type_tag.get('revision')

    for type_tag in root.findall('remote'):
        if type_tag.get('name') == 'aosp' and result is None:
            result = type_tag.get('revision')

    if result is None:
        raise Exception("Cannot find AOSP tag - fix me!")
    else:
        return result

print(gettag())
