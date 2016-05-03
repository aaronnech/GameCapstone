package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class VehicleManager implements SpriteManager {
    private static inline var DURATION = 2;
    private static inline var X_OFFSET = 10;
    private static inline var Y_OFFSET = 10;

    private var tileSize:Int;
    private var simulator:Simulator;
    // private var vehicles:Array<Vehicle>;
    private var sprites:HashMap<Vehicle, FlxSprite>;

    public function new(s:Simulator, tileSize:Int) {
        this.simulator = s;
        this.tileSize = tileSize;
        this.sprites = new HashMap<Vehicle, FlxSprite>();
        var vehicles = this.simulator.getVehicles();
        for (i in 0...vehicles.length) {
            var v = vehicles[i];
            sprites.set(v, new FlxSprite(v.x * tileSize + X_OFFSET, v.y * tileSize + Y_OFFSET));
        }
    }

    override public function getSprites():Array<FlxSprite> {
        return [for (k in this.sprites.keys()) this.sprites.get(k)];
    }

    override public function update(){
        var vehicles = this.simulator.getVehicles();
        for (i in 0...vehicles.length) {
            var v = vehicles[i];
            var newX = v.x * tileSize + X_OFFSET;
            var newY = v.x * tileSize + Y_OFFSET;
            FlxTween.tween(this.sprites.get(v), {x: newX, y:newY}, DURATION);
        }
    }

    override public function setSimulator(s:Simulator) {
        this.simulator = s;
    }
}
