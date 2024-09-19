package ui.comp;

@:uiComp("base-element")
class BaseElementComp extends h2d.Flow implements h2d.domkit.Object {

    // @formatter:off
    static var SRC = <base-element></base-element>;

    // @formatter:on
    static var BLOCK_DRAW_REC: Bool;
    static var BLOCK_SYNC: Bool;
    static var BLOCK_UPDATE_REC: Bool;

    public static var updateCounter: Int;

    public var baseGUI(get,null): ui.BaseGUI;

    var regUpdates: Array<Void->Void>;
    var event: lib.WaitEvent;
    var registered: Bool;
    var lastUpdate: Float;
    var needRegister: Bool;
    var childElements: Array<BaseElementComp>;
    var removed: Bool;
    var regUpdateTimer: Float;

    var autoClick: Bool;
    var autoFocusing: Bool;

    inline function get_baseGUI():BaseGUI {
        return ui.BaseGUI.inst;
    }

    public function new(?parent) {
        regUpdateTimer = Math.random() * Const.REGULAR_UPDATE_DT;
        removed = false;
        childElements = null;
        needRegister = false;
        lastUpdate = -1;
        registered = false;
        event = null;
        regUpdates = null;

        super(parent);
        initComponent();
    }

    function getScrollContainer(): h2d.Flow {
        var p = parent;
        while (p != null) {
            if (Std.isOfType(p, h2d.Flow)) {
                var f:h2d.Flow = cast p;
                if (f != null) {
                    if (f.overflow == h2d.Flow.FlowOverflow.Scroll) {
                        return f;
                    }
                }
            }
            p = p.parent;
        }
        return null;
    }

    function _onFocus() {
        dom.focus = true;
        if (!enableInteractive) {
            return;
        }

        var scrollContent = getScrollContainer();
        if (scrollContent != null) {
            var mainElement:h2d.Object = this;
            var p = this.parent;
            while ((scrollContent != p) || (scrollContent != p.parent)) {
                mainElement = p;
                p = p.parent;
            }

            var height = mainElement.getSize().yMax - mainElement.getSize().yMin;
            var padding = 50;
            if ((mainElement.absY - padding) >= scrollContent.absY) {
                scrollContent.scrollPosY -= (scrollContent.absY - (mainElement.absY - padding));
            }
            if ((scrollContent.absY + scrollContent.calculatedHeight) >= ((mainElement.absY + height) + padding)) {
                scrollContent.scrollPosY += ((mainElement.absY + height) - (scrollContent.absY + scrollContent.calculatedHeight));
            }
        }
        
        reflow(); // ???
        if (autoClick) {
            var ev = new hxd.Event(hxd.Event.EventKind.EPush);
            ev.button = hxd.Key.MOUSE_LEFT;
            interactive.onClick(ev);
        }
        autoFocusing = false;
        return;
    }

    function _onOver() {}
    function _onOut() {}
    function _onPush(ev:hxd.Event) {}
    function _onRelease(ev:hxd.Event) {}

    /**
     * Attempt to execute a click action.
     * @return Bool
     */
    function tryClick(): Bool {
        return false;
    }

    /**
     * Attempt to execute a release action.
     * @return Bool
     */
    function tryRelease(): Bool {
        return false;
    }

    /**
     * Remove all binded callbacks.
     */
    public function clearBinds() {
        regUpdates = null;
        event = null;
        lastUpdate = -1;
    }

    /**
     * Add the current `BaseElementComp` to the GUI context.
     */
    public function register() {
        if (registered) {
            return;
        }

        needRegister = true;
        if (allocated) {
            registered = true;
            var p:BaseElementComp = cast getParent(BaseElementComp);
            if (p != null) {
                p.register();
                if (p.childElements == null) {
                    p.childElements = [this];
                } else {
                    if (childElements.indexOf(this) < 0) {
                        p.childElements.push(this);
                    }
                }
            } else {
                baseGUI.elements.push(this);
            }
        }
    }

    /**
     * Remove the current `BaseElementComp` from the GUI context.
     */
    function unregister() {
        if (registered) {
            var p = getParent(BaseElementComp);
            if (p == null) {
                baseGUI.elements.remove(this);
            }
        }
        registered = false;
    }

