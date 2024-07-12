import Toybox.Lang;

class ExportRequest {
    private var _callback as Method(responseCode as Number, percent as Float) as Void?;
    private var _tracker as Tracker?;
    private var _currentPos = 0;
    private var _lastPos = 0;
    private const _step = 100;
    
    public function sendData(tracker as Tracker, callback as Method(responseCode as Number, percent as Float) as Void) {
        _callback = callback;
        _tracker = tracker;
        _currentPos = 0;
        _lastPos = tracker.getLastPos();
        log(Lang.format("Sending $1$ datapoints", [_lastPos]));
        makeRequest(null);
    }

    function makeRequest(track_id as Number?) {
        var params = {"points" => _tracker.getData(_currentPos, _currentPos + _step)};
        if (track_id != null) {params.put("track_id", track_id);}
        var url = "https://totoro/api/locationTracker/tracks";
        var options = {
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        _currentPos = _currentPos + _step;
        Communications.makeWebRequest(url, params, options, method(:onExportFinish));
    }


    function onExportFinish(responseCode as Number, data as Null or Dictionary or String or $.Toybox.PersistedContent.Iterator) as Void {    
        if(responseCode == 200 && _currentPos < _lastPos) {
            _callback.invoke(responseCode, _currentPos * 100.0 / _lastPos);
            makeRequest(data["track_id"].toNumber());
        } else {
            _callback.invoke(responseCode, 100.0);
        }
   }
}