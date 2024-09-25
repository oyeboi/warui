package ui;

import Types;
class BaseGUI {
    public static var inst(default,null): BaseGUI;
    public static var style(default,null): h2d.domkit.Style;

    // Fonts
    static var DEFAULT_FONTS_DEF: haxe.ds.StringMap<h2d.Font>;
    static var regularFontName(default,null): String;
    static var boldFontName(default,null): String;
    static var italicFontName(default,null): String;

    var event: lib.WaitEvent;

    //GUI 
    static var LAYER_TOOLTIP(default,null): Int = 2;
    static var LAYER_CURSOR(default,null): Int = 3;
    static var LAYER_OVER(default,null): Int = 3;

    // GUI Elements
    static var hideCursor: Bool;
    static var cursorCache: haxe.ds.StringMap<hxd.Cursor.CustomCursor>;
    static var curNativeCursor: CastleDB.IconsKind;
    
    public var elements: Array<ui.comp.BaseElementComp>;
    var tmpElements: Array<ui.comp.BaseElementComp>;
    
    // Windows
    var waitOverlay: h2d.Flow;
    var waitTimeout: Float;
    var windows: Array<ui.win.BaseWindow>;

    // Tooltips
    public var currentTooltip: ui.comp.TooltipComp;
    public var additionalTooltips(default,null): Array<ui.comp.TooltipComp>;
    public var lastTooltip(get,null): ui.comp.TooltipComp;
    public var backTooltip(default,null): ui.comp.ElementComp;
    var tooltipsFrozen: Bool;
    public var freezeTooltips(get,default): Bool;
    public var fadeTooltipsIn(get,default): Bool;
    
    var canvas(default,null): h2d.Layers;

    public var lastKeyCode(default,null): Int;
    public var lastKeyDown(default,null): Bool;

    var root: h2d.Flow;

    public function new(context:h2d.Layers) {
        elements = [];
        tmpElements = [];
        tooltipsFrozen = false;
        waitTimeout = 0;
        waitOverlay = null;
        additionalTooltips = [];

        windows = [];

        lastKeyDown = false;
        lastKeyCode = -1;
        hideCursor = false;
        event = new lib.WaitEvent();

        canvas = context;

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
        canvas.addChild(root);

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
        var gfx:cdb.Types.TilePos = cast CastleDB.icons.get(id).gfx;
        if (gfx == null) {
            trace('Error: Icon ${id.toString()} not found!');
            return null;
        }
        return getTile(gfx);
    }

    public static dynamic function getTile(tilePos:cdb.Types.TilePos): h2d.Tile {
        if (tilePos == null) {
            return h2d.Tile.fromColor(0xff00ff, 16, 16);
        }
        var w = ((tilePos.width == null) ? 1 : tilePos.width) * tilePos.size;
        var h = ((tilePos.height == null) ? 1 : tilePos.height) * tilePos.size;
        return hxd.Res.load(tilePos.file).toTile().sub(tilePos.x * tilePos.size + 0 * w, tilePos.y * tilePos.size + 0 * h, w, h);
    }

    /**
     * Loads the `style.css` resource for use.
     */
     public static function loadStyle() {
        BaseGUI.style.load(hxd.Res.style);
        #if debug
        style.allowInspect = true;
        #end

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
        if (ev.kind == hxd.Event.EventKind.EKeyDown) {
            if (ev.keyCode == lastKeyCode) {
                lastKeyDown = false;
                lastKeyCode = -1;
            }
        }

        if (ev.kind == hxd.Event.EventKind.EKeyUp) {
            if (ev.keyCode == lastKeyCode) {
                return;
            }
            lastKeyDown = true;
            lastKeyCode = ev.keyCode;
        }

        var dispatch = false;
        switch (ev.kind) {
            case EPush:
                dispatch = true;
            default:
                // no op
        }

        if (dispatch) {
            for (i in 0...elements.length) {
                var elem = elements[i];
                if (elem.dispatchRec(ev)) {
                    return;
                }
            }

            if (ev.kind == hxd.Event.EventKind.EPush) {
                onKeyDown(ev);
            }
        }
    }

