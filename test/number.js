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

test("Number", function() {
	assert(isNaN(Number(undefined)));
	assert_equal(0, Number(null));
	assert_equal(0, Number(false));
	assert_equal(1, Number(true));
	assert_equal(123, Number("123"));
	assert_equal(123.456, Number("123.456"));
	assert_equal(5, Number({ toString: function() { return "5"; } }));
});

test("int32", function() {
	assert_equal(5, 5 >> NaN);
	assert_equal(5, 5 << NaN);
	assert_equal(5, 5 | NaN);
	
	assert_equal(4, 5 & 4);
	assert_equal(4, 5.5 & 4.7816516);
	
	assert_equal(-8, ~7);
	assert_equal(-9, ~8.9923456789123456789123456789);
});

test("==", function() {
	assert("5" == 5);
	assert(5 == "5");
});