package ui.comp;

import hxd.Event;

@:uiComp("element")
class ElementComp extends ui.comp.BaseElementComp {
    
    // @formatter:off
    static var SRC = <element></element>;

    // @formatter:on
    var enable(default,set): Bool;
    var hoverDisabled: Bool;
    var propagateOverOut: Bool;
    var autoFillWidth: Bool;
    var autoFillHeight: Bool;
    var recursivePropagate(default,null): Bool;

    var checkSelected: Void->Bool;
    var selected(default,set): Bool;
    var toggleSelectedOnClick: Bool;

    var checkEnable: Void->Bool;

    public var onClick(default,set): Void->Void;
    public var onRightClick(default,set): Void->Void;
    public var onOver(default,set): Void->Void;
    public var onOut(default,set): Void->Void;
    public var onFocus(default,set): Void->Void;
    public var onPush(default,set): Void->Void;
    public var onPushRight(default,set): Void->Void;
    public var onRelease(default,set): Void->Void;

    var pushed: Bool;
    var hasHover: Bool;

    /**
     * Empty dummy method. Useful for resetting callbacks and function binds.
     */
    public final inline function emptyFunc() {}

    public function new(?parent) {
        super(parent);
        initComponent();

        hasHover = false;
        pushed = false;

        onRelease = emptyFunc;
        onPushRight = emptyFunc;
        onPush = emptyFunc;
        onFocus = emptyFunc;
        onOver = emptyFunc;
        onOut = emptyFunc;
        onRightClick = emptyFunc;
        onClick = emptyFunc;



        autoFillHeight = false;
        autoFillWidth = false;
        propagateOverOut = false;
        hoverDisabled = false;
        enable = true;

        dom.toggleClass("enabled", enable);
    }

    /**
     * Apply a function `func` recursively on an object.
     * @param obj Root h2d.Drawable object
     * @param func Function `(h2d.Drawable)->Void` to be applied
     */
    public static function applyRec(obj:h2d.Object, func:h2d.Drawable->Void) {
        var drawable:h2d.Drawable = null;
        if (Std.isOfType(obj, h2d.Drawable)) {
            drawable = cast obj;
        } else {
            throw 'Object is not of h2d.Drawable type!';
        }
        if (drawable != null) {
            func(drawable);
            for (i in 0...drawable.children.length) {
                applyRec(drawable.getChildAt(i), func);
            }
        }
    }

    public function makeInteractive() {
        if (enableInteractive) {
            return;
        }

        enableInteractive = true;
        if (recursivePropagate) {
            recursivePropagate = true;
        }

        interactive.name = Type.getClassName(Type.getClass(this));
        interactive.enableRightButton = true;

        // TODO: Add callback for cursor icon info over Element
        var callback = ()->{};

        interactive.cursor = hxd.Cursor.Callback(callback);
        interactive.onClick = (ev:hxd.Event)->{
            if (ev.button == hxd.Key.MOUSE_LEFT) {
                tryClick();
            } else if (ev.button == hxd.Key.MOUSE_RIGHT) {
                tryRightClick();
            }
        }

        // NOTE: Reassign h2d.Interactive function calls so that 
        // we can drive interactions and feedback with our own methods.
        interactive.onOver = (_)->_onOver();
        interactive.onPush = (ev:hxd.Event)->_onPush(ev);
        interactive.onRelease = (ev)->_onRelease(ev);
        interactive.onOut = (ev)->_onOut();
        interactive.onMove = (ev:hxd.Event)->{
            if (propagateOverOut) {
                ev.propagate = true;
            }
        };
        interactive.onCheck = (ev:hxd.Event)->{
            if (propagateOverOut) {
                ev.propagate = true;
            }
        };
    }

    function set_onClick(f:Void->Void): Void->Void {
        onClick = f;
        makeInteractive();
        return f;
    }

    function set_onRightClick(f:Void->Void): Void->Void {
        onRightClick = f;
        makeInteractive();
        return f;
    }

    function set_onOver(f:Void->Void): Void->Void {
        onOver = f;
        makeInteractive();
        return f;
    }

    function set_onOut(f:Void->Void): Void->Void {
        onOut = f;
        makeInteractive();
        return f;
    }

    function set_onFocus(f:Void->Void): Void->Void {
        onFocus = f;
        makeInteractive();
        return f;
    }

    function set_onPush(f:Void->Void): Void->Void {
        onPush = f;
        makeInteractive();
        return f;
    }

    function set_onPushRight(f:Void->Void): Void->Void {
        onPushRight = f;
        makeInteractive();
        return f;
    }

