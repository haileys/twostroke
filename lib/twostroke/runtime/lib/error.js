(function(globals) {
	Error = function(message) {
		this.name = "Error";
		this.message = message;
	};
	Error.prototype.toString = function() {
		return this.name + ": " + this.message;
	};

	var errors = ["Eval", "Range", "Reference", "Syntax", "Type", "URI"];
	for(var i = 0; i < errors.length; i++) {
		(function(name) {
			globals[name] = function(message) { 
				this.name = name;
				this.message = message;
			};
			globals[name].prototype = new Error();
		})(errors[i] + "Error");
	}
})(this);