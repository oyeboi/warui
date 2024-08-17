package ui;

class BaseGUI {
    public static var inst(default,null): BaseGUI;
    public static var style(default,null): h2d.domkit.Style;

    // Fonts
    static var DEFAULT_FONTS_DEF: haxe.ds.StringMap<h2d.Font>;
    var regularFontName(default,null): String;
    var boldFontName(default,null): String;
    var italicFontName(default,null): String;

    var event: lib.WaitEvent;

    // GUI Elements
    var hideCursor: Bool;
    var cursorCache: haxe.ds.StringMap<hxd.Cursor.CustomCursor>;

    var stage(default,null): h2d.Layers;

    public var lastKeyCode(default,null): Int;
    public var lastKeyDown(default,null): Bool;

    var root: h2d.Flow;

    public function new(context:h2d.Layers) {
        
        lastKeyDown = false;
        lastKeyCode = -1;
        hideCursor = false;
        event = new lib.WaitEvent();

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

        // Set up fonts
        regularFontName = hxd.Res.fonts.Roboto_Regular.toFont().name;
        boldFontName = hxd.Res.fonts.Roboto_Bold.toFont().name;
        italicFontName = hxd.Res.fonts.Roboto_Italic.toFont().name;

        if (DEFAULT_FONTS_DEF == null) {
            DEFAULT_FONTS_DEF = new haxe.ds.StringMap<h2d.Font>();
            DEFAULT_FONTS_DEF.set("Default", hxd.res.DefaultFont.get());
            
            DEFAULT_FONTS_DEF.set('$regularFontName-${Const.REG_FONT_SIZE}', hxd.Res.fonts.Roboto_Regular.toSdfFont(Const.REG_FONT_SIZE));
            DEFAULT_FONTS_DEF.set('$boldFontName-${Const.REG_FONT_SIZE}', hxd.Res.fonts.Roboto_Bold.toSdfFont(Const.REG_FONT_SIZE));
            DEFAULT_FONTS_DEF.set('$italicFontName-${Const.REG_FONT_SIZE}', hxd.Res.fonts.Roboto_Italic.toSdfFont(Const.REG_FONT_SIZE));

            DEFAULT_FONTS_DEF.set('${Const.FONT_CUTIVE_MONO}-${Const.REG_FONT_SIZE}', hxd.Res.fonts.CutiveMono_Regular.toSdfFont(Const.REG_FONT_SIZE));
            DEFAULT_FONTS_DEF.set('${Const.FONT_DANCING_SCRIPT}-${Const.REG_FONT_SIZE}', hxd.Res.fonts.DancingScript.toSdfFont(Const.REG_FONT_SIZE));
        };

        // BaseGUI.regularFontName = hxd.Res.fonts.Roboto_Regular_fnt.toFont().name;
        // BaseGUI.boldFontName = hxd.Res.loader.loadCache("fonts/Roboto-bold.fnt", hxd.res.BitmapFont).toFont().name;
        // BaseGUI.italicFontName = hxd.Res.fonts.Roboto_Italic_fnt.toFont().name;
        
        // if (DEFAULT_FONTS_DEF == null) {
        //     DEFAULT_FONTS_DEF = new haxe.ds.StringMap<h2d.Font>();
        //     DEFAULT_FONTS_DEF.set("Default", hxd.res.DefaultFont.get());
        //     DEFAULT_FONTS_DEF.set(regularFontName, hxd.Res.fonts.Roboto_Regular);

        //     // for (fnt in hxd.Res.fonts) {
        //     //     DEFAULT_FONTS_DEF.set('${fnt.name}-${Const.LARGE_FONT_SIZE}, )
        //     // }
        // }
    }

    public function onWindowEvent(ev:hxd.Event) {

    }

    public function dispose() {
        if (BaseGUI.inst == this) {
            BaseGUI.inst = null;
        }

        // clear fonts
        BaseGUI.DEFAULT_FONTS_DEF.clear();
        BaseGUI.DEFAULT_FONTS_DEF = null;

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
        event.update(dt);

        BaseGUI.style.sync();
    }
}

class RootContainer extends h2d.Flow implements h2d.domkit.Object {
	public function new(?parent) {
		super(parent);
		initComponent();
	}
}