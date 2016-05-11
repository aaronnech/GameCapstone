package;

import haxe.ds.HashMap;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.math.FlxRect;

import flixel.addons.plugin.FlxMouseControl;

class ControlManager {
    public var trackLeftmostX:Int;
    public var tileSize:Int;

    private var trackHeight:Int;
    private var parentState:PlayState;
    private var simulator:Simulator;
    private var colors:Array<Color>;
    private var buttons:HashMap<Color, Array<ControlButton>>;
    private var controls:HashMap<Color, Array<Control>>;

    private var ordering:Array<Control>;
    private var highlighted_files:Array<String>;
    private var normal_files:Array<String>;

    // Keeps track of where on the tracks the mouse is hovering over. For every
    // <K, V> pair, if V = -1, then the mouse was not previously on the K track.
    private var mouseOverTrack:HashMap<Color, Int>;

    public function new(
        tileSize:Int,
        height:Int,
        colors:Array<Color>,
        bannedControls:Array<Control>,
        simulator:Simulator,
        parent:PlayState
    ) {
        this.trackLeftmostX = FlxG.width - colors.length * tileSize;
        this.parentState = parent;
        this.colors = colors;
        this.trackHeight = height;
        this.tileSize = tileSize;
        this.simulator = simulator;
        this.buttons = new HashMap();
        this.controls = new HashMap();
        this.mouseOverTrack = new HashMap();

        for (i in 0...colors.length) {
            this.buttons.set(colors[i], []);
            this.controls.set(colors[i], []);
            this.mouseOverTrack.set(colors[i], -1);

            // Make tracks
            var trackX = FlxG.width - tileSize * (colors.length - i);
            var track = new FlxTilemap();
            var img = "assets/images/";
            if (colors[i].color == "blue") {
                img += "bluetrack.png";
            } else if (colors[i].color == "red") {
                img += "yellowtrack.png";
            }
            track.loadMapFrom2DArray([for (_ in 0...this.trackHeight) [0]], img, tileSize, tileSize, FlxTilemapAutoTiling.OFF, 0, 0);
            track.setPosition(trackX, 0);
            track.alpha = 1;
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

    public function duplicateButton(button:ControlButton) {
        this.parentState.add(button.copy());
    }

    public function dropButton(button:ControlButton, mouseX:Int, mouseY:Int) {
        // determine where button was dropped and update array
        if (mouseX < this.trackLeftmostX) {
            AnalyticsAPI.emitEvent('click', 'playstate', 'delete-sequence',
                this.ordering.indexOf(button.control));
            button.destroy();
        } else {
            // Figure out which track this button is being dropped onto.
            button.trackColor = this.getTrackColorUnderMouse(mouseX, mouseY);
            button.x = this.trackLeftmostX + colors.indexOf(button.trackColor) * tileSize + 1;

            var tileY = Math.floor(mouseY / this.tileSize);
            this.addControl(button.trackColor, button, button.control, tileY);
        }

        // Clear mouse hover data
        for (color in this.colors) {
            this.mouseOverTrack.set(color, -1);
        }
    }

    // Add control to end if index > length.
    public function addControl(color:Color, button:ControlButton, control:Control, index:Int) {
        AnalyticsAPI.emitEvent('click', 'playstate', 'add-sequence',
                this.ordering.indexOf(button.control));
        var colorButtons = this.buttons.get(color);
        var colorControls = this.controls.get(color);
        if (index > colorButtons.length) {
            index = colorButtons.length;
        }
        button.putOnTrack(index);
        button.y = index * tileSize;
        for (i in index...colorButtons.length) {
            colorButtons[i].indexOnTrack += 1;
        }
        colorButtons.insert(index, button);
        colorControls.insert(index, control);
        this.repositionButtons(color);
    }

    public function removeControl(color:Color, index:Int) {
        var colorButtons = this.buttons.get(color);
        var colorControls = this.controls.get(color);
        colorButtons.splice(index, 1);
        colorControls.splice(index, 1);
        for (i in index...colorButtons.length) {
            colorButtons[i].indexOnTrack -= 1;
        }
        this.shiftButtonsUp(index, color);
    }

    private function shiftButtonsUp(i:Int, color:Color) {
        shiftButtons(i, color, -this.tileSize);
    }

    private function shiftButtonsDown(i:Int, color:Color) {
        shiftButtons(i, color, this.tileSize);
    }

    private function shiftButtons(i:Int, color:Color, shift:Int) {
        var colorButtons = this.buttons.get(color);
        for (x in i...colorButtons.length) {
            colorButtons[x].y += shift;
        }
    }

    private function repositionButtons(color:Color) {
        var colorButtons = this.buttons.get(color);
        for (i in 0...colorButtons.length) {
            colorButtons[i].y = i * this.tileSize;
        }
    }

    public function checkMouseHover(mouseX:Int, mouseY:Int) {
        var currentTrack = this.getTrackColorUnderMouse(mouseX, mouseY);
        var tileY = Math.floor(mouseY / this.tileSize);
        for (color in this.colors) {
            var trackIndex = this.mouseOverTrack.get(color);
            if (color == currentTrack) {
                if (trackIndex != tileY) {
                    // Button's Y position changed
                    if (trackIndex != -1) {
                        // Undo previous shift
                        this.shiftButtonsUp(trackIndex, currentTrack);
                    }
                    // Do new shift
                    this.shiftButtonsDown(tileY, currentTrack);
                    this.mouseOverTrack.set(currentTrack, tileY);
                }
            } else if (trackIndex != -1) {
                // Undo this color's shifts
                this.shiftButtonsUp(trackIndex, color);
                this.mouseOverTrack.set(color, -1);
            } else if (currentTrack == null) {
                // Clear mouse hover data
                this.mouseOverTrack.set(color, -1);
            }
        }
    }

    private function getTrackColorUnderMouse(mouseX:Int, mouseY:Int) {
        if (mouseX > FlxG.width) {
            return colors[colors.length - 1];
        } else if (mouseX >= this.trackLeftmostX) {
            for (i in 0...this.colors.length) {
                if (mouseX < this.trackLeftmostX + (i + 1) * tileSize) {
                    return colors[i];
                }
            }
        }
        return null;
    }

    public function getControls():HashMap<Color, Array<Control>> {
        return this.controls;
    }

    public function hasControls() {
        var numControls = 0;
        for (color in this.colors) {
            numControls += this.controls.get(color).length;
        }
        return numControls > 0;
    }

    public function enableControls() {
        FlxMouseControl.mouseZone = FlxG.worldBounds;
    }

    public function disableControls() {
        FlxMouseControl.mouseZone = new FlxRect(10, FlxG.height - 70, 70, 70);
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
