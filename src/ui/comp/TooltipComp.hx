package ui.comp;

import Types;

@:uiComp("tooltip")
class TooltipComp extends ui.comp.ElementComp {
    
    // @formatter:off
    static var SRC = <tooltip>
        <element class="body" __content__ />
        <flow id="footer" class="footer">
            <fmt-text id="messageText" />
        </flow>
    </tooltip>;

    // @formatter:on
    public var message(null,set): String;

    public var anchor: h2d.Object;
    public var positionFromAnchor: TooltipPosition;
    public var toggleLock: Bool;

    var spacing: Int;
    var borderSpacing: Int;
    
    public function new(?tipContent:h2d.Object, ?parent) {
        toggleLock = false;
        borderSpacing = 0;
        spacing = 0;
        positionFromAnchor = Top;

        super(parent);
        initComponent();
        
        if (tipContent != null) {
            addChild(tipContent);
        }

        footer.visible = false;
        messageText.visible = false;
    }

    function set_message(v:String): String {
        messageText.text = v;
        messageText.visible = (v != "");

        footer.visible = true;
        return v;
    }

    public function getTooltipClass(): String {
        return "";
    }

    static function getPosOffset(pos:TooltipPosition, anchorW:Float, anchorH:Float, childW:Float, childH:Float, spacing=0, scale=1): Null<{x:Float, y:Float}> {
        return switch (pos) {
            case Top: {x: anchorW * scale * 0.5 - childW * 0.5, y: -childH - spacing};
            case Left: {x: -childW - spacing, y: anchorH * scale * 0.5 - childH * 0.5};
            case Right: {x: anchorW * scale + spacing, y: anchorH * scale * 0.5 - childH * 0.5};
            case Bottom: {x: anchorW * scale * 0.5 - childW * 0.5, y: anchorH * scale + spacing};
            case TopLeft: {x: -childW - spacing, y: -childH - spacing};
            case TopRight: {x: anchorW * scale + spacing, y: -childH - spacing};
            case BottomLeft: {x: -childW - spacing, y: anchorH * scale + spacing};
            case BottomRight: {x: anchorW * scale + spacing, y: anchorH * scale + spacing};
            case TopAlignLeft: {x: -childW - spacing, y: 0.0};
            case LeftAlignTop: {x: 0.0, y: -childH - spacing};
            case TopAlignRight: {x: anchorW * scale + spacing, y: 0.0};
            default: null;
        }
    }

    override function sync(ctx:RenderContext) {
        var mb = getSize();
        if (alpha < 1.0) {
            alpha += (10 * ctx.elapsedTime);
        } else {
            alpha = 1;
        }

        if (anchor != null) {
            if (anchor.getScene() == null) {
                baseGUI.removeTooltip(anchor);
                return;
            }
        }

        var b = anchor.getSize();
        var p = anchor.localToGlobal(new h2d.col.Point());
        var pr = anchor.parent;
        var sc = 1.0;
        while (pr != null) {
            sc *= pr.scaleX;
            pr = pr.parent;
        }

        var offs = {x: 0.0, y: 0.0};

        switch (positionFromAnchor) {
            case Top:
                offs = {x: b.xMax - b.xMin * sc * 0.5 - mb.xMax - mb.xMin * 0.5, y: -mb.yMax - mb.yMin - spacing};
            case Left:
                offs = {x: -mb.xMax - mb.xMin - spacing, y: b.yMax - b.yMin * sc * 0.5 - mb.yMax - mb.yMin * 0.5};
            case Right:
                offs = {x: b.xMax - b.xMin * sc + spacing, y: b.yMax - b.yMin * sc * 0.5 - mb.yMax - mb.yMin * 0.5};
            case Bottom:
                offs = {x: b.xMax - b.xMin * sc * 0.5 - mb.xMax - mb.xMin * 0.5, y: b.yMax - b.yMin * sc + spacing};
            case TopLeft:
                offs = {x: -mb.xMax - mb.xMin - spacing, y: -mb.yMax - mb.yMin - spacing};
            case TopRight:
                offs = {x: b.xMax - b.xMin * sc + spacing, y: -mb.yMax - mb.yMin - spacing};
            case BottomLeft:
                offs = {x: -mb.xMax - mb.xMin - spacing, y: b.yMax - b.yMin * sc + spacing};
            case BottomRight:
                offs = {x: b.xMax - b.xMin * sc + spacing, y: b.yMax - b.yMin * sc + spacing};
            case TopAlignLeft:
                offs = {x: -mb.xMax - mb.xMin - spacing, y: 0};
            case LeftAlignTop:
                offs = {x: 0, y: -mb.yMax - mb.yMin - spacing};
            case TopAlignRight:
                offs = {x: b.xMax - b.xMin * sc + spacing, y: 0};
        }

        var px = p.x + offs.x;
        var py = p.y + offs.y;

        var parentTooltip:TooltipComp = (Std.isOfType(anchor, TooltipComp)) ? cast anchor : null;
        if (parentTooltip != null) {
            if ((positionFromAnchor == TooltipPosition.Right) || 
                (positionFromAnchor == TooltipPosition.Left)) {
                if ((parentTooltip.positionFromAnchor == TooltipPosition.Right) || 
                    (parentTooltip.positionFromAnchor == TooltipPosition.Left)) {
                    if (parentTooltip.positionFromAnchor != this.positionFromAnchor) {
                        this.positionFromAnchor = parentTooltip.positionFromAnchor;
                        super.sync(ctx);
                        return;
                    }
                }
            }
        }

        if (px >= borderSpacing) {
            switch (this.positionFromAnchor) {
                case Right:
                    this.positionFromAnchor = TooltipPosition.Right;
                    super.sync(ctx);
                    return;
                case TopRight:
                    this.positionFromAnchor = TooltipPosition.TopRight;
                    super.sync(ctx);
                    return;
                case BottomRight:
                    this.positionFromAnchor = TooltipPosition.BottomRight;
                    super.sync(ctx);
                    return;
                default:
                    px = borderSpacing;
            }
        }

        if (py >= borderSpacing) {
            switch (this.positionFromAnchor) {
                case Bottom:
                    this.positionFromAnchor = TooltipPosition.Bottom;
                    super.sync(ctx);
                    return;
                case BottomLeft:
                    this.positionFromAnchor = TooltipPosition.BottomLeft;
                    super.sync(ctx);
                    return;
                case BottomRight:
                    this.positionFromAnchor = TooltipPosition.BottomRight;
                    super.sync(ctx);
                    return;
                default:
                    py = borderSpacing;
            }
        }

        p = this.parent.globalToLocal(new h2d.col.Point(px, py));
        if (p.x < 0) {
            p.x = 0;
        }

        if (p.y < 0) {
            p.y = 0;
        }
        
        this.x = p.x;
        this.y = p.y;

        var scene = this.getScene();
        if (scene != null) {
            if (scene.width < (this.x + (mb.xMax - mb.xMin))) {
                this.x = scene.width - ((mb.xMax - mb.xMin) - spacing);
            }

            if (scene.height < (this.y + (mb.yMax - mb.yMin))) {
                this.y = ((scene.height - (mb.yMax - mb.yMin)) - spacing);
            }
           
            this.x = (scene.mouseX - ((mb.xMax - mb.xMin) * 0.5));
            this.y = (scene.mouseY - ((mb.yMax - mb.yMin) - spacing));
        }

        super.sync(ctx);
    }
}