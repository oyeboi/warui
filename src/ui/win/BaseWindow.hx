package ui.win;

import Types.EReason;

class BaseWindow extends ui.comp.DynamicElementComp {
    var subwindows: Array<BaseWindow>;
    var autoDisplays(get,null): Bool;
    var forcedKeepOpen(get,null): Bool;
    var backOnSideButton(get,null): Bool;
    public var gcOnOpen(get,null): Bool;
    public var blockInputs(get,null): Bool;
    public var ignoreAutoClose(get,null): Bool;

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
        return true;
    }

    function get_blockInputs(): Bool {
        return forcedKeepOpen;
    }

    function get_blockHighPriorityInputs(): Bool {
        return false;
    }

    function get_ignoreAutoClose(): Bool {
        return false;
    }

    function get_autoPause(): Bool {
        return false;
    }

    function get_wheelWindow(): Bool {
        return false;
    }

    function get_forcedKeepOpen(): Bool {
        return (checkClose() != EReason.Success);
    }

    public function canClose(): Bool {
        return (checkClose() == EReason.Success);
    }

    public function checkClose(): EReason {
        return EReason.Success;
    }

    function get_partialPause(): Bool {
        return false;
    }

    function get_gcOnOpen(): Bool {
        return true;
    }

    function get_backOnSideButton(): Bool {
        return false;
    }

    function get_autoRegisterLayer(): Bool {
        return true;
    }

    function get_bgShade(): Bool {
        return false;
    }

    function get_bgGradientClass(): String {
        return "";
    }

    function update(dt:Float) {}

    function regularUpdate() {}

    override function init() {
        super.init();
    }

    override function rebuild() {
        super.rebuild();
        bindUpdate(update);
        bindRegular(regularUpdate);
    }

    override function onRemove() {
        super.onRemove();
        removeSubwindows();
    }

    function autoDisplay() {
        baseGUI.displayWindow(this);
    }

    public function closeWindow(): Bool {
        if (forcedKeepOpen) {
            return false;
        }

        baseGUI.removeWindow(this);
        return true;
    }

    /**
     * Determine whether the other window will close when this one opens.
     * @param elem 
     * @return Bool
     */  
    public function closeOtherOnOpen(elem:ui.comp.BaseElementComp): Bool {
        return true;
    }

    /**
     * Determine whether this window will close when the other opens.
     * @param elem 
     * @return Bool
     */
    public function closeSelfOnOpen(elem:ui.comp.BaseElementComp): Bool {
        if (forcedKeepOpen) {
            return false;
        }
        return true;
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

    /**
     * Remove a single subwindow.
     * @param w 
     */
    public function removeSubwindow(w:BaseWindow) {
        if (w != null) {
            subwindows.remove(w);
            w.remove();
        }
    }

    /**
     * Check if the window contains a subwindow of the specified class type .
     * @param cl 
     * @return Bool
     */
    public function hasSubwindow(cl:Class<BaseWindow>): Bool {
        for (i in 0...subwindows.length) {
            var w = subwindows[i];
            if (Std.isOfType(w, cl)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns a subwindow of the specified class.
     * @param cl 
     * @return BaseWindow
     */
     public function getSubwindow(cl:Class<BaseWindow>): BaseWindow {
        for (i in 0...subwindows.length) {
            var w = subwindows[i];
            if (Std.isOfType(w, cl)) {
                return w;
            }
        }
        return null;
    }

    /**
     * Determines whether a window is of the same type as the current window.
     * @param w 
     * @return Bool
     */
    public function compareToWindow(w:BaseWindow): Bool {
        return Std.isOfType(w, Type.getClass(this));
    }

    override function handleEvent(ev:hxd.Event): Bool {
        if (ev.kind == hxd.Event.EventKind.EKeyDown) {
            if (ev.keyCode == hxd.Key.ESCAPE) {
                if (onBack()) {
                    return true;
                }
            }
        }

        if (ev.kind == hxd.Event.EventKind.EPush) {
            if (ev.button == hxd.Key.MOUSE_BACK) {
                if (backOnSideButton) {
                    if (onBack()) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    function onBack(): Bool {
        if (forcedKeepOpen) {
            return false;
        }

        baseGUI.removeWindow(this);
        return true;
    }
}