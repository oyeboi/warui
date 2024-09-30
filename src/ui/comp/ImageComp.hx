package ui.comp;

@:uiComp("image")
class ImageComp extends ui.comp.ElementComp {
    
    // @formatter:off
    static var SRC = <image>
        <bitmap id="bitmap" />
    </image>;

    // @formatter:on
    var icon(default,set): String;
    var src(default,set): h2d.Tile;
    var colorAdd: h3d.Vector4;
    var colorMultiply: h3d.Vector4;

    public function new(?kind:String, ?tile:h2d.Tile, ?parent:h2d.Object) {

        super(parent);
        initComponent();

        if (tile != null) {
            src = tile;
        }

        if (kind != null) {
            dom.setClasses("icon-"+kind);
            icon = kind;
        }

        colorAdd = new h3d.Vector4();
    }

    function set_icon(i:String): String {
        src = ui.BaseGUI.getIcon(i);
        return i;
    }

    function set_src(t:h2d.Tile): h2d.Tile {
        if (t == null) {
            bitmap.visible = false;
        } else {
            bitmap.visible = true;
            bitmap.tile = t;
        }
        src = t;
        return t;
    }

    function setColorAdd(color:Int) {
        colorAdd.setColor(color);
    }

    function setColorAddVec(v:h3d.Vector4) {
        colorAdd.load(v);
    }

    function setColorMultiply(v:Int) {
        if (colorMultiply == null) {
            colorMultiply = new h3d.Vector4();
        }
        colorMultiply *= v;
    }
}