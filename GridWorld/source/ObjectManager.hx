package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;

class ObjectManager implements SpriteManager {
    public var xOffset:Int = 0;
    public var yOffset:Int = 0;

    private var tileSize:Int;
    private var simulator:Simulator;
    private var vehicles:HashMap<Vehicle, FlxSprite>;
    private var gems:HashMap<Gem, FlxSprite>;
    private var goals:HashMap<Goal, FlxSprite>;
    private var tweens:Array<FlxTween>;

    private var gemSound:FlxSound;

    public function new(s:Simulator, tileSize:Int) {
        this.simulator = s;
        this.tileSize = tileSize;
        this.vehicles = new HashMap();
        this.gems = new HashMap();
        this.goals = new HashMap();
        this.tweens = new Array<FlxTween>();
        this.gemSound = FlxG.sound.load("assets/sounds/gemingoal.wav");
    }

    public function generate() {
        makeSprites(this.vehicles, this.simulator.getVehicles(), FlxColor.CYAN);
        makeSprites(this.gems, this.simulator.getGems(), FlxColor.MAGENTA);
        makeSprites(this.goals, this.simulator.getGoals(), FlxColor.RED);
    }

    private function makeSprites(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>, color:FlxColor) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var sprite = new FlxSprite(o.x * tileSize + xOffset, o.y * tileSize + yOffset);

            // Set direction of vehicle sprites.
            if (Std.is(o, Vehicle)) {
                sprite.facing = getDirection(o.direction);
                sprite.angle = getFaceAngle(getDirection(o.direction));
                if (o.color.color == 'blue') {
                    sprite.loadGraphic('assets/images/bluedoser.png');
                } else if (o.color.color == 'red') {
                    sprite.loadGraphic('assets/images/yellowdoser.png');
                }
            } else if (Std.is(o, Gem)) {
                if (o.color.color == 'blue') {
                    sprite.loadGraphic('assets/images/bluegem.png');
                } else if (o.color.color == 'red') {
                    sprite.loadGraphic('assets/images/yellowgem.png');
                }
            } else if (Std.is(o, Goal)) {
                if (o.color.color == 'blue') {
                    sprite.loadGraphic('assets/images/blueflag.png');
                } else if (o.color.color == 'red') {
                    sprite.loadGraphic('assets/images/yellowflag.png');
                }
            }

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
        this.tweens = new Array<FlxTween>();
        updateSprite(this.vehicles, this.simulator.getVehicles());
        updateSprite(this.gems, this.simulator.getGems());
        updateSprite(this.goals, this.simulator.getGoals());
        haxe.Timer.delay(checkGoal, Std.int(PlayState.TICK_TIME * 1000));
    }

    private function updateSprite(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var newX = o.x * tileSize + xOffset;
            var newY = o.y * tileSize + yOffset;
            var sprite = map.get(o);
            tweens.push(FlxTween.tween(sprite, {x: newX, y:newY}, PlayState.TICK_TIME / 2));

            // Rotate vehicle
            if (Std.is(o, Vehicle) && sprite.facing != getDirection(o.direction)) {
                var diff = o.direction;
                switch sprite.facing {
                    case FlxObject.UP: // diff -= 0;
                    case FlxObject.RIGHT: diff -= 1;
                    case FlxObject.DOWN: diff -= 2;
                    case FlxObject.LEFT: diff -= 3;
                }
                var from = this.getFaceAngle(sprite.facing);

                if (diff == 1 || diff == -3) {
                    // Turn right
                    tweens.push(FlxTween.angle(sprite, from, from + 90, PlayState.TICK_TIME / 2));
                } else if (diff == -1 || diff == 3) {
                    // Turn left
                    tweens.push(FlxTween.angle(sprite, from, from - 90, PlayState.TICK_TIME / 2));
                }
                sprite.facing = getDirection(o.direction);
            }
        }
    }

    private function getFaceAngle(ang:Int): Int {
        switch ang {
            case FlxObject.UP: return 90;
            case FlxObject.RIGHT: return 180;
            case FlxObject.DOWN: return 270;
            case FlxObject.LEFT: return 0;
        }

        return 0;
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
                var gemVisible = this.gems.get(gem).visible;
                if (gemVisible) {
                    this.gemSound.play();
                    this.gems.get(gem).visible = false;
                    this.goals.get(gem.parentGoal).visible = false;
                }
            }
        }
    }

    public function setSimulator(s:Dynamic) {
        this.simulator = s;
    }

    public function snap() {
        for (tw in tweens) {
            tw.cancel();
        }
        this.tweens = new Array<FlxTween>();
        snapSprite(this.vehicles, this.simulator.getVehicles());
        snapSprite(this.gems, this.simulator.getGems());
        snapSprite(this.goals, this.simulator.getGoals());
    }

    private function snapSprite(map:HashMap<Dynamic, FlxSprite>, obj:Array<Dynamic>) {
        for (i in 0...obj.length) {
            var o = obj[i];
            var newX = o.x * tileSize + xOffset;
            var newY = o.y * tileSize + yOffset;
            var sprite = map.get(o);
            sprite.setPosition(newX, newY);

            if (Std.is(o, Vehicle)) {
                sprite.facing = getDirection(o.direction);
                sprite.angle = getFaceAngle(getDirection(o.direction));
            }

            sprite.visible = true;
        }
    }
}
