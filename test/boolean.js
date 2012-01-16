test("toString", function() {
  assert_equal("true", true.toString());
  assert_equal("false", false.toString());
  try {
    Boolean.prototype.toString.call(123);
    assert(false, "did not throw");
  } catch(e) {
    assert(/generic/.test(e.toString()));
  }
});

test("String coercion", function() {
  assert_equal("true", String(true));
  assert_equal("false", String(false));
  assert_equal("true", String(new Boolean(true)));
  assert_equal("false", String(new Boolean(false)));
});

test("Number coercion", function() {
  assert_equal(1, Number(true));
  assert_equal(0, Number(false));
  assert_equal(1, Number(new Boolean(true)));
  assert_equal(0, Number(new Boolean(false)));
});