test("simple throw/catch", function() {
	try {
		throw 1;
	} catch(e) {
		assert(e === 1);
	}
});

test("code after throw is not executed", function() {
	try {
		throw 1;
		assert(false);
	} catch(e) {
	}
});

test("throw/catch across function", function() {
	function foo() {
		throw 1;
	}
	try {
		foo();
	} catch(e) {
		assert(e === 1);
	}
});

test("throw/catch across many functions", function() {
	function foo(i) {
		if(i > 10) {
			throw 1;
		} else {
			foo(i + 1);
		}
	}
	try {
		foo(0);
	} catch(e) {
		assert(e === 1);
	}
});

test("catch runs before finally", function() {
	var x = 0;
	try {
		assert(x === 0);
		throw 1;
	} catch(e) {
		assert(++x === 1);
	} finally {
		assert(++x === 2);
	}
});

test("finally's return value overrides catch's", function() {
	function foo() {
		try {
			throw 1;
		} catch(e) {
			return "catch";
		} finally {
			return "finally";
		}
	}
	assert(foo() === "finally");
});

test("finally still executes if catch throws an exception", function() {
	var x = false;
	function foo() {
		try {
			throw 1;
		} catch(e) {
			throw 2;
		} finally {
			x = true;
		}
	}
	try {
		foo();
	} catch(e) { }
	assert(x);
});

test("finally still executes if catch throws an exception and the exception keeps bubbling up", function() {
  var x = false, y = false, z = false;
  try {
    try {
      throw 1;
    } catch(e) {
      x = (e == 1);
      throw 2;
    } finally {
      console.log("finally");
      y = true;
    }
  } catch(e) { 
    console.log("hi! -> ", e == 2);
    z = (e == 2);
  }
  assert(x && y && z);
});

test("finally's throw overrides catch's", function() {
	function foo() {
		try {
			throw 1;
		} catch(e) {
			throw 2;
		} finally {
			throw 3;
		}
	}
	try {
		foo();
	} catch(e) {
		assert(e === 3);
	}
});

test("nested try/catches work", function() {
	try {
		try {
			throw 1;
		} catch(e) {
			assert(e === 1);
			throw 2;
		}
	} catch(e) {
		assert(e === 2);
	}
});