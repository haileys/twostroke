Array.prototype.forEach = function(callback, thisArg) {
	if(this == null) {
		throw new TypeError("this is null or undefined");
	}
	var obj = Object(this);
	thisArg = thisArg || this;
	for(var i = 0; i < obj.length; i++) {
		callback(thisArg, obj[i], i, obj);
	}
};

Array.prototype.reverse = function() {
	for(var i = 0; i < this.length / 2; i++) {
		var j = this.length - 1 - i;
		var tmp = this[i];
		this[i] = this[j];
		this[j] = tmp;
	}
	return this;
};

Array.prototype.concat = function(other) {
	var x = [];
	this.forEach(function(el) {
		x.push(el);
	});
	other.forEach(function(el) {
		x.push(el);
	});
	return x;
};

Array.prototype.join = function(delim) {
	delim = delim.toString();
	var str = "";
	this.forEach(function(el, i) {
		if(i > 0) {
			str += delim;
		}
		str += el.toString();	
	});
	return str;
};

Array.prototype.indexOf = function(el, from) {
	from = Number(from || 0);
	if(from < 0) {
		from += this.length;
	}
	for(var i = from; i < this.length; i++) {
		if(this[i] === el) {
			return i;
		}
	}
	return -1;
};

Array.prototype.lastIndexOf = function(el, from) {
	from = Number(from || this.length);
	if(from < 0) {
		from += this.length;
	}
	for(var i = from - 1; i >= 0; i--) {
		if(this[i] === el) {
			return i;
		}
	}
	return -1;
};