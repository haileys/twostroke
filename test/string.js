test("toString", function() {
	assert_equal("foo", "foo".toString());
	assert_equal("", "".toString());
});

test("toString is not generic", function() {
	try {
		String.prototype.toString.call(123);
	} catch(e) {
		if(e instanceof TypeError) {
			assert(true);
			return;
		}
		assert(false, "exception not TypeError");
	}
	assert(false, "did not throw");
});

test("split", function() {
	assert("hello,world" == "hello world".split(" "));
	assert("this,is,a test" == "this is a test".split(" ", 3));
	assert("what" == "what".split("jjjj"));
	assert("w,h,a,t" == "what".split(""));
	assert("what" == "what".split());
});

test("slice", function() {
	assert_equal("hello", "hello".slice());
	assert_equal("llo", "hello".slice(2));
	assert_equal("el", "hello".slice(1,3));
	assert_equal("ell", "hello".slice(1,-1));
});

test("match", function() {
  assert("fo,ob,ar" == "foobar".match(/../g));
  assert("fo" == "foobar".match(/../));
  
  assert("fo,ob,ar" == "foobar".match(/.(.)/g));
  assert("fo,o" == "foobar".match(/.(.)/));
});

test("indexOf", function() {
  assert_equal(3, "foobar".indexOf("bar"));
  assert_equal(2, "bbaaaaa".indexOf("a"));
});

test("lastIndexOf", function() {
  assert_equal(3, "foobar".lastIndexOf("bar"));
  assert_equal(6, "bbaaaaa".lastIndexOf("a"));
});

test("enumerable properties", function() {
  var i = 0;
  var s = "hello";
  for(var x in s) {
    if(s.hasOwnProperty(x)) {
      i++;
    }
  }
  assert_equal(5, i);
});