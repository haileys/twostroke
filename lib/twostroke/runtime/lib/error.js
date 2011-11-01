Error.prototype.toString = function() {
	return this.name + ": " + this.message;
};