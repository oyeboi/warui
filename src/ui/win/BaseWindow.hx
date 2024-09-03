package ui.win;

class BaseWindow extends ui.comp.DynamicElementComp {
    var subwindows: Array<BaseWindow>;
    var autoDisplays(get,null): Bool;

    public function new(?parent) {
        subwindows = [];

        super(parent);
        initComponent();
        
        enableInteractive = true;
        needRegister = true;
        interactive.propagateEvents = false;

        interactive.onClick = (ev:hxd.Event)->removeSubwindows();
        if (autoDisplays) {
            autoDisplay();
        }
    }

    function get_autoDisplays() {
        return false;
    }

    function autoDisplay() {

    }

    function update(dt:Float) {

    }

    function fixedUpdate() {

    }

    override function rebuild() {
            super.rebuild();
            bindUpdate((dt)->{});
            bindCallback(()->{});
    }

    public function removeSubwindows() {
        var i = subwindows.length;
        while (i-- > 0) {
            var w = subwindows.pop();
            if (w != null) {
                w.remove();
            }
        }
    }

    function onBack(): Bool {
        return false;
    }
}