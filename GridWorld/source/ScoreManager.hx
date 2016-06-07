import haxe.Serializer;
import haxe.Unserializer;
import flixel.util.FlxSave;

class ScoreManager {
    private var serializer:Serializer;
    private var save:FlxSave;
    private var levels:Array<Level>;

    public function new(levels:Array<Level>) {
        this.levels = levels;
        this.serializer = new Serializer();

        this.save = new FlxSave();
        this.save.bind("Game");

        trace(levels.length);
        if (!this.save.data.scores) {
            this.save.data.scores = [ for (_ in 0...levels.length) 0 ];
        }
    }

    public function setLevelScore(levelIndex:Int, score:Int) {
        if (score > this.save.data.scores[levelIndex]) {
            this.save.data.scores[levelIndex] = score;
            trace(this.save.data.scores);
            this.save.flush();
        }
    }

    public function getLevelScore(levelIndex:Int) {
        return this.save.data.scores[levelIndex];
    }

    public function getTotalScore() {
        var sum = 0;
        for (i in 0...this.levels.length - 1) {
            sum += Std.int(this.save.data.scores[i]);
        }
        return sum;
    }
}
