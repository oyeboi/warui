package ui.comp;

@:uiComp("element")
class ElementComp extends ui.comp.BaseElementComp {
    
    // @formatter:off
    static var SRC = <element></element>;

    // @formatter:on
    var enable(default,set): Bool = true;
    var hoverDisabled: Bool;

    function set_enable(b:Bool): Bool {
        if (!b && !hoverDisabled) {
            dom.active = false;
            dom.hover = false;
        }

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

        enable = b;
        return b;
    }

    public function new(?parent) {

        hoverDisabled = false;
        // enable = true;

        super(parent);
        initComponent();

        dom.toggleClass("enabled", enable);
    }
}