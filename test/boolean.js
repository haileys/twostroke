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