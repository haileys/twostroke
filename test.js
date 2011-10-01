var handy_shit = {
	fibonacci: function(x) {
		if(x > 2) {
			return fibonacci(x - 2) + fibonacci(x - 1);
		} else {
			return 1;
		}
	}
};