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