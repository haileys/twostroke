test("Error constructor works", function() {
  var e = new Error();
  assert_equal(e.name, "Error");
  assert_equal(e.message, undefined);
  
  var f = new Error("test");
  assert_equal(f.name, "Error");
  assert_equal(f.message, "test");
});

test("json parser works with simple values", function() {
    assert_equal(123, JSON.parse("123"));
    assert_equal(123.456, JSON.parse("123.456"));
    assert_equal(-123456, JSON.parse("-123.456e3"));
    assert_equal(true, JSON.parse("true"));
    assert_equal(false, JSON.parse("false"));
    assert_equal(null, JSON.parse("null"));
    assert_equal("foo", JSON.parse('"foo"'));
    assert_equal("", JSON.parse('""'));
});

test("json parser works with arrays", function() {
    var a = JSON.parse("[1,2,3]");
    assert_equal(3, a.length);
    assert_equal(1, a[0]);
    assert_equal(2, a[1]);
    assert_equal(3, a[2]);
    
    var a = JSON.parse("[[[[1]]]]");
    assert_equal(1, a.length);
    assert_equal(1, a[0][0][0][0]);
});

test("json parser works with object", function() {
    var o = JSON.parse('{ "a": 1, "b": [2] }');
    assert_equal(1, o.a);
    assert_equal(1, o.b.length);
    assert_equal(2, o.b[0]);
    
    var o = JSON.parse('{"a":{"b":{"a":{"b":123}}}}');
    assert_equal(123, o.a.b.a.b);
});