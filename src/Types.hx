enum GUIFonts {
	Default;
	Bold;
	Italic;
}

enum EReason {
    Do(f:Void->Void);
    Success;
    Invalid;
    Multiple(a:Array<EReason>);
    Cooldown(ms:Float);
    Skip;
    Dismiss;
    
    PlayerNotReady;
    NotImplemented;
    NotSupported;
}

enum TooltipPosition {
    Top;
    Left;
    Right;
    Bottom;
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
    TopAlignLeft;
    LeftAlignTop;
    TopAlignRight;
}

typedef TooltipRefs = {};