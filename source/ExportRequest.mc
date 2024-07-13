import Toybox.Lang;

class ExportRequest {
    private var callback as Method(responseCode as Number, percent as Float) as Void?;
    private var tracker as Tracker?;
    private var currentPos = 0;
    private var lastPos = 0;
    private const step = 100;
    
    public function sendData(tracker as Tracker, callback as Method(responseCode as Number, percent as Float) as Void) {
        me.callback = callback;
        me.tracker = tracker;
        currentPos = 0;
        lastPos = tracker.getLastPos();
        log(Lang.format("Sending $1$ datapoints", [lastPos]));
        makeRequest(null);
    }

    function makeRequest(track_id as Number?) {
        var params = {"points" => tracker.getData(currentPos, currentPos + step)};
        if (track_id != null) {params.put("track_id", track_id);}
        var url = "https://totoro/api/locationTracker/tracks";
        var options = {
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        currentPos = currentPos + step;
        Communications.makeWebRequest(url, params, options, method(:onExportFinish));
    }

    function onExportFinish(responseCode as Number, data as Null or Dictionary or String or $.Toybox.PersistedContent.Iterator) as Void {    
        if(responseCode == 200 && currentPos < lastPos) {
            callback.invoke(responseCode, currentPos * 100.0 / lastPos);
            makeRequest((data as Dictionary)["track_id"].toNumber());
        } else {
            callback.invoke(responseCode, 100.0);
        }
   }
}