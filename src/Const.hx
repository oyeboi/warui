class Const {

    public static final REGULAR_UPDATE_DT: Float = 0.016667;

    // Font Sizes
    public static final SMALL_FONT_SIZE:Int = 8;
    public static final REG_FONT_SIZE:Int = 16;
    public static final LARGE_FONT_SIZE:Int = 24;

    // Custom Fonts
    public static final FONT_CUTIVE_MONO:String = "CutiveMono-Regular";
    public static final FONT_DANCING_SCRIPT:String = "DancingScript";

    // Preferenecs
    public static var PREFS: {
        keepTooltips: Bool,
    };

    public static final BUILD: String = #if debug "dev" #else "release" #end;
}