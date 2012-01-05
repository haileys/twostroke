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
});

})();