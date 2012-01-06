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

test("propertyIsEnumerable", function() {
  assert_equal(false, propertyIsEnumerable("blah"));
  assert_equal(true, ({a:1}).propertyIsEnumerable("a"));
  assert_equal(false, ({b:1}).propertyIsEnumerable("a"));
  assert_equal(false, Object.prototype.propertyIsEnumerable("propertyIsEnumerable"));
});

test("toString", function() {
  var to_s = Object.prototype.toString;
  assert_equal("[object Object]", to_s.call({}));
  assert_equal("[object Number]", to_s.call(123));
  assert_equal("[object Boolean]", to_s.call(true));
  assert_equal("[object String]", to_s.call("hi"));
  assert_equal("[object String]", to_s.call(new String("hi")));
});

test("typeof", function() {
  assert_equal("object", typeof null);
  assert_equal("object", typeof {});
  assert_equal("object", typeof new String("hi"));
});