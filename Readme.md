# Location Tracker

The goal of this app is to register the location of the device at regular intervals, in order to be able to map a multi-day expedition using as little battery as possible.

## Approach

**The approach used in this version does not work!**

This version stores the position store on the device every 5 minutes. This does not work because the GPS location on the device is not updated unless an activity is started or there is a synch with the mobile phone.