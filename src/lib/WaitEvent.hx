package lib;

class WaitEvent extends hxd.WaitEvent {
    public function new() {
        super();
    }

    /**
     * Repeat a callback function for a set interval of `time`. Callback will stop once it returns `true`.
     * @param time Length of interval in milliseconds 
     * @param callback Function to invoked at each interval
     * @return Bool
     */
    public function waitInterval(time:Float, callback:Float->Bool) {
        time = (time < 0) ? 0 : time;
        var count:Float = 0.0;
        waitUntil((dt)->{
            count += dt;
            if (count < time) {
                return false;
            }
            var ret = callback(dt);
            count -= time;
            return ret;
        });
    }

    /**
     * Repeats a callback function at the regular game loop update interveral (default 60 FPS).
     * @param callback Function to invoked each regular update
     */
    public function waitRegular(callback:Float->Bool) {
        waitInterval(Const.REGULAR_UPDATE_DT, callback);
    }


    /**
     * Repeats a `callback `function each frame for a specifed amount of `time`.
     * @param time Length of duration in milliseconds 
     * @param callback Function to invoked each update
     */
    public function waitFor(time:Float, callback:Float->Bool) {
        var count = 0.0;
        waitUntil((dt)->{
            callback(dt);
            count += dt;
            return (count >= time);
        });
    }

}