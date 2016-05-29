class GUID {
	private static var CHARS : Array<String> = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".split("");

	static public function gen() {
		var chars = CHARS, uuid = new Array(), rnd = 0, r;
		for (i in 0...36) {
			if (i==8 || i==13 ||  i==18 || i==23) {
				uuid[i] = "-";
			} else if (i==14) {
				uuid[i] = "4";
			} else {
				if (rnd <= 0x02) rnd = 0x2000000 + Std.parseInt( Std.string(Math.random() * Std.parseFloat(Std.string(0x1000000)))) | 0;
				r = rnd & 0xf;
				rnd = rnd >> 4;
				uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
			}
		}
		return uuid.join("");
	}
}