package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class ObjectManager implements SpriteManager {
    private static inline var X_OFFSET = 0;
    private static inline var Y_OFFSET = 0;

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

            // Set direction of vehicle sprites.
            if (Std.is(o, Vehicle)) {
                sprite.facing = getDirection(o.direction);
            }

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
        haxe.Timer.delay(checkGoal, Std.int(PlayState.TICK_TIME * 1000));
    }

    private function updateSprite(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var newX = o.x * tileSize + X_OFFSET;
            var newY = o.y * tileSize + Y_OFFSET;
            var sprite = map.get(o);
            FlxTween.tween(sprite, {x: newX, y:newY}, PlayState.TICK_TIME / 2);

            // Rotate vehicle
            if (Std.is(o, Vehicle) && sprite.facing != getDirection(o.direction)) {
                var diff = o.direction;
                switch sprite.facing {
                    case FlxObject.UP: // diff -= 0;
                    case FlxObject.RIGHT: diff -= 1;
                    case FlxObject.DOWN: diff -= 2;
                    case FlxObject.LEFT: diff -= 3;
                }

                if (diff == 1 || diff == -3) {
                    // Turn right
                    FlxTween.angle(sprite, 0, 90, PlayState.TICK_TIME / 2);
                } else if (diff == -1 || diff == 3) {
                    // Turn left
                    FlxTween.angle(sprite, 0, -90, PlayState.TICK_TIME / 2);
                }
                sprite.facing = getDirection(o.direction);
            }
        }
    }

    private function getDirection(i:Int):Int {
        switch i {
            case 0: return FlxObject.UP;
            case 1: return FlxObject.RIGHT;
            case 2: return FlxObject.DOWN;
            case 3: return FlxObject.LEFT;
            default: return -1;
        }
    }

    private function checkGoal() {
        var gemObjs = this.simulator.getGems();
        for (i in 0...gemObjs.length) {
            var gem = gemObjs[i];
            if (gem.isInGoal) {
                this.gems.get(gem).visible = false;
                this.goals.get(gem.parentGoal).visible = false;
            }
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
            var sprite = map.get(o);
            sprite.setPosition(newX, newY);

            if (Std.is(o, Vehicle)) {
                sprite.facing = getDirection(o.direction);
            }

            sprite.visible = true;
        }
    }
}
