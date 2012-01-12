test("typeof", function() {
	assert_equal(typeof function() {}, "function");
});

test("undefined arguments", function() {
	function foo(a, b, c) {
		assert_equal(a, 1);
		assert_equal(b, undefined);
		assert_equal(c, undefined);
	}
	foo(1);
});

test("apply", function() {
	(function() {
		assert_equal(typeof this, "object");
		assert_equal(+this, 1);
	}).apply(1);
	
	(function(a, b, c) {
		assert_equal(typeof this, "object");
		assert_equal(Boolean(this), true);
		assert_equal(a, 1);
		assert_equal(b, "test");
		assert_equal(c, false);
	}).apply(true, [1, "test", false]);
});

test("toString", function() {
	assert(/function foo/.test((function foo() { }).toString()));
});

test("new with member access", function() {
	var x = {
		y: {
			z: function() {
				assert(true);
				return true;
			}
		}
	};
	(new x.y.z()) || assert(false);
});

test("new with array index", function() {
	var x = {
		y: {
			z: function() {
				assert(true);
				return true;
			}
		}
	};
	(new x["y"]["z"]()) || assert(false);
});

test("instanceof", function() {
  assert(!("hi" instanceof String));
  assert(new String("hi") instanceof String);
  var x = String;
  assert(new x("hi") instanceof String);
  assert(new String("hi") instanceof x);
  assert(Function instanceof Function);
  try {
    String instanceof new String("hi");
    assert(false, "did not throw");
  } catch(e) {
    assert(/instanceof/.test(e.toString()));
  }
});