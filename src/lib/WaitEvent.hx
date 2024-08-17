package lib;

class WaitEvent extends hxd.WaitEvent {
    public function new() {
        super();
    }

    /**
     * Delays a function `callback` by `delay` frames.
     * @param delay Frames
     * @param callback Function
     */
     public function waitF(delay:Float, callback:Void->Void) {
        wait(delay/Const.REGULAR_UPDATE_DT, callback);
    }

    /**
     * Delays a function `callback` by `delay` milliseconds.
     * @param delay Milliseconds
     * @param callback Function
     */
    public function waitMS(delay:Float, callback:Void->Void) {
        wait(delay/1000, callback);
    }

    /**
     * Repeat a callback function for a set interval of seconds. Callback will stop once it returns `true`.
     * @param seconds 
     * @param callback 
     * @return Bool
     */
    public function waitInterval(seconds:Float, callback:Float->Bool) {
        seconds = (seconds < 0) ? 0.0 : seconds;
        var acc:Float = 0.0;
        waitUntil((dt)->{
            acc += dt;
            if (acc < seconds) {
                return false;
            }
            var ret = callback(dt);
            acc -= seconds;
            return ret;
        });
    }

    /**
     * Repeats a callback function at the regular game loop update interveral (default 60 FPS).
     * @param callback 
     */
    public function waitRegular(callback:Float->Bool) {
        waitInterval(Const.REGULAR_UPDATE_DT, callback);
    }


    /**
     * Repeats a callback function each frame for a specifed amount of seconds.
     * @param time 
     * @param callback 
     */
    public function waitFor(time:Float, callback:Float->Bool) {
        var acc = 0.0;
        waitUntil((dt)->{
            callback(dt);
            acc += dt;
            return (acc >= time);
        });
    }

}