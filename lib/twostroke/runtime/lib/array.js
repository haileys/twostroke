Array.prototype.forEach = function(callback, thisObj) {
	if(this == null) {
		throw new TypeError("this is null or undefined");
	}
	var obj = Object(this);
	thisObj = thisObj || this;
	for(var i = 0; i < obj.length; i++) {
		if(i in this) {
			callback.call(thisObj, obj[i], i, obj);
		}
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

Array.prototype.filter = function(callback, thisObj) {
	var x = [];
	this.forEach(function(el, i, obj) {
		if(callback.call(this, el, i, obj)) {
			x.push(el);
		}
	}, thisObj);
	return x;
};

Array.prototype.every = function(callback, thisObj) {
	for(var i = 0; i < this.length; i++) {
		if(i in this) {
			if(!callback.call(thisObj, this[i], i, this)) {
				return false;
			}
		}
	}
	return true;
};

Array.prototype.map = function(callback, thisObj) {
	var x = [];
	this.forEach(function(el, i, obj) {
		x.push(callback.call(this, el, i, obj));
	}, thisObj);
	return x;
};

Array.prototype.some = function(callback, thisObj) {
	for(var i = 0; i < this.length; i++) {
		if(i in this) {
			if(callback.call(thisObj, this[i], i, this)) {
				return true;
			}
		}
	}
	return false;
};

Array.prototype.reduce = function(callback, accumulator) {
	var i = 0;
	if(accumulator === undefined) {
		if(!this.length) {
			throw new TypeError("Reduce of empty array with no initial value");
		}
		while(i < this.length && !(i in this)) i++;
		accumulator = this[i++];
	}
	for(; i < this.length; i++) {
		if(i in this) {
			accumulator = callback(accumulator, this[i], i, this);
		}
	}
	return accumulator;
};

Array.prototype.reduceRight = function(callback, accumulator) {
	var i = this.length - 1;
	if(accumulator === undefined) {
		if(!this.length) {
			throw new TypeError("Reduce of empty array with no initial value");
		}
		accumulator = this[i--];
	}
	for(; i >= 0; i--) {
		if(i in this) {
			accumulator = callback(accumulator, this[i], i, this);
		}
	}
	return accumulator;
};