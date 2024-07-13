import click
import datetime
import sqlite3
import xml.etree.ElementTree as ET

@click.command()
@click.argument('track')
def buildTrack(track):
    gpx = ET.Element("gpx")
    gpx.set("version", "1.1")
    gpx.set("creator", "Location Tracker")
    trk = ET.SubElement(gpx, "trk")
    ET.SubElement(trk, "name").text = "Sailing activity"
    ET.SubElement(trk, "type").text = "sailing_v2"
    trkseg = ET.SubElement(trk, "trkseg")

    with sqlite3.connect("api/tracks.db") as con:
        cur = con.cursor()
        for row in cur.execute("SELECT time, lat, lon  FROM point where track_id = ?", (track,)):
            trkpt = ET.SubElement(trkseg, "trkpt")
            trkpt.set("lat", str(row[1]))
            trkpt.set("lon", str(row[2]))
            dt = datetime.datetime.fromtimestamp(int(row[0]))
            ET.SubElement(trkpt, "time").text = dt.strftime('%Y-%m-%dT%H:%M:%SZ')
            
    tree = ET.ElementTree(gpx)
    ET.indent(tree, space="  ", level=0)
    tree.write('output.gpx', encoding="UTF-8", xml_declaration=True)

if __name__ == '__main__':
    buildTrack()