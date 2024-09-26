package ui.comp;

import Types;

@:uiComp("fmt-text")
class FmtTextComp extends h2d.HtmlText implements h2d.domkit.Object {
    // @formatter:off
    static var SRC = <fmt-text></fmt-text>;

    // @formatter:on
    var gui(get,never): ui.BaseGUI;

    var prevUnformatted: String;
    var textTransform(default,set): TextTransform;
    var iconSize: Int;
    var iconYOffset: Null<Int>;

    public var refs(default,null): TooltipRefs;

    var allowOverRichIds(default,set): Bool;
    var transformTextLast: Bool;

    public function new(?txt:String, ?parent) {
        transformTextLast = false;
        allowOverRichIds = true;
        iconYOffset = null;
        iconSize = -1;
        textTransform = null;
        prevUnformatted = null;

        super(hxd.res.DefaultText.get(), parent);
        clearRefs();
        formatText = (s)->{
            ui.BaseGUI.allowOverRichIds = allowOverRichIds;
            if (ui.BaseGUI.inst == null) {
                return s;
            }
            return ui.BaseGUI.inst.formatText(s, this);
        };
        initComponent();
        if (txt != null) {
            this.text = txt;
        }
    }

    function get_gui(): ui.BaseGUI {
        return ui.BaseGUI.inst;
    }

    function set_allowOverRichIds(b:Bool): Bool {
        allowOverRichIds = b;
        var prev = prevUnformatted;
        prevUnformatted = null;
        text = prev;

        return allowOverRichIds;
    }

    override function set_text(t:String): String {
        if (t == prevUnformatted) {
            return t;
        }
        prevUnformatted = t;
        return super.set_text(t);
    }

    override function set_font(f:h2d.Font): h2d.Font {
        super.set_font(f);
        @:privateAccess {
            if (f.defaultChar.width > 0) {
                var t = new h2d.Tile(null, 0, 0, 0, 0);
                var fc = new h2d.Font.FontChar(t, 0);
                font.defaultChar = fc;
            }
        }
        return font;
    }

    function set_textTransform(v:TextTransform): TextTransform {
        textTransform = v;
        prevUnformatted = null;
        if (v != null) {
            formatText = (s:String)->{
                ui.BaseGUI.allowOverRichIds = this.allowOverRichIds;
                if (tranformTextLast) {
                    s = h2d.HtmlText.defaultFormatText(s);
                }
                if ((s != null) && (s.length > 0)) {
                    s = Texts.applyTextTransform(s, v);
                }
                if (transformTextLast){
                    return s;
                }
                return h2d.HtmlText.defaultFormatText(s);
            };
        } else {
            formatText = (s:String)->{
                if (s.toLowerCase().indexOf("<UNFORMATABLE WORDS>") >= 0) {
                    trace("FmtText: No Transform formattext " + s);
                }
                ui.BaseGUI.allowOverRichIds = allowOverRichIds;
                return h2d.HtmlText.defaultFormatText(s);
            };
        }
        return textTransform;
    }

    public function getTooltip(id:String): ui.comp.TooltipComp {
        return null;
    }

    public function clearRefs() {
        refs = ui.BaseGUI.initRefs(refs);
    }

    override function onOverHyperlink(id:String) {
        if (!BaseGUI.freezeTooltips) {
            var refContent = getTooltip(id);
            gui.setTooltip(refContent, this, TooltipPosition.Left);
        }
    }

    function onOutHyperLink(id:String) {
        if (!BaseGUI.freezeTooltips) {
            gui.removeTooltip(this);
        }
    }

    override function loadFont(nane:String): h2d.Font {
        return BaseGUI.loadFontFace(font, name);
    }

    override function loadImage(url:String): h2d.Tile {
        var tile = BaseGUI.loadTextIcon(url);
        var minRatio = if ((iconSize/tile.height) >= (iconSize/tile.width)) {
            iconSize / tile.height;
        } else {
            iconSize / tile.width;
        };
        tile.scaleToSize(Math.round(tile.width)*minRatio, Math.round(tile.height)*minRatio);
        return tile;
    }
}