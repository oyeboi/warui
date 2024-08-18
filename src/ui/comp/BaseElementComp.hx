package ui.comp;

@:uiComp("base-element")
class BaseElementComp extends h2d.Flow implements h2d.domkit.Object {

    // @formatter:off
    static var SRC = <base-element></base-element>;

    // @formatter:on
    static var BLOCK_UPDATE_REC: Bool;
    public static var updateCounter(default,null): Int;

    public var baseGUI(get,null): ui.BaseGUI;

    var regUpdates: Array<()->Void>;
    var event: lib.WaitEvent;
    var registered: Bool;
    var lastUpdate: Float;
    var childElements: Array<BaseElementComp>;
    var removed: Bool;
    var regUpdateTimer: Float;

    inline function get_baseGUI():BaseGUI {
        return ui.BaseGUI.inst;
    }

    public function new(?parent) {
        childElements = null;
        lastUpdate = -1;
        event = null;
        regUpdates = null;

        super(parent);
        initComponent();
    }

    /**
     * Empty dummy method. Useful for resetting callbacks and function binds.
     */
    public final function emptyFunc() {}

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

    function _update(dt:Float) {
        if (event != null) {
            event.update(dt);
        }

        BaseElementComp.updateCounter++;
        regUpdateTimer -= dt;
        if (regUpdateTimer <= 0) {
            lastUpdate = #if sys Sys.time(); #else haxe.Timer.stamp(); #end
            callBinds();
            regUpdateTimer += Const.REGULAR_UPDATE_DT;
        }
    }
}