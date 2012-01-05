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