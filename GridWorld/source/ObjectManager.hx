package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class ObjectManager implements SpriteManager {
    private static inline var DURATION = 1;
    private static inline var X_OFFSET = 24;
    private static inline var Y_OFFSET = 24;

    private var tileSize:Int;
    private var simulator:Simulator;
    private var vehicles:HashMap<Vehicle, FlxSprite>;
    private var gems:HashMap<Gem, FlxSprite>;
    private var goals:HashMap<Goal, FlxSprite>;

    public function new(s:Simulator, tileSize:Int) {
        this.simulator = s;
        this.tileSize = tileSize;
        this.vehicles = new HashMap();
        this.gems = new HashMap();
        this.goals = new HashMap();
        makeSprites(this.vehicles, this.simulator.getVehicles(), FlxColor.CYAN);
        makeSprites(this.gems, this.simulator.getGems(), FlxColor.MAGENTA);
        makeSprites(this.goals, this.simulator.getGoals(), FlxColor.RED);
    }

    private function makeSprites(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>, color:FlxColor) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var sprite = new FlxSprite(o.x * tileSize + X_OFFSET, o.y * tileSize + Y_OFFSET);
            sprite.makeGraphic(this.tileSize, this.tileSize, color);
            map.set(o, sprite);
        }
    }

    public function getSprites():Array<FlxSprite> {
        var sprites = new Array();
        for (v in this.vehicles.keys()) {
            sprites.push(vehicles.get(v));
        }
        for (g in this.gems.keys()) {
            sprites.push(gems.get(g));
        }
        for (g in this.goals.keys()) {
            sprites.push(goals.get(g));
        }
        return sprites;
    }

    public function update() {
        updateSprite(this.vehicles, this.simulator.getVehicles());
        updateSprite(this.gems, this.simulator.getGems());
        updateSprite(this.goals, this.simulator.getGoals());
    }

    private function updateSprite(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var newX = o.x * tileSize + X_OFFSET;
            var newY = o.y * tileSize + Y_OFFSET;
            FlxTween.tween(map.get(o), {x: newX, y:newY}, DURATION);
            // FlxTween.angle(map.get(o))
        }
    }

    public function setSimulator(s:Dynamic) {
        this.simulator = s;
    }

    public function snap() {
        snapSprite(this.vehicles, this.simulator.getVehicles());
        snapSprite(this.gems, this.simulator.getGems());
        snapSprite(this.goals, this.simulator.getGoals());
    }

    private function snapSprite(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var newX = o.x * tileSize + X_OFFSET;
            var newY = o.y * tileSize + Y_OFFSET;
            map.get(o).setPosition(newX, newY);
        }
    }
}
