test("hasOwnProperty", function() {
	assert_equal(console.hasOwnProperty("log"), true);
	assert_equal("test".hasOwnProperty("length"), false);
	assert_equal("test".hasOwnProperty(0), true);
	assert_equal("test".hasOwnProperty(99), false);
	assert_equal([1].hasOwnProperty(0), true);
	assert_equal([1].hasOwnProperty(99), false);
	assert_equal({ a: 1 }.hasOwnProperty("a"), true);
});

test("isPrototypeOf", function() {
	assert_equal(Object.prototype.isPrototypeOf(console), true);
	assert_equal(Object.isPrototypeOf(console), false);
	assert_equal(Number.prototype.isPrototypeOf(new Number(1)), true);
	assert_equal(Number.prototype.isPrototypeOf(1), false);
	assert_equal(String.prototype.isPrototypeOf(new String("hi")), true);
	assert_equal(String.prototype.isPrototypeOf("hi"), false);
});