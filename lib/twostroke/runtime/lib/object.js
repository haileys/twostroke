Object.keys = function(obj) {
	if(typeof obj !== "object" || obj === null) {
		throw new TypeError("Object.keys called on non-object");
	}
	var keys = [];
	for(var k in obj) {
		if(Object.prototype.hasOwnProperty.call(obj, k)) {
			keys.push(k);
		}
	}
	return keys;
};