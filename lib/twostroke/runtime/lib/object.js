Object.keys = function(obj) {
	var keys = [];
	for(var k in obj) {
		keys.push(k);
	}
	return keys;
};