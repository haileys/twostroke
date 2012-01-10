test("pop", function() {
	var x = [1,2];
	assert_equal(x.pop(), 2);
	assert_equal(x.pop(), 1);
	assert_equal(x.pop(), undefined);
});

test("shift", function() {
	var x = [1,2];
	assert_equal(x.shift(), 1);
	assert_equal(x.shift(), 2);
	assert_equal(x.shift(), undefined);
});

test("push", function() {
	var x = [1];
	assert_equal(x.push("foo"), 2);
	assert_equal(x[0], 1);
	assert_equal(x[1], "foo");
	assert_equal(x.push("bar"), 3);
	assert_equal(x[0], 1);
	assert_equal(x[1], "foo");
	assert_equal(x[2], "bar");
});

test("unshift", function() {
	var x = [1];
	assert_equal(x.unshift("foo"), 2);
	assert_equal(x[0], "foo");
	assert_equal(x[1], 1);
	assert_equal(x.unshift("bar"), 3);
	assert_equal(x[0], "bar");
	assert_equal(x[1], "foo");
	assert_equal(x[2], 1);
});

test("constructor", function() {
  assert("1,2,3,4" == new Array(1,2,3,4));
  assert("1,2,3,4" == Array(1,2,3,4));
  assert("" == new Array());
});

test("splice", function() {
  var a = [1,2,3,4,5];
  assert("2,3" == a.splice(1, 2, 7));
  assert("1,7,4,5" == a);
  assert("4,5" == a.splice(2));
  assert("1,7" == a);
});

test("length=", function() {
  var a = [1,2,3,4,5,6,7];
  a.length = 4;
  assert("1,2,3,4" == a);
});

test("concat", function() {
  var a = [];
  
  assert(a.concat(1,2,3) == "1,2,3");
  assert(a == "", "concat mutated array");
  
  assert(a.concat([1,2,3],4,[5]) == "1,2,3,4,5");
  assert(a == "", "concat mutated array");
  
  var b = [1,2,3];
  assert(b.concat() == "1,2,3");
  assert(b.concat() !== b);
  
  assert(Array.prototype.concat.call({ length: 2, 0: 1, 1: 2 }, [3, 4]) == "1,2,3,4");
});