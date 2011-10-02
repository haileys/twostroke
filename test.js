var handy_stuff = {
	fibonacci: function(x) {
		if(x > 2) {
			return fibonacci(x - 2) + fibonacci(x - 1);
		} else {
			return 1;
		}
	}
};

if(!false == true) {
	var array = [1, 2, function() { return 3; }, "four"];	
}