    function set_onRelease(f:Void->Void): Void->Void {
        onRelease = f;
        makeInteractive();
        return f;
    }

    function set_selected(b:Bool): Bool {
        if (selected == b) {
            return b;
        }

        if (dom != null) {
            dom.toggleClass("selected", b);
        }

        selected = b;
        return b;
    }

    function set_enable(b:Bool): Bool {
        if (!b) {
            if (dom != null) {
                if (!hoverDisabled) {
                    dom.active = false;
                    dom.hover = false;
                }
            }
        }

        if (dom != null) {
            if (dom.hasClass("enabled")) {
                if (!b) {
                    dom.toggleClass("enabled", b);
                }
            }
            
            if (dom.hasClass("disabled")) {
                if (b) {
                    dom.toggleClass("disabled", !b);
                }
            }
        }

        enable = b;
        return b;
    }

    function set_checkEnable(f:Void->Bool): Void->Bool {
        if (checkEnable == null) {
            if (f != null) {
                bindUpdate((dt)->{
                    if (checkEnable != null) {
                        enable = checkEnable();
                    }
                });
            }
        }
        checkEnable = f;
        return f;
    }

    function set_checkSelected(f:Void->Bool): Void->Bool {
        if (checkSelected == null) {
            if (f != null) {
                bindUpdate((dt)->{
                    if (checkSelected != null) {
                        selected = checkSelected();
                    }
                });
            }
        }
        checkSelected = f;
        return f;
    }

    override function clearBinds() {
        super.clearBinds();
        if (checkEnable != null) {
            var v = checkEnable;
            checkEnable = null;
            checkEnable = v;
        }

        if (checkSelected != null) {
            var v = checkSelected;
            checkSelected = null;
            checkSelected = v;
        }
    }

    override function tryClick(): Bool {
        if (super.tryRelease() || !enable) {
            return false;
        }

        if (toggleSelectedOnClick) {
            selected = !selected;
        }

        try {
            onClick();
        } catch (e) {
            throw "Exception: " + e;
        }

        if (onClick != emptyFunc) {
            playClickFeedback();
        }

        if (toggleSelectedOnClick) {
            playClickFeedback();
        }

        return true;
    }

    function tryRightClick(): Bool {
        if (super.tryRelease() || !enable) {
            return false;
        }

        try {
            onRightClick();
        } catch (e) {
            throw "Exception: " + e;
        }

        if (onRightClick != emptyFunc) {
            playClickFeedback();
            return true;
        }

        return false;
    }

    override function tryRelease(): Bool {
        if (super.tryRelease()) {
            return false;
        }
        
        onRelease();
        return true;
    }

    override function _onOver() {
        // TODO: Show tooltip

        if (enable || !hoverDisabled) {
            if (dom != null) {
                dom.hover = true;
            }
        }

        if (enable) {
            playHoverFeedback();
        }

        hasHover = true;
        onOver();
    }

    override function _onFocus() {
        super._onFocus();
        if (enable) {
            playFocusFeedback();
        }
        onFocus();
    }

    override function _onOut() {
        // TODO: Hide tooltip

        if (!enable) {
            if (hoverDisabled) {
                if (dom != null) {
                    dom.hover = false;
                }
            }
        }

        hasHover = false;
        onOut();
    }

    override function _onPush(ev:Event) {
        if (!enable) {
            return;   
        }

        if (dom != null) {
            dom.active = true;
        }
        pushed = true;

        if (ev != null) {
            if (ev.button == hxd.Key.MOUSE_LEFT) {
                onPush();
            } 
            
            if (ev.button == hxd.Key.MOUSE_RIGHT) {
                onPushRight();
            }
        }
    }

    override function _onRelease(ev:Event) {
        if (dom != null) {
            dom.active = true;
        }
        pushed = false;
        tryRelease();
    }

    override function onRemove() {
        if (baseGUI != null) {
            // closeSfx
        }

        if (hasHover) {
            _onOut();
        }

        super.onRemove();
    }

    function playClickFeedback() {
        if (baseGUI == null) {
            return;
        }

        trace("ClickFeecback");

        // Audio Feedback

        // Visual Feedback

    }

    function playHoverFeedback() {
        if (baseGUI == null) {
            return;
        }

        trace("HoverFeedback");

        // Audio Feedback

        // Visual Feedback
    }

    function playFocusFeedback() {
        if (baseGUI == null) {
            return;
        }

        trace("FocusFeedback");

        // Audio Feedback

        // Visual Feedback
    }
}