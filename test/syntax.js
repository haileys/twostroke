test("do while", function() {
	do {
		assert(true);
		return;
	} while(false);
	assert(false, "did not execute");
});

test("do while and continue", function() {
	var flag = false;
	do {
		if(flag) {
			assert(false, "loop executed again after continue in do..while(false)");
		}
		flag = true;
		continue;
	} while(false);
	assert(true);
});

test("with", function() {
	var b = 0;
	var x = { a: 1 };
	with(x) {
		assert_equal("number", typeof a);
		assert_equal(1, a);
		var y = 2;
		b = 3;
		a = 4;
	}
	assert_equal(4, x.a);
	assert_equal(2, y);
	assert_equal("undefined", typeof x.b);
	assert_equal(3, b);
});

test("default in switch", function() {
	switch(1) {
		case 1: assert(true); break;
		default: assert(false); break;
	}

	switch(2) {
		case 1: assert(false); break;
		default: assert(true); break;
	}

	switch(1) {
		default: assert(false); break;
		case 1: assert(true); break;
	}

	switch(2) {
		default: assert(true); break;
		case 1: assert(false); break;
	}
});