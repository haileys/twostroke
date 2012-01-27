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

test("charAt", function() {
  assert_equal("a", "abc".charAt(0));
  assert_equal("o", "zzo".charAt(2));
  assert_equal("", "what".charAt(-1));
  assert_equal("", "what".charAt(4));
});

test("[]", function() {
  assert_equal("a", "abc"[0]);
  assert_equal("o", "zzo"[2]);
  assert_equal(undefined, "what"[-1]);
  assert_equal(undefined, "what"[4]);
});

test("in", function() {
  assert(0 in "hi");
  assert(1 in "hi");
  assert(!(2 in "hi"));
  assert("length" in "hi");
  assert(!("foo" in "hi"));
});

test("charCodeAt", function() {
  assert_equal(97, "a".charCodeAt(0));
  assert_equal(111, "zzo".charCodeAt(2));
  assert(isNaN("what".charCodeAt(-1)));
  assert(isNaN("what".charCodeAt(4)));
});

test("toUpperCase", function() {
  assert_equal("FOO", "foo".toUpperCase());
  assert_equal("FOO", "FoO".toUpperCase());
  assert_equal("", "".toUpperCase());
});

test("toLowerCase", function() {
  assert_equal("foo", "FOO".toLowerCase());
  assert_equal("foo", "FoO".toLowerCase());
  assert_equal("", "".toLowerCase());
});

test("fromCharCode", function() {
  assert_equal("", String.fromCharCode());
  assert_equal("a", String.fromCharCode(97));
  assert_equal("abcd", String.fromCharCode(97,98,99,100));
});

test("primitive value", function() {
  assert_equal("foobar", String(new String("foobar")));
  assert_equal("", String(new String("")));
});

test("escape codes", function() {
  assert_equal(-1, "\b".indexOf("b"));
  assert_equal(-1, "\n".indexOf("n"));
  assert_equal(-1, "\f".indexOf("f"));
  assert_equal(-1, "\v".indexOf("v"));
  assert_equal(-1, "\r".indexOf("r"));
  assert_equal(-1, "\t".indexOf("t"));
  assert_equal("hi", "h\
i");

  assert_equal(" ", "\x20");
  assert_equal(" ", "\u0020");
  assert_equal(" ", "\40");
});

test("substring", function() {
    assert_equal("foobar", "foobar".substring());
    assert_equal("foobar", "foobar".substring(0, 6));
    assert_equal("ar", "foobar".substring(-2, 6));
    assert_equal("ob", "foobar".substring(2, 4));
    assert_equal("bar", "foobar".substring(3));
});

test("comparison", function() {
    assert("hello" > "a");
    assert("a" < "b");
    assert("a" <= "a");
    assert("A" < "a");
});