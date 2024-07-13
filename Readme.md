# Location Tracker

The goal of this app is to register the location of the device at regular intervals, in order to be able to map a multi-day expedition using as little battery as possible.

## Approach

This version sets a background timer that will warn the use that it's time to save the position. This is the only way to get the GPS going and get some proper location.

The location is stored in `Storage` and can be sent to a server via the "Export" commnd. The export command will do a REST call to a server (check the [server](server/) folder).