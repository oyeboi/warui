import h2d.domkit.BaseComponents.CustomParser;

class DOMkit {
    #if macro 
    public static function setup() {
        domkit.Macros.setDefaultParser("DOMkit.CssParser");
        domkit.Macros.registerComponentsPath("$");
        domkit.Macros.registerComponentsPath("ui.comp.$Comp");
        domkit.Macros.registerComponentsPath("ui.menu.$");
        domkit.Macros.registerComponentsPath("ui.win.$");
    }
    #end
}

class WaruiCssParser extends CustomParser {
    
}