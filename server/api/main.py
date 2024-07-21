from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import sqlite3

app = FastAPI()

class Point(BaseModel):
    nbr: int
    time: int
    lat: float
    lon: float
    alt: float

class Track(BaseModel):
    track_id: int | None = None
    points: list[Point]

@app.post("/tracks")
async def save_track(track: Track):
    with sqlite3.connect("tracks.db") as con:
        cur = con.cursor()
        if track.track_id is None:
            cur.execute("insert into track (name) values(?)", (datetime.now(),))
            track.track_id = cur.lastrowid
        last_record = 0
        for point in track.points:
            cur.execute("insert into point (track_id, nbr, time, lat, lon, alt) values (?, ?, ?, ?, ?, ?)",
                        (track.track_id, point.nbr, point.time, point.lat, point.lon, point.alt))
            last_record = max(last_record, point.nbr)
    return {"track_id": track.track_id}

@app.get("/tracks")
async def list_tracks():
    return {"message": "Hello World"}
