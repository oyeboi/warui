class Main extends hxd.App {
    public static var inst: Main;

    static function main() {
        new Main();
    }

    override function init() {
        inst = this;

        #if hl
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        engine.backgroundColor = 0x6495ed;
        hxd.Window.getInstance().addEventTarget(onWindowEvent);
    }

    function onWindowEvent(ev:hxd.Event) {
        switch (ev.kind) {
            case EPush:
            case ERelease:
            case EMove:
            case EOver: onMouseEnter(ev);
            case EOut: onMouseLeave(ev);
            case EWheel:
            case EFocus: onWindowFocus(ev);
            case EFocusLost: onWindowBlur(ev);
            case EKeyDown:
            case EKeyUp:
            case EReleaseOutside:
            case ETextInput:
            case ECheck:
            default:
                // noop
        }
    }

    function onMouseEnter(e:hxd.Event) {}
    function onMouseLeave(e:hxd.Event) {}
    function onWindowFocus(e:hxd.Event) {}
    function onWindowBlur(e:hxd.Event) {}

    override function dispose() {
        super.dispose();
        hxd.Window.getInstance().removeEventTarget(onWindowEvent);
    }

    override function onResize() {
        super.onResize();
    }

    override function update(deltaTime) {
        super.update(deltaTime);
    }
}