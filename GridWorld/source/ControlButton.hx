package;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxExtendedSprite;

import Color;

class ControlButton extends FlxExtendedSprite {
    public static var SNAP_GRID_SIZE = 48;

    public var control:Control;
    public var trackColor:Color;
    private var manager:ControlManager;
    private var simpleGraphic:FlxGraphicAsset;

    public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, manager:ControlManager, control:Control) {
        super(X, Y, SimpleGraphic);
        // FlxG.plugins.add(new flixel.addons.plugin.FlxMouseControl());
        this.manager = manager;
        this.control = control;
        this.simpleGraphic = SimpleGraphic;

        this.mouseStartDragCallback = startDragCallback;
        this.mouseStopDragCallback = stopDragCallback;
        enableMouseDrag();
    }

    public function startDragCallback(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.pickUpButton(this);
    }

    public function stopDragCallback(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.dropButton(this, FlxG.mouse.x, FlxG.mouse.y);
        this.mousePressedCallback = onClick;
    }

    public function onClick(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.destroyButton(this);
    }

    public function copy():ControlButton {
        return new ControlButton(this.x, this.y, this.simpleGraphic, this.manager, this.control);
    }
}
