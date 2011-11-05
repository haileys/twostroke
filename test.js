var	sys	= require("sys"),
	fs	= require("fs");

var ESC = String.fromCharCode(27);

fs.readdirSync("test/").map(function(test) { return "test/" + test; }).forEach(function(test) {
	try {
		console.log("%s[1;37m%s%s[0m", ESC, test, ESC);
		var src = fs.readFileSync(test, "utf-8");
		var assert, assert_equal;
		var test = function(name, callback) {
			assert = function(t, msg) {
				if(!t) {
					throw name + "\n      " + msg;
				}
			};
			assert_equal = function(a, b, msg) {
				if(a !== b) {
					throw name + "\n      " + "Assertion failed: <" + a.toString() + "> !== <" + b.toString() + ">";
				}
			}
			console.log("    %s[32m PASS%s[0m %s", ESC, ESC, name);
		};
		eval(src);
	} catch(ex) {
		if(typeof ex === "string") {
			console.log("    %s[31m FAIL%s[0m%s", ESC, ESC, ex);
		} else {
			console.log("    %s[33mERROR%s[0m%s", ESC, ESC, ex.toString());
		}
	}
});