    override function onAdd() {
        super.onAdd();
        if (needRegister) {
            register();
        }
        removed = false;
    }

    override function onRemove() {
        super.onRemove();
        unregister();
        removed = true;
        
        
    }

    /**
     * Delays a function `callback` by `delay` seconds.
     * @param delay Second
     * @param callback 
     */
     public function wait(delay:Float, callback:Void->Void) {
        if (event == null) {
            event = new lib.WaitEvent();
            register();
        }
        event.wait(delay, callback);
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
        wait((delay/1000.0), callback);
    }

    /**
     * Repeat a callback function each update until it returns true.
     * @param callback 
     */
    public function waitUntil(callback:Float->Bool) {
        if (event == null) {
            event = new lib.WaitEvent();
            register();
        }
        event.waitUntil(callback);
    }

    /**
     * Binds a `callback` function to the WaitEvent loop indefinitely until cleared.
     * @param callback Function to be invoked each frame.
     */
    public function bindUpdate(callback:Float->Void) {
        if (lastUpdate < 0) {
            throw "Calling bindUpdate() too late!";
        }

        waitUntil((dt)->{
            callback(dt);
            return false;
        });
    }

    /**
     * Binds a function `callback` to a fixed interval unaffected by the update loop.
     * The function is also immediately called once.
     * @param callback 
     */
     public function bindRegular(callback:Void->Void) {
        if (lastUpdate < 0) {
            throw "Calling bind() too late!";
        }

        if (regUpdates == null) {
            register();
            regUpdates = new Array<Void->Void>();
        }
        regUpdates.push(callback);
        callback();
    }

    /**
     * Executes all functions binded to the regular update loop.
     */
    function callBinds() {
        if (regUpdates != null) {
            for (i in 0...regUpdates.length) {
                var f = regUpdates[i];
                f();
            }
        }
    }

    /**
     * Returns a `BaseElement` parent of class type `cl`.
     * @param cl 
     * @return h2d.Object
     */
    function getParent(cl:Class<BaseElementComp>): h2d.Object {
        var p = this.parent;
        while (p != null) {
            if (Std.isOfType(p, cl)) {
                return p;
            }
            p = p.parent;
        }
        return null;
    }

    /**
     * Returns the most recent `BaseElement` child of class type `cl`.
     * @param cl 
     * @return h2d.Object
     */
    function getChild(cl:Class<BaseElementComp>): h2d.Object {
        var i = children.length;
        while (i-- > 0) {
            var e = getChildAt(i);
            if (Std.isOfType(e, cl)) {
                return e;
            }
        }
        return null;
    }

    /**
     * Recurisvely updates all `BaseElementComp` children of this component.
     * @param dt 
     */
    public function updateRec(dt:Float) {
        if (BaseElementComp.BLOCK_UPDATE_REC) {
            return;
        }

        _update(dt);
        if (childElements != null) {
            var i = childElements.length;
            while (i-- > 0) {
                var e = childElements[i];
                if (!e.removed) {
                    e.updateRec(dt);
                    if (e.removed) {
                        childElements.remove(e);
                    }
                }
            }
        }
    }

    /**
     * Recursively dispatch hxd.Event `ev` to all child elements.
     * @param ev 
     * @return Bool
     */
    public function dispatchRec(ev:hxd.Event): Bool {
        if (childElements != null) {
            for (i in 0...childElements.length) {
                var c = childElements[i];
                if (c.dispatchRec(ev)) {
                    return true;
                }
            }
        }
        handleEvent(ev);
        return true;
    }

    function handleEvent(ev:hxd.Event): Bool {
        return false;
    }

    function _update(dt:Float) {
        if (event != null) {
            event.update(dt);
        }

        BaseElementComp.updateCounter++;
        regUpdateTimer -= dt;
        if (regUpdateTimer <= 0) {
            lastUpdate = Utils.time();
            callBinds();
            regUpdateTimer += Const.REGULAR_UPDATE_DT;
        }
    }

    override function drawRec(ctx:h2d.RenderContext) {
        if (BaseElementComp.BLOCK_DRAW_REC) {
            return;
        }
        super.drawRec(ctx);
    }

    override function sync(ctx:h2d.RenderContext) {
        if (BaseElementComp.BLOCK_SYNC) {
            return;
        }
        super.sync(ctx);
    }
}