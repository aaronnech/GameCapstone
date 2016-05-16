package;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxExtendedSprite;

import Color;

class ControlButton extends FlxExtendedSprite {
    public static var SNAP_GRID_SIZE = 48;

    public var control:Control;
    public var trackColor:Color;
    public var indexOnTrack:Int; // -1 means button is not on track
    private var manager:ControlManager;
    private var simpleGraphic:FlxGraphicAsset;

    public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, manager:ControlManager, control:Control) {
        super(X, Y, SimpleGraphic);
        this.manager = manager;
        this.control = control;
        this.indexOnTrack = -1;
        this.simpleGraphic = SimpleGraphic;

        this.mouseStartDragCallback = duplicateButton;
        this.mouseStopDragCallback = stopDragCallback;
        this.enableMouseDrag();
    }

    public function putOnTrack(index:Int) {
        this.indexOnTrack = index;
        this.mouseStartDragCallback = moveButton;
    }

    public function duplicateButton(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.duplicateButton(this);
    }

    public function moveButton(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.removeControl(trackColor, this.indexOnTrack);
    }

    public function stopDragCallback(obj:FlxExtendedSprite, x:Int, y:Int) {
        this.manager.dropButton(this, FlxG.mouse.x, FlxG.mouse.y);
    }

    public function copy():ControlButton {
        return new ControlButton(this.x, this.y, this.simpleGraphic, this.manager, this.control);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (this.draggable && this.isDragged) {
            this.manager.checkMouseHover(FlxG.mouse.x, FlxG.mouse.y);
        }
    }
}
