test("simple regexps", function() {
	assert_equal(true, /hello/.test("hello world"));
	assert_equal(false, /goodbye/.test("hello world"));
});

test("exec", function() {
	assert("123,1,2,3" == /(\d)(\d)(\d)/.exec("123"));
	assert("123,123" == /(\d+)/.exec("123"));
	assert(null == /\s+/.exec("123"));
	assert("b,,b" == /(a)?(b)/.exec("b"));
});

test("exec additional attributes", function() {
	assert_equal("hello", /./.exec("hello").input);
	assert_equal(0, /./.exec("hello").index);
	assert_equal("hello", /l/.exec("hello").input);
	assert_equal(2, /l/.exec("hello").index);
});