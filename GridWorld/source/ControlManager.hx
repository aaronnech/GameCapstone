package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;

class ControlManager {
    private var parentState:PlayState;
    private var simulator:Simulator;
    private var tileSize:Int;
    private var colors:Array<Color>;
    private var buttons:HashMap<Color, Array<ControlButton>>;
    private var controls:HashMap<Color, Array<Control>>;

    private var ordering:Array<Control>;
    private var highlighted_files:Array<String>;
    private var normal_files:Array<String>;

    public function new(
        tileSize:Int,
        colors:Array<Color>,
        bannedControls:Array<Control>,
        simulator:Simulator,
        parent:PlayState
    ) {
        this.parentState = parent;
        this.colors = colors;
        this.tileSize = tileSize;
        this.simulator = simulator;
        this.buttons = new HashMap();
        this.controls = new HashMap();

        for (i in 0...colors.length) {
            this.buttons.set(colors[i], []);
            this.controls.set(colors[i], []);

            var trackX = FlxG.width - tileSize * (colors.length - i);
            var track = new FlxSprite(trackX, 0);
            var color = 0x8800BFFF; // blue
            if (colors[i].color == "red") {
                color = 0x88E3C934; // yellow
            }
            track.makeGraphic(tileSize, FlxG.height, color);
            this.parentState.add(track);
        }

        this.makeButtons(bannedControls);

        this.ordering = new Array();
        this.ordering.push(Control.FORWARD);
        this.ordering.push(Control.LEFT);
        this.ordering.push(Control.RIGHT);
        this.ordering.push(Control.PAUSE);

        this.highlighted_files = new Array();
        this.highlighted_files.push("assets/images/forward_highlighted.png");
        this.highlighted_files.push("assets/images/left_highlighted.png");
        this.highlighted_files.push("assets/images/right_highlighted.png");
        this.highlighted_files.push("assets/images/pause_highlighted.png");

        this.normal_files = new Array();
        this.normal_files.push("assets/images/forward.png");
        this.normal_files.push("assets/images/left.png");
        this.normal_files.push("assets/images/right.png");
        this.normal_files.push("assets/images/pause.png");
    }

    private function makeButtons(bannedControls:Array<Control>) {
        FlxG.plugins.add(new flixel.addons.plugin.FlxMouseControl());

        var buttonY = FlxG.height - 70;
        if (bannedControls.indexOf(Control.FORWARD) == -1) {
            var forward = new ControlButton(170, buttonY, "assets/images/forward.png", this, Control.FORWARD);
            this.parentState.add(forward);
        }
        if (bannedControls.indexOf(Control.LEFT) == -1) {
            var left = new ControlButton(100, buttonY, "assets/images/left.png", this, Control.LEFT);
            this.parentState.add(left);
        }
        if (bannedControls.indexOf(Control.RIGHT) == -1) {
            var right = new ControlButton(240, buttonY, "assets/images/right.png", this, Control.RIGHT);
            this.parentState.add(right);
        }
        if (bannedControls.indexOf(Control.PAUSE) == -1) {
            var pause = new ControlButton(310, buttonY, "assets/images/pause.png", this, Control.PAUSE);
            this.parentState.add(pause);
        }
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
                    button.x = startPx + i * tileSize + 1;
                    break;
                }
            }

            // TODO: Sort Y position of button
            // put at end for now
            var colorButtons = buttons.get(button.trackColor);
            var colorControls = controls.get(button.trackColor);
            button.y = colorButtons.length * tileSize;
            button.disableMouseDrag();
            colorButtons.push(button);
            colorControls.push(button.control);
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

    public function updateControlHighlights() {
        var controlIndices = this.simulator.getControlIndices();
        for (color in this.buttons.keys()) {
            var selectedTrack = buttons.get(color);
            if (selectedTrack.length == 0) {
                continue;
            }

            var controlIndex = controlIndices.get(color);
            var buttonToHighlight = selectedTrack[controlIndex];
            buttonToHighlight.loadGraphic(
                this.highlighted_files[this.ordering.indexOf(buttonToHighlight.control)]
            );

            if (selectedTrack.length > 1) {
                // Unselect the previous one
                var index = (controlIndex == 0) ? selectedTrack.length - 1 : controlIndex - 1;
                var buttonToReset = selectedTrack[index];
                buttonToReset.loadGraphic(
                    this.normal_files[this.ordering.indexOf(buttonToReset.control)]
                );
            }
        }
    }

    public function resetControlHighlights() {
        // Turn the highlights off
        for (color in this.buttons.keys()) {
            var selectedTrack = buttons.get(color);
            for (i in 0...selectedTrack.length) {
                var buttonToReset = selectedTrack[i];
                buttonToReset.loadGraphic(
                    this.normal_files[this.ordering.indexOf(buttonToReset.control)]
                );
            }
        }
    }

    public function setSimulator(s:Dynamic):Void {
        this.simulator = s;
    }
}
