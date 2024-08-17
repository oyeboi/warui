import h2d.domkit.BaseComponents.CustomParser;

class DOMkit {
    #if macro 
    public static function setup() {
        domkit.Macros.setDefaultParser("DOMkit.WaruiCssParser");

        domkit.Macros.registerComponentsPath("ui.$");
    }
    #end
}

class WaruiCssParser extends CustomParser {
    
}