package ui.comp;

class DynamicElementComp extends ui.comp.ElementComp {
    public function new(?parent) {
        super(parent);
        initComponent();

        rebuild();
    }

    public function init() {}

    public function rebuild() {
        removeChildren();
        clearBinds();
        refreshTooltip();
        dom.contentRoot = this;
        init();
        if (recursivePropagate) {
            recursivePropagate = recursivePropagate;
        }
        dom.applyStyle(ui.BaseGUI.style, true);
    }
}