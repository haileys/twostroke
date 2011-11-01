Error = function(message) {
	this.name = "Error";
	this.message = message;
};
Error.prototype.toString = function() {
	return this.name + ": " + this.message;
};