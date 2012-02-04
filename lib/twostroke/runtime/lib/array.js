Array.prototype.reverse = function() {
	for(var i = 0; i < this.length / 2; i++) {
		var j = this.length - 1 - i;
		var tmp = this[i];
		this[i] = this[j];
		this[j] = tmp;
	}
	return this;
};

Array.prototype.concat = function() {
	var x = [];
	Array.prototype.slice.call(this).forEach(function(el) {
		x.push(el);
	});
	Array.prototype.slice.call(arguments).forEach(function(obj) {
	  if(obj instanceof Array) {
	    obj.forEach(function(el) {
	      x.push(el);
	    });
	  } else {
	    x.push(obj);
	  }
	});
	return x;
};

Array.prototype.join = function(delim) {
    if(delim === null || delim === undefined) {
        delim = ",";
    }
	delim = delim.toString();
	var str = "";
	this.forEach(function(el, i) {
		if(i > 0) {
			str += delim;
		}
		if(el !== null && typeof el !== "undefined") {
		    str += el.toString();
	    }
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