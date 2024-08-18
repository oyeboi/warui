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
    static var hideCursor: Bool;
    static var cursorCache: haxe.ds.StringMap<hxd.Cursor.CustomCursor>;
    static var curNativeCursor: CastleDB.IconsKind;

    var elements: Array<ui.comp.BaseElementComp>;
    var tmpElements: Array<ui.comp.BaseElementComp>;

    var stage(default,null): h2d.Layers;

    public var lastKeyCode(default,null): Int;
    public var lastKeyDown(default,null): Bool;

    var root: h2d.Flow;

    public function new(context:h2d.Layers) {
        elements = [];
        tmpElements = [];

        lastKeyDown = false;
        lastKeyCode = -1;
        hideCursor = false;
        event = new lib.WaitEvent();

        stage = context;

        cursorCache = new haxe.ds.StringMap<hxd.Cursor.CustomCursor>();
        hxd.System.setCursor = setSystemCusor;

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
     * Returns `true` if the app is accepting input from a gamepad. Useful for modifying certain GUI elements.
     * NOTE: This function can be replaced with your own means of determining gamepad usage.
     * @return Bool
     */
     public static dynamic function isGamepadActive(): Bool {
        return false;
    }

    /**
     * Returns a `h2d.Tile` from CastleDB as an icon.
     * Can be substituted for an alternative approach.
     * @param id 
     * @return h2d.Tile
     */
    public static dynamic function getIcon(id:CastleDB.IconsKind): h2d.Tile {
        var gfx:Types.TilePos = cast CastleDB.icons.get(id).gfx;
        if (gfx == null) {
            trace('Error: Icon ${id.toString()} not found!');
            return null;
        }
        return getTile(gfx);
    }

    public static dynamic function getTile(tilePos:Types.TilePos): h2d.Tile {
        if (tilePos == null) {
            return h2d.Tile.fromColor(0xff00ff, 16, 16);
        }
        if (tilePos.width == null) {
            tilePos.width = 1;
        }
        var w = tilePos.width * tilePos.size;
        if (tilePos.height == null) {
            tilePos.height = 1;
        }

        var h = tilePos.height * tilePos.size;
        return hxd.Res.load(tilePos.file).toTile().sub(tilePos.x * tilePos.size + 0 * w, tilePos.y * tilePos.size + 0 * h, w, h);
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
    }

    public function onWindowEvent(ev:hxd.Event) {

    }

    /**
     * Sets a predefined `hxd.Cursor` for the overall application.
     * @param cursor 
     */
    public function setSystemCusor(cursor:hxd.Cursor) {
        if (isGamepadActive()) {
            cursor = Hide;
        }

        switch (cursor) {
            case Button:
                setGUICursor(OverCursor);
            case Hide:
                setGUICursor(null);
            case Callback(f):
                f();
            default:
                setGUICursor(DefaultCursor);
        }
    }

    /**
     * Set the cursor application to a default pointer.
     */
     public function setDefaultCursor() {
        setGUICursor(DefaultCursor);
    }

    static function setGUICursor(id:CastleDB.IconsKind) {
        if (hideCursor) {
            id = null;
        }

        if (isGamepadActive()) {
            if (curNativeCursor == null) {
                return;
            }
        }
        
        if (curNativeCursor != id) {
            curNativeCursor = id;
            if (id == null) {
                hxd.System.setNativeCursor(hxd.Cursor.Default);
                return; 
            }

            var cursor = hxd.Cursor.Custom(getIconCursor(id));
            hxd.System.setNativeCursor(cursor);
            return; 
        }
    }


    static function getIconCursor(id:CastleDB.IconsKind): hxd.Cursor.CustomCursor {
        var c = cursorCache.get(id.toString());
        if (c == null) {
            var ico:CastleDB.Icons = CastleDB.icons.get(id);
            var inf = ico.gfx;

            var bmp = hxd.Res.loader.load(inf.file).toImage().toBitmap();
            if (bmp.width >= inf.size) {
                bmp.toNative().width = inf.size;
            }
            
            var cursor = bmp.sub(inf.x * inf.size, inf.y * inf.size, bmp.width, inf.size);
            bmp.dispose();
            var offsetX = 0, offsetY = 0;
            if (ico.props != null) {
                offsetX = ico.props.offsetX;
                offsetY = ico.props.offsetY;
            }

            c = new hxd.Cursor.CustomCursor([cursor], 1, offsetX, offsetY);
            cursorCache.set(id.toString(), c);
        }
        return c;
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

        for (i in 0...elements.length) {
            tmpElements.push(elements[i]);
        }

        for (i in 0...tmpElements.length) {
            var e = tmpElements[i];
            e.updateRec(dt);
        }

        var i = tmpElements.length;
        while (i-- > 0) {
            tmpElements.pop();
        }
        
        BaseGUI.style.sync();
    }
}

class RootContainer extends h2d.Flow implements h2d.domkit.Object {
	public function new(?parent) {
		super(parent);
		initComponent();
	}
}