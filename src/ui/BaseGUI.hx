package ui;

class BaseGUI {
    public static var inst(default,null): BaseGUI;
    public static var style(default,null): h2d.domkit.Style;

    var stage(default,null): h2d.Layers;

    var root: h2d.Flow;

    public function new(context:h2d.Layers) {

        stage = context;

        // Create GUI root object for all subsequent UI elements.
        root = new RootContainer();
        root.dom.addClass("root");
        root.fillHeight = true;
        root.fillWidth = true;
        
        BaseGUI.style = new h2d.domkit.Style();
        BaseGUI.style.useSmartCache = true;
        BaseGUI.style.addObject(root);
        stage.addChild(root);

        loadStyle();
    }

    /**
     * Loads the `style.css` resource for use.
     */
     public function loadStyle() {
        BaseGUI.style.load(hxd.Res.style);
    }

    public function onWindowEvent(ev:hxd.Event) {

    }

    public function dispose() {
        if (BaseGUI.inst == this) {
            BaseGUI.inst = null;
        }

        // clear display tree
        if (root != null) {
            root.remove();
        }

        // clear css
        BaseGUI.style.removeObject(root);
    }

    public function onResize() {

    }

    public function update(dt:Float) {
        BaseGUI.style.sync();
    }
}

class RootContainer extends h2d.Flow implements h2d.domkit.Object {
	public function new(?parent) {
		super(parent);
		initComponent();
	}
}
