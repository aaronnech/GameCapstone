package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;

// Managers one track
class ControlManager {
    private var parentState:PlayState;
    private var simulator:Simulator;
    private var tileSize:Int;
    private var height:Int; // number of slots per control
    private var colors:Array<Color>;
    private var buttons:HashMap<Color, Array<ControlButton>>;
    private var controls:HashMap<Color, Array<Control>>;

    public function new(tileSize:Int, height:Int, colors:Array<Color>, simulator:Simulator, parent:PlayState) {
        this.parentState = parent;
        this.colors = colors;
        this.tileSize = tileSize;
        this.simulator = simulator;
        this.buttons = new HashMap();
        this.controls = new HashMap();

        for (color in colors) {
            this.buttons.set(color, []);
            this.controls.set(color, []);
        }

        FlxG.plugins.add(new flixel.addons.plugin.FlxMouseControl());

        var buttonY = FlxG.height - 70;
        var forward = new ControlButton(170, buttonY, "assets/images/forward.png", this, Control.FORWARD);
        var left = new ControlButton(100, buttonY, "assets/images/left.png", this, Control.LEFT);
        var right = new ControlButton(240, buttonY, "assets/images/right.png", this, Control.RIGHT);
        var pause = new ControlButton(310, buttonY, "assets/images/pause.png", this, Control.PAUSE);

        this.parentState.add(forward);
        this.parentState.add(left);
        this.parentState.add(right);
        this.parentState.add(pause);
    }

    public function pickUpButton(button:ControlButton) {
        this.parentState.add(button.copy());
    }

    public function dropButton(button:ControlButton, mouseX:Int, mouseY:Int) {
        // determine where button was dropped and update array
        var startPx = FlxG.width - colors.length * tileSize;
        if (mouseX < startPx) {
            button.destroy();
        } else {
            // Figure out which track this button is being dropped onto.
            for (i in 0...colors.length) {
                if (mouseX < startPx + (i + 1) * tileSize) {
                    button.trackColor = colors[i];
                    button.x = startPx + i * tileSize + 2;
                }
            }

            // TODO: Sort Y position of button
            // put at end for now
            var colorButtons = buttons.get(button.trackColor);
            button.y = colorButtons.length * tileSize;
            button.disableMouseDrag();
            colorButtons.push(button);
            controls.get(button.trackColor).push(button.control);
        }
    }

    public function destroyButton(button:ControlButton) {
        var colorButtons = this.buttons.get(button.trackColor);
        var index = Math.floor(button.y / tileSize);
        colorButtons.splice(index, 1);
        controls.get(button.trackColor).splice(index, 1);
        button.destroy();
        shiftButtons(index, colorButtons);
    }

    private function shiftButtons(i:Int, buttons:Array<ControlButton>) {
        for (x in i...buttons.length) {
            buttons[x].y -= tileSize;
        }
    }

    public function getControls():HashMap<Color, Array<Control>> {
        return this.controls;
    }

    public function update() {
        simulator.getControlIndices(); // Hashmap<Color, Int>
    }

    public function setSimulator(s:Dynamic):Void {
        this.simulator = s;
    }
}
