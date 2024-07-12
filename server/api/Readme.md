# Location Tracker API

## Database

To create a new database, run `sqlite3 tracks.db < dbschema.sql`.

## Running

Assuming you're using `nginx` to send the requests to `uvicorn`, you can use the following command line:

    .venv/bin/uvicorn main:app --reload --uds /tmp/LocationTracker.sock

The configuration on `nginx` should be something like:

    location /api/locationTracker  {
        rewrite ^/api/locationTracker/(.*)$ /$1 break;
        proxy_pass http://unix:/tmp/LocationTracker.sock;
    }