package ui.comp;

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

    public function new(?parent) {
        super(parent);
        initComponent();
        
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

}