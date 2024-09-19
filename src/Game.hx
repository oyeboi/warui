class Game {
    public static var inst(default,null): Game;

    public var dt(default,null): Float;

    public function new() {
        inst = this;
    }
}