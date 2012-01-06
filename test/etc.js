test("Error constructor works", function() {
  var e = new Error();
  assert_equal(e.name, "Error");
  assert_equal(e.message, undefined);
  
  var f = new Error("test");
  assert_equal(f.name, "Error");
  assert_equal(f.message, "test");
});