    function onKeyDown(ev:hxd.Event) {
        if (ev.keyCode == hxd.Key.ESCAPE) {

        }
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

    public function setLayoutClasses(elem:ui.comp.BaseElementComp) {
        // elem.dom.setClassKind("lang", Options.language);

        elem.dom.setClassKind("build", Const.BUILD);

        elem.dom.toggleClass("pad", isGamepadActive());
        elem.dom.toggleClass("pc", !isGamepadActive());
    }

    public function refreshLayoutClasses() {}

    public function onResize() {

    }

    public function update(dt:Float) {
        event.update(dt);
        ui.comp.BaseElementComp.updateCounter = 0;

        if (isWaiting() || (waitTimeout >= lib.Utils.time())) {
            waitRelease();
        }

        for (i in 0...elements.length) {
            tmpElements[i] = elements[i];
        }

        while (elements.length < tmpElements.length) {
            tmpElements.pop();
        }
        
        for (i in 0...tmpElements.length) {
            var e = tmpElements[i];
            e.updateRec(dt);
        }

        tooltipsFrozen = freezeTooltips;
        if (!isGamepadActive()) {
            if (hxd.Key.isPressed(hxd.Key.MOUSE_LEFT)) {
                if (hasLockedTooltip()) {
                    cleanTooltips();
                }
            }
        }

        BaseGUI.style.sync();
    }

    // #region - Tooltips
    function get_fadeTooltipsIn(): Bool {
        return true;
    }

    function get_freezeTooltips(): Bool {
        return false;
    }

    public function get_lastTooltip(): ui.comp.TooltipComp {
        if (additionalTooltips.length > 0) {
            return additionalTooltips[additionalTooltips.length - 1];
        }
        return currentTooltip;
    }

    public function hasLockedTooltip(): Bool {
        return false;
    }

    public function lockTooltip() {
        if (backTooltip == null) {
            
            // blocking element
            backTooltip = new ui.comp.ElementComp();
            backTooltip.enableInteractive = true;
            backTooltip.interactive.propagateEvents = false;

            BaseGUI.style.addObject(backTooltip);
            canvas.add(backTooltip, LAYER_TOOLTIP - 1);
        }
    }

    public function setTooltip(elem:h2d.Object, anchor:h2d.Object, position:Types.TooltipPosition=Top, nesting=0): ui.comp.TooltipComp {
        return null;
    }

    public function removeTooltip(anchor:h2d.Object): Bool {
       
        return false;
    }

    /**
     * Remove all tooltips from the GUI.
     */
     public function cleanTooltips() {
        for (i in 0...additionalTooltips.length) {
            var ttip = additionalTooltips[i];
            if (ttip != null) {
                ttip.remove();
            }
            BaseGUI.style.removeObject(ttip);
        }
        additionalTooltips.resize(0);
        
        if (currentTooltip != null) {
            currentTooltip.remove();
        }
        BaseGUI.style.removeObject(currentTooltip);
        currentTooltip = null;
        
        if (backTooltip != null) {
            backTooltip.remove();
        }
        BaseGUI.style.removeObject(backTooltip);
        backTooltip = null;

        clearAllRefs();
    }

    // #endregion

    // #region Windows
    function isWaiting(): Bool {
        return false;
    }

    function attachWindow(w:ui.win.BaseWindow) {}

    function deselect(): Bool {
        return false;
    }

    public function displayWindow(window:ui.win.BaseWindow) {
        if (windows.contains(window)) {
            return;
        }

        var i = windows.length;
        while (i-- > 0) {
            var w = windows[i];
            if (window.closeOtherOnOpen(w)) {
                if (w.closeSelfOnOpen(window)) {
                    closeWindow(w);
                }
            }
        }

        if (window.parent == null) {
            attachWindow(window);
        }

        windows.unshift(window);
        if (window != null) {
            if (window.gcOnOpen) {
                var delay = 0.01;
                if (Game.inst != null) {
                    delay = delay + Game.inst.dt;
                }
                event.wait(delay, ()->{
                    #if hl
                    var gc = haxe.Timer.stamp() - lib.GC.lastGC;
                    if (gc > lib.GC.cooldown) {
                        lib.GC.lastGC = Sys.time();
                        hl.Gc.major();
                    }
                    #end
                });
            }
        }
    }

    public function hasWindowInstance(window:ui.win.BaseWindow): Bool {
        var i = windows.length;
        while (i-- > 0) {
            var w = windows[i];
            if (w == window) {
                return true;
            }
        }
        return false;
    }

    /**
     * Remove a specified window `w` from the GUI immediately.
     * @param w 
     */
     public function removeWindow(window:ui.win.BaseWindow) {
        windows.remove(window);
        if (window != null) {
            if (window.parent != null) {
                window.parent.removeChild(window);
            }
        }
    }

    /**
     * Close the specified window `window` and remove it from the GUI.
     * @param window 
     */
    public function closeWindow(window:ui.win.BaseWindow) {
        if (window != null) {
            window.closeWindow();
        } else {
            removeWindow(window);
        }
    }

    /**
     * Clear all windows from the current GUI context.
     */
    public function removeAllWindows() {
        var i = windows.length;
        while (i-- > 0 ) {
            var w = windows[i];
            closeWindow(w);
        }
    }

    /**
     * Removes the window of type `cl`.
     * @param cl 
     */
    public function removeWindowType(cl:Class<ui.win.BaseWindow>): Bool {
        var window = getWindow(cl);
        if (window == null) {
            return false;
        }

        removeWindow(window);
        return true;
    }

    /**
     * Returns whether `windows` contains a `BaseWindow` class instance with optional `filter` criteria.
     * @param cl 
     * @param filter 
     * @return Bool
     */
    public function hasWindow(cl:Class<ui.win.BaseWindow>, ?filter:ui.comp.DynamicElementComp->Bool): Bool {
        for (i in 0...windows.length) {
            var w = windows[i];
            if (Std.isOfType(w, cl)) {
                if ((filter == null) || filter(w)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Returns the most recent occurance of `cl`, with optional `filter` criteria.
     * @param cl 
     * @param filter 
     * @return ui.comp.DynamicElement
     */
    public function getWindow(cl:Class<ui.win.BaseWindow>, ?filter:ui.comp.DynamicElementComp->Bool): ui.win.BaseWindow {
        var i = windows.length;
        while (i-- > 0) {
            var w = windows[i];
            if (Std.isOfType(w, cl)) {
                if ((filter == null) || filter(w)) {
                    return w;
                }
            }
        }
        return null;
    }

    public function toggleWindow(cl:Class<ui.win.BaseWindow>, ?filter:ui.comp.DynamicElementComp->Bool): ui.win.BaseWindow {
        var w = getWindow(cl, filter);
        if (w != null) {
            removeWindow(w);
            return null;
        }
        w = Type.createInstance(cl, []);
        displayWindow(w);
        return w;
    }

    /**
     * Check if the GUI has any blocking windows
     */
    public function hasBlockingWindow() {
        for (i in 0...windows.length) {
            var window = windows[i];
            if (Std.isOfType(window, ui.win.BaseWindow)) {
                var w:ui.win.BaseWindow = cast window;
                if (w.blockInputs) {
                    return true;
                }
            }
        }
        return false;
    }

    public function closeFirstClosableUI(fromClick:Bool=true): Bool {
        if (hasLockedTooltip()) {
            cleanTooltips();
        }

        var i = windows.length;
        while (i-- > 0) {
            var w = windows[i];
            if (w != null) {
                if (!w.ignoreAutoClose) {
                    if (w.closeWindow()) {
                        return true;
                    }
                }
            }
            removeWindow(w);
            return true;
        }
        return false;
    }

    /**
     * Returns true if any item in `windows` satisfies the provided function `fn`.
     * @param fn 
     * @return Bool
     */
    public function anyWindow(fn:ui.win.BaseWindow->Bool): Bool {
        for (i in 0...windows.length) {
            var w = windows[i];
            if ((w != null) && fn(w)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if any open window is unable to close.
     */
    public function anyForcedOpenWindow(): Bool {
        return anyWindow((w)->{
            return !w.canClose();
        });
    }

    /**
     * Returns true if any window is blocking user inputs.
     */
    public function anyBlockingWindow(): Bool {
        return anyWindow((w)->{
            return w.blockInputs;
        });
    }

    // #endregion

    public static function loadFontFace(base:h2d.Font, ?variant:String): h2d.Font {
        var fontName = switch(variant) {
            case "bold":
                BaseGUI.boldFontName;
            case "italic":
                BaseGUI.italicFontName;
            default:
                base.name;
        };

        if (BaseGUI.DEFAULT_FONTS_DEF.exists(fontName + "-" + base.size)) {
            return BaseGUI.DEFAULT_FONTS_DEF.get(fontName + "-" + base.size);
        }

        return base;
    }

    public static function loadTextIcon(path:String): h2d.Tile {
        if (path == null) {
            return null;
        }

        return h2d.Tile.fromColor(0xff00ff, 8, 8);
    }

}

class RootContainer extends h2d.Flow implements h2d.domkit.Object {
	public function new(?parent) {
		super(parent);
		initComponent();
	}
}