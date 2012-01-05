test("pop", function() {
	var x = [1,2];
	assert_equal(x.pop(), 2);
	assert_equal(x.pop(), 1);
	assert_equal(x.pop(), undefined);
});

test("shift", function() {
	var x = [1,2];
	assert_equal(x.shift(), 1);
	assert_equal(x.shift(), 2);
	assert_equal(x.shift(), undefined);
});

test("push", function() {
	var x = [1];
	assert_equal(x.push("foo"), 2);
	assert_equal(x[0], 1);
	assert_equal(x[1], "foo");
	assert_equal(x.push("bar"), 3);
	assert_equal(x[0], 1);
	assert_equal(x[1], "foo");
	assert_equal(x[2], "bar");
});

test("unshift", function() {
	var x = [1];
	assert_equal(x.unshift("foo"), 2);
	assert_equal(x[0], "foo");
	assert_equal(x[1], 1);
	assert_equal(x.unshift("bar"), 3);
	assert_equal(x[0], "bar");
	assert_equal(x[1], "foo");
	assert_equal(x[2], 1);
});

test("delete", function() {	
	var y = { a:1, b:2, c:3 };
	assert_equal("number", typeof y.b);
	delete y.b;
	assert_equal("undefined", typeof y.b);
});