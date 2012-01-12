(function() {

function assert_feq(a, b) {
	assert(Math.abs(a - b) < 0.00000001);
}

test("sin", function() {
	assert_feq(0, Math.sin(0));
	assert_feq(1, Math.sin(Math.PI / 2));
	assert_feq(0, Math.sin(Math.PI));
	assert_feq(-1, Math.sin(Math.PI * 3 / 2));
	assert_feq(0, Math.sin(Math.PI * 2));
});

test("cos", function() {
	assert_feq(1, Math.cos(0));
	assert_feq(0, Math.cos(Math.PI / 2));
	assert_feq(-1, Math.cos(Math.PI));
	assert_feq(0, Math.cos(Math.PI * 3 / 2));
	assert_feq(1, Math.cos(Math.PI * 2));
});

test("tan", function() {
	assert_feq(0, Math.tan(0));
});

test("sqrt", function() {
	assert_feq(0, Math.sqrt(0));
	assert_feq(4, Math.sqrt(16));
	assert_feq(Math.PI, Math.sqrt(Math.PI * Math.PI));
  assert(isNaN(Math.sqrt(-1)));
});

test("parseInt", function() {
  assert_equal(123, parseInt("123"));
  assert_equal(123, parseInt("123", 10));
  assert_equal(123, parseInt("0123", 10));
  assert_equal(123, parseInt("0173"));
  assert_equal(123, parseInt("173", 8));
  assert_equal(123, parseInt("0x7b"));
  assert_equal(123, parseInt("0X7B"));
  assert_equal(123, parseInt("7b", 16));
  
  assert(isNaN(parseInt("123", 1)));
  assert(isNaN(parseInt("123", 37)));
  assert(isNaN(parseInt("f00")));
});

test("pow", function() {
  assert_equal(27, Math.pow(3, 3));
  assert_equal(4, Math.pow(16, 0.5));
  assert_equal(1024, Math.pow(16, 2.5));
  assert(isNaN(Math.pow(-1, 0.5)));
})

})();