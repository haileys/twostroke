test("simple expressions", function() {
	assert_equal(3, eval("1 + 2"));
	assert_equal("hello", eval("\"hello\""));
	assert_equal("hello", eval("eval(\"\\\"hello\\\"\")"));
});

test("captures local variables", function() {
	var x = 123;
	assert_equal(123, eval("x"));
	(function() {
		var x = 456;
		assert_equal(456, eval("x"));
	})();
});

test("variables declared inside eval visible from outside", function() {
	eval("var inside = true");
	assert_equal("boolean", typeof inside);
});

test("captures same this value", function() {
	function foo() {
		assert_equal(7, eval("Number(this)"));
	}
	foo.call(7);
});

test("syntax error throws SyntaxError", function() {
	try {
		eval("!");
	} catch(e) {
		assert(e instanceof SyntaxError);
		return;
	}
	assert(false, "did not throw!");
});