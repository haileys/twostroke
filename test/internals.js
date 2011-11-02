test("undefined variable throws ReferenceError", function() {
	try {
		whatever;
		assert(false, "did not throw");
	} catch(e) {
		assert_equal(e.name, "ReferenceError");
	}
});

test("dereferencing null throws TypeError", function() {
	try {
		var x = null;
		x.foo;
		assert(false, "did not throw");
	} catch(e) {
		assert_equal(e.name, "TypeError");
	}
});