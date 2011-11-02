test("toString", function() {
	assert_equal((123).toString(), "123");
	assert_equal((123.0).toString(), "123");
	assert_equal((123.456).toString(), "123.456");
	assert_equal(Number.POSITIVE_INFINITY.toString(), "Infinity");
	assert_equal(Number.NEGATIVE_INFINITY.toString(), "-Infinity");
	assert_equal(Number.NaN.toString(), "NaN");
});

test("toString throws on non-number", function() {
	try {
		Number.prototype.toString.call("");
		assert(false);
	} catch(e) {
		assert(true);
	}
});

test("toExponential", function() {
	assert_equal((1).toExponential(), "1.0e+0");
	assert_equal((1.0).toExponential(), "1.0e+0");
	assert_equal((123).toExponential(), "1.23e+2");
	assert_equal((0.00123).toExponential(), "1.23e-3");
});

test("typeof", function() {
	assert_equal(typeof 1, "number");
	assert_equal(typeof 1.0, "number");
	assert_equal(typeof Number(1), "number");
	assert_equal(typeof Number(1.0), "number");
	assert_equal(typeof new Number(1), "object");
	assert_equal(typeof new Number(1.0), "object");
});