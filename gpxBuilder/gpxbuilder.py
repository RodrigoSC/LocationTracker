import csv
import datetime
import xml.etree.ElementTree as ET

gpx = ET.Element("gpx")
gpx.set("version", "1.1")
gpx.set("creator", "Location Tracker")
trk = ET.SubElement(gpx, "trk")
ET.SubElement(trk, "name").text = "Sailing activity"
ET.SubElement(trk, "type").text = "sailing_v2"
trkseg = ET.SubElement(trk, "trkseg")

with open('LOCATIONTRACKER.TXT') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        trkpt = ET.SubElement(trkseg, "trkpt")
        trkpt.set("lat", row[1])
        trkpt.set("lon", row[2])
        dt = datetime.datetime.fromtimestamp(int(row[0]))
        ET.SubElement(trkpt, "time").text = dt.strftime('%Y-%m-%dT%H:%M:%SZ')
        
tree = ET.ElementTree(gpx)
ET.indent(tree, space="  ", level=0)
tree.write('output.gpx', encoding="UTF-8", xml_declaration=True)