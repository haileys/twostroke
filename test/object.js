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
	assert_equal(Object.isPrototypeOf(console, "log"), true);
	assert_equal(Object.hasOwnProperty("test", "length"), false);
	assert_equal(Object.hasOwnProperty("test", 0), true);
	assert_equal(Object.hasOwnProperty("test", 99), false);
	assert_equal(Object.hasOwnProperty([1], 0), true);
	assert_equal(Object.hasOwnProperty([1], 99), false);
	assert_equal(Object.hasOwnProperty({ a: 1 }, "a"), true);
});