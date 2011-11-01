/*
Copyright (c) 2011 Jeremy Ashkenas

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

test("cubes", function() {
	var cubes, list, math, num, number, opposite, race, square;
	var __slice = Array.prototype.slice;
	number = 42;
	opposite = true;
	if (opposite) number = -42;
	square = function(x) {
	  return x * x;
	};
	list = [1, 2, 3, 4, 5];
	math = {
	  root: Math.sqrt,
	  square: square,
	  cube: function(x) {
	    return x * square(x);
	  }
	};
	race = function() {
	  var runners, winner;
	  winner = arguments[0], runners = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
	  return print(winner, runners);
	};
	if (typeof elvis !== "undefined" && elvis !== null) alert("I knew it!");
	cubes = (function() {
	  var _i, _len, _results;
	  _results = [];
	  for (_i = 0, _len = list.length; _i < _len; _i++) {
	    num = list[_i];
	    _results.push(math.cube(num));
	  }
	  return _results;
	})();
	
	assert(cubes == "1,8,27,64,125");
});

test('fill("cup")', function() {
	var fill;
	fill = function(container, liquid) {
	  if (liquid == null) liquid = "coffee";
	  return "Filling the " + container + " with " + liquid + "...";
	};
	
	assert(fill("cup") == "Filling the cup with coffee...");
});

test('song.join(" ... ")', function() {
	var song;
	song = ["do", "re", "mi", "fa", "so"];
	
	assert(song.join(" ... ") == "do ... re ... mi ... fa ... so");
});