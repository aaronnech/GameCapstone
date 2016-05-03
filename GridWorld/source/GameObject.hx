package;

class GameObject {
	public var id:Int;

	public function new(id:Int) {
		this.id = id;
	}

    public function hashCode():Int {
        return this.id;
    }
}
