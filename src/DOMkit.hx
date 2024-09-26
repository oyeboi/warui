import h2d.domkit.BaseComponents.CustomParser;

class DOMkit {
    #if macro 
    public static function setup() {
        domkit.Macros.setDefaultParser("DOMkit.WaruiCssParser");

        domkit.Macros.registerComponentsPath("ui.$");
        domkit.Macros.registerComponentsPath("ui.comp.$Comp");
        domkit.Macros.registerComponentsPath("ui.win.$");
    }
    #end
}

class WaruiCssParser extends CustomParser {
    
}