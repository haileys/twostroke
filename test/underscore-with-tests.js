//     Underscore.js 1.2.1
//     (c) 2011 Jeremy Ashkenas, DocumentCloud Inc.
//     Underscore is freely distributable under the MIT license.
//     Portions of Underscore are inspired or borrowed from Prototype,
//     Oliver Steele's Functional, and John Resig's Micro-Templating.
//     For all details and documentation:
//     http://documentcloud.github.com/underscore

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `global` on the server.
  var root = this;

  // Save the previous value of the `_` variable.
  var previousUnderscore = root._;

  // Establish the object that gets returned to break out of a loop iteration.
  var breaker = {};

  // Save bytes in the minified (but not gzipped) version:
  var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

  // Create quick reference variables for speed access to core prototypes.
  var slice            = ArrayProto.slice,
      unshift          = ArrayProto.unshift,
      toString         = ObjProto.toString,
      hasOwnProperty   = ObjProto.hasOwnProperty;

  // All **ECMAScript 5** native function implementations that we hope to use
  // are declared here.
  var
    nativeForEach      = ArrayProto.forEach,
    nativeMap          = ArrayProto.map,
    nativeReduce       = ArrayProto.reduce,
    nativeReduceRight  = ArrayProto.reduceRight,
    nativeFilter       = ArrayProto.filter,
    nativeEvery        = ArrayProto.every,
    nativeSome         = ArrayProto.some,
    nativeIndexOf      = ArrayProto.indexOf,
    nativeLastIndexOf  = ArrayProto.lastIndexOf,
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind;

  // Create a safe reference to the Underscore object for use below.
  var _ = function(obj) { return new wrapper(obj); };

  // Export the Underscore object for **Node.js** and **"CommonJS"**, with
  // backwards-compatibility for the old `require()` API. If we're not in
  // CommonJS, add `_` to the global object.
  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else if (typeof define === 'function' && define.amd) {
    // Register as a named module with AMD.
    define('underscore', function() {
      return _;
    });
  } else {
    // Exported as a string, for Closure Compiler "advanced" mode.
    root['_'] = _;
  }

  // Current version.
  _.VERSION = '1.2.1';

  // Collection Functions
  // --------------------

  // The cornerstone, an `each` implementation, aka `forEach`.
  // Handles objects with the built-in `forEach`, arrays, and raw objects.
  // Delegates to **ECMAScript 5**'s native `forEach` if available.
  var each = _.each = _.forEach = function(obj, iterator, context) {
    if (obj == null) return;
    if (nativeForEach && obj.forEach === nativeForEach) {
      obj.forEach(iterator, context);
    } else if (obj.length === +obj.length) {
      for (var i = 0, l = obj.length; i < l; i++) {
        if (i in obj && iterator.call(context, obj[i], i, obj) === breaker) return;
      }
    } else {
      for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) {
          if (iterator.call(context, obj[key], key, obj) === breaker) return;
        }
      }
    }
  };

  // Return the results of applying the iterator to each element.
  // Delegates to **ECMAScript 5**'s native `map` if available.
  _.map = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
    each(obj, function(value, index, list) {
      results[results.length] = iterator.call(context, value, index, list);
    });
    return results;
  };

  // **Reduce** builds up a single result from a list of values, aka `inject`,
  // or `foldl`. Delegates to **ECMAScript 5**'s native `reduce` if available.
  _.reduce = _.foldl = _.inject = function(obj, iterator, memo, context) {
    var initial = memo !== void 0;
    if (obj == null) obj = [];
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduce(iterator, memo) : obj.reduce(iterator);
    }
    each(obj, function(value, index, list) {
      if (!initial) {
        memo = value;
        initial = true;
      } else {
        memo = iterator.call(context, memo, value, index, list);
      }
    });
    if (!initial) throw new TypeError("Reduce of empty array with no initial value");
    return memo;
  };

  // The right-associative version of reduce, also known as `foldr`.
  // Delegates to **ECMAScript 5**'s native `reduceRight` if available.
  _.reduceRight = _.foldr = function(obj, iterator, memo, context) {
    if (obj == null) obj = [];
    if (nativeReduceRight && obj.reduceRight === nativeReduceRight) {
      if (context) iterator = _.bind(iterator, context);
      return memo !== void 0 ? obj.reduceRight(iterator, memo) : obj.reduceRight(iterator);
    }
    var reversed = (_.isArray(obj) ? obj.slice() : _.toArray(obj)).reverse();
    return _.reduce(reversed, iterator, memo, context);
  };

  // Return the first value which passes a truth test. Aliased as `detect`.
  _.find = _.detect = function(obj, iterator, context) {
    var result;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  // Return all the elements that pass a truth test.
  // Delegates to **ECMAScript 5**'s native `filter` if available.
  // Aliased as `select`.
  _.filter = _.select = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeFilter && obj.filter === nativeFilter) return obj.filter(iterator, context);
    each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) results[results.length] = value;
    });
    return results;
  };

  // Return all the elements for which a truth test fails.
  _.reject = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    each(obj, function(value, index, list) {
      if (!iterator.call(context, value, index, list)) results[results.length] = value;
    });
    return results;
  };

  // Determine whether all of the elements match a truth test.
  // Delegates to **ECMAScript 5**'s native `every` if available.
  // Aliased as `all`.
  _.every = _.all = function(obj, iterator, context) {
    var result = true;
    if (obj == null) return result;
    if (nativeEvery && obj.every === nativeEvery) return obj.every(iterator, context);
    each(obj, function(value, index, list) {
      if (!(result = result && iterator.call(context, value, index, list))) return breaker;
    });
    return result;
  };

  // Determine if at least one element in the object matches a truth test.
  // Delegates to **ECMAScript 5**'s native `some` if available.
  // Aliased as `any`.
  var any = _.some = _.any = function(obj, iterator, context) {
    iterator = iterator || _.identity;
    var result = false;
    if (obj == null) return result;
    if (nativeSome && obj.some === nativeSome) return obj.some(iterator, context);
    each(obj, function(value, index, list) {
      if (result |= iterator.call(context, value, index, list)) return breaker;
    });
    return !!result;
  };

  // Determine if a given value is included in the array or object using `===`.
  // Aliased as `contains`.
  _.include = _.contains = function(obj, target) {
    var found = false;
    if (obj == null) return found;
    if (nativeIndexOf && obj.indexOf === nativeIndexOf) return obj.indexOf(target) != -1;
    found = any(obj, function(value) {
      return value === target;
    });
    return found;
  };

  // Invoke a method (with arguments) on every item in a collection.
  _.invoke = function(obj, method) {
    var args = slice.call(arguments, 2);
    return _.map(obj, function(value) {
      return (method.call ? method || value : value[method]).apply(value, args);
    });
  };

  // Convenience version of a common use case of `map`: fetching a property.
  _.pluck = function(obj, key) {
    return _.map(obj, function(value){ return value[key]; });
  };

  // Return the maximum element or (element-based computation).
  _.max = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj)) return Math.max.apply(Math, obj);
    if (!iterator && _.isEmpty(obj)) return -Infinity;
    var result = {computed : -Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed >= result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Return the minimum element (or element-based computation).
  _.min = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj)) return Math.min.apply(Math, obj);
    if (!iterator && _.isEmpty(obj)) return Infinity;
    var result = {computed : Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed < result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Shuffle an array.
  _.shuffle = function(obj) {
    var shuffled = [], rand;
    each(obj, function(value, index, list) {
      if (index == 0) {
        shuffled[0] = value;
      } else {
        rand = Math.floor(Math.random() * (index + 1));
        shuffled[index] = shuffled[rand];
        shuffled[rand] = value;
      }
    });
    return shuffled;
  };

  // Sort the object's values by a criterion produced by an iterator.
  _.sortBy = function(obj, iterator, context) {
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value : value,
        criteria : iterator.call(context, value, index, list)
      };
    }).sort(function(left, right) {
      var a = left.criteria, b = right.criteria;
      return a < b ? -1 : a > b ? 1 : 0;
    }), 'value');
  };

  // Groups the object's values by a criterion. Pass either a string attribute
  // to group by, or a function that returns the criterion.
  _.groupBy = function(obj, val) {
    var result = {};
    var iterator = _.isFunction(val) ? val : function(obj) { return obj[val]; };
    each(obj, function(value, index) {
      var key = iterator(value, index);
      (result[key] || (result[key] = [])).push(value);
    });
    return result;
  };

  // Use a comparator function to figure out at what index an object should
  // be inserted so as to maintain order. Uses binary search.
  _.sortedIndex = function(array, obj, iterator) {
    iterator || (iterator = _.identity);
    var low = 0, high = array.length;
    while (low < high) {
      var mid = (low + high) >> 1;
      iterator(array[mid]) < iterator(obj) ? low = mid + 1 : high = mid;
    }
    return low;
  };

  // Safely convert anything iterable into a real, live array.
  _.toArray = function(iterable) {
    if (!iterable)                return [];
    if (iterable.toArray)         return iterable.toArray();
    if (_.isArray(iterable))      return slice.call(iterable);
    if (_.isArguments(iterable))  return slice.call(iterable);
    return _.values(iterable);
  };

  // Return the number of elements in an object.
  _.size = function(obj) {
    return _.toArray(obj).length;
  };

  // Array Functions
  // ---------------

  // Get the first element of an array. Passing **n** will return the first N
  // values in the array. Aliased as `head`. The **guard** check allows it to work
  // with `_.map`.
  _.first = _.head = function(array, n, guard) {
    return (n != null) && !guard ? slice.call(array, 0, n) : array[0];
  };

  // Returns everything but the last entry of the array. Especcialy useful on
  // the arguments object. Passing **n** will return all the values in
  // the array, excluding the last N. The **guard** check allows it to work with
  // `_.map`.
  _.initial = function(array, n, guard) {
    return slice.call(array, 0, array.length - ((n == null) || guard ? 1 : n));
  };

  // Get the last element of an array. Passing **n** will return the last N
  // values in the array. The **guard** check allows it to work with `_.map`.
  _.last = function(array, n, guard) {
    return (n != null) && !guard ? slice.call(array, array.length - n) : array[array.length - 1];
  };

  // Returns everything but the first entry of the array. Aliased as `tail`.
  // Especially useful on the arguments object. Passing an **index** will return
  // the rest of the values in the array from that index onward. The **guard**
  // check allows it to work with `_.map`.
  _.rest = _.tail = function(array, index, guard) {
    return slice.call(array, (index == null) || guard ? 1 : index);
  };

  // Trim out all falsy values from an array.
  _.compact = function(array) {
    return _.filter(array, function(value){ return !!value; });
  };

  // Return a completely flattened version of an array.
  _.flatten = function(array, shallow) {
    return _.reduce(array, function(memo, value) {
      if (_.isArray(value)) return memo.concat(shallow ? value : _.flatten(value));
      memo[memo.length] = value;
      return memo;
    }, []);
  };

  // Return a version of the array that does not contain the specified value(s).
  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  // Aliased as `unique`.
  _.uniq = _.unique = function(array, isSorted, iterator) {
    var initial = iterator ? _.map(array, iterator) : array;
    var result = [];
    _.reduce(initial, function(memo, el, i) {
      if (0 == i || (isSorted === true ? _.last(memo) != el : !_.include(memo, el))) {
        memo[memo.length] = el;
        result[result.length] = array[i];
      }
      return memo;
    }, []);
    return result;
  };

  // Produce an array that contains the union: each distinct element from all of
  // the passed-in arrays.
  _.union = function() {
    return _.uniq(_.flatten(arguments, true));
  };

  // Produce an array that contains every item shared between all the
  // passed-in arrays. (Aliased as "intersect" for back-compat.)
  _.intersection = _.intersect = function(array) {
    var rest = slice.call(arguments, 1);
    return _.filter(_.uniq(array), function(item) {
      return _.every(rest, function(other) {
        return _.indexOf(other, item) >= 0;
      });
    });
  };

  // Take the difference between one array and another.
  // Only the elements present in just the first array will remain.
  _.difference = function(array, other) {
    return _.filter(array, function(value){ return !_.include(other, value); });
  };

  // Zip together multiple lists into a single array -- elements that share
  // an index go together.
  _.zip = function() {
    var args = slice.call(arguments);
    var length = _.max(_.pluck(args, 'length'));
    var results = new Array(length);
    for (var i = 0; i < length; i++) results[i] = _.pluck(args, "" + i);
    return results;
  };

  // If the browser doesn't supply us with indexOf (I'm looking at you, **MSIE**),
  // we need this function. Return the position of the first occurrence of an
  // item in an array, or -1 if the item is not included in the array.
  // Delegates to **ECMAScript 5**'s native `indexOf` if available.
  // If the array is large and already in sort order, pass `true`
  // for **isSorted** to use binary search.
  _.indexOf = function(array, item, isSorted) {
    if (array == null) return -1;
    var i, l;
    if (isSorted) {
      i = _.sortedIndex(array, item);
      return array[i] === item ? i : -1;
    }
    if (nativeIndexOf && array.indexOf === nativeIndexOf) return array.indexOf(item);
    for (i = 0, l = array.length; i < l; i++) if (array[i] === item) return i;
    return -1;
  };

  // Delegates to **ECMAScript 5**'s native `lastIndexOf` if available.
  _.lastIndexOf = function(array, item) {
    if (array == null) return -1;
    if (nativeLastIndexOf && array.lastIndexOf === nativeLastIndexOf) return array.lastIndexOf(item);
    var i = array.length;
    while (i--) if (array[i] === item) return i;
    return -1;
  };

  // Generate an integer Array containing an arithmetic progression. A port of
  // the native Python `range()` function. See
  // [the Python documentation](http://docs.python.org/library/functions.html#range).
  _.range = function(start, stop, step) {
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }
    step = arguments[2] || 1;

    var len = Math.max(Math.ceil((stop - start) / step), 0);
    var idx = 0;
    var range = new Array(len);

    while(idx < len) {
      range[idx++] = start;
      start += step;
    }

    return range;
  };

  // Function (ahem) Functions
  // ------------------

  // Reusable constructor function for prototype setting.
  var ctor = function(){};

  // Create a function bound to a given object (assigning `this`, and arguments,
  // optionally). Binding with arguments is also known as `curry`.
  // Delegates to **ECMAScript 5**'s native `Function.bind` if available.
  // We check for `func.bind` first, to fail fast when `func` is undefined.
  _.bind = function bind(func, context) {
    var bound, args;
    if (func.bind === nativeBind && nativeBind) return nativeBind.apply(func, slice.call(arguments, 1));
    if (!_.isFunction(func)) throw new TypeError;
    args = slice.call(arguments, 2);
    return bound = function() {
      if (!(this instanceof bound)) return func.apply(context, args.concat(slice.call(arguments)));
      ctor.prototype = func.prototype;
      var self = new ctor;
      var result = func.apply(self, args.concat(slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  };

  // Bind all of an object's methods to that object. Useful for ensuring that
  // all callbacks defined on an object belong to it.
  _.bindAll = function(obj) {
    var funcs = slice.call(arguments, 1);
    if (funcs.length == 0) funcs = _.functions(obj);
    each(funcs, function(f) { obj[f] = _.bind(obj[f], obj); });
    return obj;
  };

  // Memoize an expensive function by storing its results.
  _.memoize = function(func, hasher) {
    var memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key = hasher.apply(this, arguments);
      return hasOwnProperty.call(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
    };
  };

  // Delays a function for the given number of milliseconds, and then calls
  // it with the arguments supplied.
  _.delay = function(func, wait) {
    var args = slice.call(arguments, 2);
    return setTimeout(function(){ return func.apply(func, args); }, wait);
  };

  // Defers a function, scheduling it to run after the current call stack has
  // cleared.
  _.defer = function(func) {
    return _.delay.apply(_, [func, 1].concat(slice.call(arguments, 1)));
  };

  // Returns a function, that, when invoked, will only be triggered at most once
  // during a given window of time.
  _.throttle = function(func, wait) {
    var context, args, timeout, throttling, more;
    var whenDone = _.debounce(function(){ more = throttling = false; }, wait);
    return function() {
      context = this; args = arguments;
      var later = function() {
        timeout = null;
        if (more) func.apply(context, args);
        whenDone();
      };
      if (!timeout) timeout = setTimeout(later, wait);
      if (throttling) {
        more = true;
      } else {
        func.apply(context, args);
      }
      whenDone();
      throttling = true;
    };
  };

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds.
  _.debounce = function(func, wait) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        func.apply(context, args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  };

  // Returns a function that will be executed at most one time, no matter how
  // often you call it. Useful for lazy initialization.
  _.once = function(func) {
    var ran = false, memo;
    return function() {
      if (ran) return memo;
      ran = true;
      return memo = func.apply(this, arguments);
    };
  };

  // Returns the first function passed as an argument to the second,
  // allowing you to adjust arguments, run code before and after, and
  // conditionally execute the original function.
  _.wrap = function(func, wrapper) {
    return function() {
      var args = [func].concat(slice.call(arguments));
      return wrapper.apply(this, args);
    };
  };

  // Returns a function that is the composition of a list of functions, each
  // consuming the return value of the function that follows.
  _.compose = function() {
    var funcs = slice.call(arguments);
    return function() {
      var args = slice.call(arguments);
      for (var i = funcs.length - 1; i >= 0; i--) {
        args = [funcs[i].apply(this, args)];
      }
      return args[0];
    };
  };

  // Returns a function that will only be executed after being called N times.
  _.after = function(times, func) {
    return function() {
      if (--times < 1) { return func.apply(this, arguments); }
    };
  };

  // Object Functions
  // ----------------

  // Retrieve the names of an object's properties.
  // Delegates to **ECMAScript 5**'s native `Object.keys`
  _.keys = nativeKeys || function(obj) {
    if (obj !== Object(obj)) throw new TypeError('Invalid object');
    var keys = [];
    for (var key in obj) if (hasOwnProperty.call(obj, key)) keys[keys.length] = key;
    return keys;
  };

  // Retrieve the values of an object's properties.
  _.values = function(obj) {
    return _.map(obj, _.identity);
  };

  // Return a sorted list of the function names available on the object.
  // Aliased as `methods`
  _.functions = _.methods = function(obj) {
    var names = [];
    for (var key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  // Extend a given object with all the properties in passed-in object(s).
  _.extend = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      for (var prop in source) {
        if (source[prop] !== void 0) obj[prop] = source[prop];
      }
    });
    return obj;
  };

  // Fill in a given object with default properties.
  _.defaults = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      for (var prop in source) {
        if (obj[prop] == null) obj[prop] = source[prop];
      }
    });
    return obj;
  };

  // Create a (shallow-cloned) duplicate of an object.
  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
  };

  // Invokes interceptor with the obj, and then returns obj.
  // The primary purpose of this method is to "tap into" a method chain, in
  // order to perform operations on intermediate results within the chain.
  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  // Internal recursive comparison function.
  function eq(a, b, stack) {
    // Identical objects are equal. `0 === -0`, but they aren't identical.
    // See the Harmony `egal` proposal: http://wiki.ecmascript.org/doku.php?id=harmony:egal.
    if (a === b) return a !== 0 || 1 / a == 1 / b;
    // A strict comparison is necessary because `null == undefined`.
    if ((a == null) || (b == null)) return a === b;
    // Unwrap any wrapped objects.
    if (a._chain) a = a._wrapped;
    if (b._chain) b = b._wrapped;
    // Invoke a custom `isEqual` method if one is provided.
    if (_.isFunction(a.isEqual)) return a.isEqual(b);
    if (_.isFunction(b.isEqual)) return b.isEqual(a);
    // Compare object types.
    var typeA = typeof a;
    if (typeA != typeof b) return false;
    // Optimization; ensure that both values are truthy or falsy.
    if (!a != !b) return false;
    // `NaN` values are equal.
    if (_.isNaN(a)) return _.isNaN(b);
    // Compare string objects by value.
    var isStringA = _.isString(a), isStringB = _.isString(b);
    if (isStringA || isStringB) return isStringA && isStringB && String(a) == String(b);
    // Compare number objects by value.
    var isNumberA = _.isNumber(a), isNumberB = _.isNumber(b);
    if (isNumberA || isNumberB) return isNumberA && isNumberB && +a == +b;
    // Compare boolean objects by value. The value of `true` is 1; the value of `false` is 0.
    var isBooleanA = _.isBoolean(a), isBooleanB = _.isBoolean(b);
    if (isBooleanA || isBooleanB) return isBooleanA && isBooleanB && +a == +b;
    // Compare dates by their millisecond values.
    var isDateA = _.isDate(a), isDateB = _.isDate(b);
    if (isDateA || isDateB) return isDateA && isDateB && a.getTime() == b.getTime();
    // Compare RegExps by their source patterns and flags.
    var isRegExpA = _.isRegExp(a), isRegExpB = _.isRegExp(b);
    if (isRegExpA || isRegExpB) {
      // Ensure commutative equality for RegExps.
      return isRegExpA && isRegExpB &&
             a.source == b.source &&
             a.global == b.global &&
             a.multiline == b.multiline &&
             a.ignoreCase == b.ignoreCase;
    }
    // Ensure that both values are objects.
    if (typeA != 'object') return false;
    // Arrays or Arraylikes with different lengths are not equal.
    if (a.length !== b.length) return false;
    // Objects with different constructors are not equal.
    if (a.constructor !== b.constructor) return false;
    // Assume equality for cyclic structures. The algorithm for detecting cyclic
    // structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
    var length = stack.length;
    while (length--) {
      // Linear search. Performance is inversely proportional to the number of
      // unique nested structures.
      if (stack[length] == a) return true;
    }
    // Add the first object to the stack of traversed objects.
    stack.push(a);
    var size = 0, result = true;
    // Deep compare objects.
    for (var key in a) {
      if (hasOwnProperty.call(a, key)) {
        // Count the expected number of properties.
        size++;
        // Deep compare each member.
        if (!(result = hasOwnProperty.call(b, key) && eq(a[key], b[key], stack))) break;
      }
    }
    // Ensure that both objects contain the same number of properties.
    if (result) {
      for (key in b) {
        if (hasOwnProperty.call(b, key) && !(size--)) break;
      }
      result = !size;
    }
    // Remove the first object from the stack of traversed objects.
    stack.pop();
    return result;
  }

  // Perform a deep comparison to check if two objects are equal.
  _.isEqual = function(a, b) {
    return eq(a, b, []);
  };

  // Is a given array, string, or object empty?
  // An "empty" object has no enumerable own-properties.
  _.isEmpty = function(obj) {
    if (_.isArray(obj) || _.isString(obj)) return obj.length === 0;
    for (var key in obj) if (hasOwnProperty.call(obj, key)) return false;
    return true;
  };

  // Is a given value a DOM element?
  _.isElement = function(obj) {
    return !!(obj && obj.nodeType == 1);
  };

  // Is a given value an array?
  // Delegates to ECMA5's native Array.isArray
  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj) == '[object Array]';
  };

  // Is a given variable an object?
  _.isObject = function(obj) {
    return obj === Object(obj);
  };

  // Is a given variable an arguments object?
  if (toString.call(arguments) == '[object Arguments]') {
    _.isArguments = function(obj) {
      return toString.call(obj) == '[object Arguments]';
    };
  } else {
    _.isArguments = function(obj) {
      return !!(obj && hasOwnProperty.call(obj, 'callee'));
    };
  }

  // Is a given value a function?
  _.isFunction = function(obj) {
    return toString.call(obj) == '[object Function]';
  };

  // Is a given value a string?
  _.isString = function(obj) {
    return toString.call(obj) == '[object String]';
  };

  // Is a given value a number?
  _.isNumber = function(obj) {
    return toString.call(obj) == '[object Number]';
  };

  // Is the given value `NaN`?
  _.isNaN = function(obj) {
    // `NaN` is the only value for which `===` is not reflexive.
    return obj !== obj;
  };

  // Is a given value a boolean?
  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj) == '[object Boolean]';
  };

  // Is a given value a date?
  _.isDate = function(obj) {
    return toString.call(obj) == '[object Date]';
  };

  // Is the given value a regular expression?
  _.isRegExp = function(obj) {
    return toString.call(obj) == '[object RegExp]';
  };

  // Is a given value equal to null?
  _.isNull = function(obj) {
    return obj === null;
  };

  // Is a given variable undefined?
  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  // Utility Functions
  // -----------------

  // Run Underscore.js in *noConflict* mode, returning the `_` variable to its
  // previous owner. Returns a reference to the Underscore object.
  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  // Keep the identity function around for default iterators.
  _.identity = function(value) {
    return value;
  };

  // Run a function **n** times.
  _.times = function (n, iterator, context) {
    for (var i = 0; i < n; i++) iterator.call(context, i);
  };

  // Escape a string for HTML interpolation.
  _.escape = function(string) {
    return (''+string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;');
  };

  // Add your own custom functions to the Underscore object, ensuring that
  // they're correctly added to the OOP wrapper as well.
  _.mixin = function(obj) {
    each(_.functions(obj), function(name){
      addToWrapper(name, _[name] = obj[name]);
    });
  };

  // Generate a unique integer id (unique within the entire client session).
  // Useful for temporary DOM ids.
  var idCounter = 0;
  _.uniqueId = function(prefix) {
    var id = idCounter++;
    return prefix ? prefix + id : id;
  };

  // By default, Underscore uses ERB-style template delimiters, change the
  // following template settings to use alternative delimiters.
  _.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g,
    escape      : /<%-([\s\S]+?)%>/g
  };

  // JavaScript micro-templating, similar to John Resig's implementation.
  // Underscore templating handles arbitrary delimiters, preserves whitespace,
  // and correctly escapes quotes within interpolated code.
  _.template = function(str, data) {
    var c  = _.templateSettings;
    var tmpl = 'var __p=[],print=function(){__p.push.apply(__p,arguments);};' +
      'with(obj||{}){__p.push(\'' +
      str.replace(/\\/g, '\\\\')
         .replace(/'/g, "\\'")
         .replace(c.escape, function(match, code) {
           return "',_.escape(" + code.replace(/\\'/g, "'") + "),'";
         })
         .replace(c.interpolate, function(match, code) {
           return "'," + code.replace(/\\'/g, "'") + ",'";
         })
         .replace(c.evaluate || null, function(match, code) {
           return "');" + code.replace(/\\'/g, "'")
                              .replace(/[\r\n\t]/g, ' ') + "__p.push('";
         })
         .replace(/\r/g, '\\r')
         .replace(/\n/g, '\\n')
         .replace(/\t/g, '\\t')
         + "');}return __p.join('');";
    var func = new Function('obj', '_', tmpl);
    return data ? func(data, _) : function(data) { return func(data, _) };
  };

  // The OOP Wrapper
  // ---------------

  // If Underscore is called as a function, it returns a wrapped object that
  // can be used OO-style. This wrapper holds altered versions of all the
  // underscore functions. Wrapped objects may be chained.
  var wrapper = function(obj) { this._wrapped = obj; };

  // Expose `wrapper.prototype` as `_.prototype`
  _.prototype = wrapper.prototype;

  // Helper function to continue chaining intermediate results.
  var result = function(obj, chain) {
    return chain ? _(obj).chain() : obj;
  };

  // A method to easily add functions to the OOP wrapper.
  var addToWrapper = function(name, func) {
    wrapper.prototype[name] = function() {
      var args = slice.call(arguments);
      unshift.call(args, this._wrapped);
      return result(func.apply(_, args), this._chain);
    };
  };

  // Add all of the Underscore functions to the wrapper object.
  _.mixin(_);

  // Add all mutator Array functions to the wrapper.
  each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method = ArrayProto[name];
    wrapper.prototype[name] = function() {
      method.apply(this._wrapped, arguments);
      return result(this._wrapped, this._chain);
    };
  });

  // Add all accessor Array functions to the wrapper.
  each(['concat', 'join', 'slice'], function(name) {
    var method = ArrayProto[name];
    wrapper.prototype[name] = function() {
      return result(method.apply(this._wrapped, arguments), this._chain);
    };
  });

  // Start chaining a wrapped Underscore object.
  wrapper.prototype.chain = function() {
    this._chain = true;
    return this;
  };

  // Extracts the result from a wrapped and chained object.
  wrapper.prototype.value = function() {
    return this._wrapped;
  };

}).call(this);

// Mock QUnit and run tests
(function() {
	function module() { /* nop */ }
	function equals(a, b, msg) {
		assert(a == b, msg + ", <" + a + "> != <" + b + ">");
	}
	var equal = equals;
	function notStrictEqual(a, b, msg) {
		assert(a !== b, msg);
	}
	function ok(a, msg) {
		assert(a, msg);
	}
	// raises implementation taken from QUnit
	/*
	 * QUnit - A JavaScript Unit Testing Framework
	 *
	 * http://docs.jquery.com/QUnit
	 *
	 * Copyright (c) 2009 John Resig, JÃ¶rn Zaefferer
	 * Dual licensed under the MIT (MIT-LICENSE.txt)
	 * and GPL (GPL-LICENSE.txt) licenses.
	 */
	function raises(fn, expected, message) {
		var actual, _ok = false;
		if(typeof expected === "string") {
			message = expected;
			expected = null;
		}
		
		try {
			fn();
		} catch(e) {
			actual = e;
		}
		
		if(actual) {
			if(!expected) {
				_ok = true;
			} else if(expected instanceof RegExp) {
				_ok = expected.test(actual);
			} else if(actual instanceof expected) {
				_ok = true
			} else if(expected.call({}, actual) === true) {
				_ok = true;
			}
		}
		
		ok(_ok, message);
	}
	function asyncTest(msg, expected, callback) {
		/*test(msg, function() {
			ok(false, "asyncTest not implemented yet!");
		});*/
	}
	
	// actual unit tests:
  test("arrays: first", function() {
    equals(_.first([1,2,3]), 1, 'can pull out the first element of an array');
    equals(_([1, 2, 3]).first(), 1, 'can perform OO-style "first()"');
    equals(_.first([1,2,3], 0).join(', '), "", 'can pass an index to first');
    equals(_.first([1,2,3], 2).join(', '), '1, 2', 'can pass an index to first');
    var result = (function(){ return _.first(arguments); })(4, 3, 2, 1);
    equals(result, 4, 'works on an arguments object.');
    result = _.map([[1,2,3],[1,2,3]], _.first);
    equals(result.join(','), '1,1', 'works well with _.map');
  });

  test("arrays: rest", function() {
    var numbers = [1, 2, 3, 4];
    equals(_.rest(numbers).join(", "), "2, 3, 4", 'working rest()');
    equals(_.rest(numbers, 0).join(", "), "1, 2, 3, 4", 'working rest(0)');
    equals(_.rest(numbers, 2).join(', '), '3, 4', 'rest can take an index');
    var result = (function(){ return _(arguments).tail(); })(1, 2, 3, 4);
    equals(result.join(', '), '2, 3, 4', 'aliased as tail and works on arguments object');
    result = _.map([[1,2,3],[1,2,3]], _.rest);
    equals(_.flatten(result).join(','), '2,3,2,3', 'works well with _.map');
  });

  test("arrays: initial", function() {
    equals(_.initial([1,2,3,4,5]).join(", "), "1, 2, 3, 4", 'working initial()');
    equals(_.initial([1,2,3,4],2).join(", "), "1, 2", 'initial can take an index');
    var result = (function(){ return _(arguments).initial(); })(1, 2, 3, 4);
    equals(result.join(", "), "1, 2, 3", 'initial works on arguments object');
    result = _.map([[1,2,3],[1,2,3]], _.initial);
    equals(_.flatten(result).join(','), '1,2,1,2', 'initial works with _.map');
  });

  test("arrays: last", function() {
    equals(_.last([1,2,3]), 3, 'can pull out the last element of an array');
    equals(_.last([1,2,3], 0).join(', '), "", 'can pass an index to last');
    equals(_.last([1,2,3], 2).join(', '), '2, 3', 'can pass an index to last');
    var result = (function(){ return _(arguments).last(); })(1, 2, 3, 4);
    equals(result, 4, 'works on an arguments object');
    result = _.map([[1,2,3],[1,2,3]], _.last);
    equals(result.join(','), '3,3', 'works well with _.map');
  });

  test("arrays: compact", function() {
    equals(_.compact([0, 1, false, 2, false, 3]).length, 3, 'can trim out all falsy values');
    var result = (function(){ return _(arguments).compact().length; })(0, 1, false, 2, false, 3);
    equals(result, 3, 'works on an arguments object');
  });

  test("arrays: flatten", function() {
    if (window.JSON) {
      var list = [1, [2], [3, [[[4]]]]];
      equals(JSON.stringify(_.flatten(list)), '[1,2,3,4]', 'can flatten nested arrays');
      equals(JSON.stringify(_.flatten(list, true)), '[1,2,3,[[[4]]]]', 'can shallowly flatten nested arrays');
      var result = (function(){ return _.flatten(arguments); })(1, [2], [3, [[[4]]]]);
      equals(JSON.stringify(result), '[1,2,3,4]', 'works on an arguments object');
    }
  });

  test("arrays: without", function() {
    var list = [1, 2, 1, 0, 3, 1, 4];
    equals(_.without(list, 0, 1).join(', '), '2, 3, 4', 'can remove all instances of an object');
    var result = (function(){ return _.without(arguments, 0, 1); })(1, 2, 1, 0, 3, 1, 4);
    equals(result.join(', '), '2, 3, 4', 'works on an arguments object');

    var list = [{one : 1}, {two : 2}];
    ok(_.without(list, {one : 1}).length == 2, 'uses real object identity for comparisons.');
    ok(_.without(list, list[0]).length == 1, 'ditto.');
  });

  test("arrays: uniq", function() {
    var list = [1, 2, 1, 3, 1, 4];
    equals(_.uniq(list).join(', '), '1, 2, 3, 4', 'can find the unique values of an unsorted array');

    var list = [1, 1, 1, 2, 2, 3];
    equals(_.uniq(list, true).join(', '), '1, 2, 3', 'can find the unique values of a sorted array faster');

    var list = [{name:'moe'}, {name:'curly'}, {name:'larry'}, {name:'curly'}];
    var iterator = function(value) { return value.name; };
    equals(_.map(_.uniq(list, false, iterator), iterator).join(', '), 'moe, curly, larry', 'can find the unique values of an array using a custom iterator');

    var iterator = function(value) { return value +1; };
    var list = [1, 2, 2, 3, 4, 4];
    equals(_.uniq(list, true, iterator).join(', '), '1, 2, 3, 4', 'iterator works with sorted array');

    var result = (function(){ return _.uniq(arguments); })(1, 2, 1, 3, 1, 4);
    equals(result.join(', '), '1, 2, 3, 4', 'works on an arguments object');
  });

  test("arrays: intersection", function() {
    var stooges = ['moe', 'curly', 'larry'], leaders = ['moe', 'groucho'];
    equals(_.intersection(stooges, leaders).join(''), 'moe', 'can take the set intersection of two arrays');
    equals(_(stooges).intersection(leaders).join(''), 'moe', 'can perform an OO-style intersection');
    var result = (function(){ return _.intersection(arguments, leaders); })('moe', 'curly', 'larry');
    equals(result.join(''), 'moe', 'works on an arguments object');
  });

  test("arrays: union", function() {
    var result = _.union([1, 2, 3], [2, 30, 1], [1, 40]);
    equals(result.join(' '), '1 2 3 30 40', 'takes the union of a list of arrays');

    var result = _.union([1, 2, 3], [2, 30, 1], [1, 40, [1]]);
    equals(result.join(' '), '1 2 3 30 40 1', 'takes the union of a list of nested arrays');
  });

  test("arrays: difference", function() {
    var result = _.difference([1, 2, 3], [2, 30, 40]);
    equals(result.join(' '), '1 3', 'takes the difference of two arrays');
  });

  test('arrays: zip', function() {
    var names = ['moe', 'larry', 'curly'], ages = [30, 40, 50], leaders = [true];
    var stooges = _.zip(names, ages, leaders);
    equals(String(stooges), 'moe,30,true,larry,40,,curly,50,', 'zipped together arrays of different lengths');
  });

  test("arrays: indexOf", function() {
    var numbers = [1, 2, 3];
    numbers.indexOf = null;
    equals(_.indexOf(numbers, 2), 1, 'can compute indexOf, even without the native function');
    var result = (function(){ return _.indexOf(arguments, 2); })(1, 2, 3);
    equals(result, 1, 'works on an arguments object');
    equals(_.indexOf(null, 2), -1, 'handles nulls properly');

    var numbers = [10, 20, 30, 40, 50], num = 35;
    var index = _.indexOf(numbers, num, true);
    equals(index, -1, '35 is not in the list');

    numbers = [10, 20, 30, 40, 50]; num = 40;
    index = _.indexOf(numbers, num, true);
    equals(index, 3, '40 is in the list');

    numbers = [1, 40, 40, 40, 40, 40, 40, 40, 50, 60, 70]; num = 40;
    index = _.indexOf(numbers, num, true);
    equals(index, 1, '40 is in the list');
  });

  test("arrays: lastIndexOf", function() {
    var numbers = [1, 0, 1, 0, 0, 1, 0, 0, 0];
    numbers.lastIndexOf = null;
    equals(_.lastIndexOf(numbers, 1), 5, 'can compute lastIndexOf, even without the native function');
    equals(_.lastIndexOf(numbers, 0), 8, 'lastIndexOf the other element');
    var result = (function(){ return _.lastIndexOf(arguments, 1); })(1, 0, 1, 0, 0, 1, 0, 0, 0);
    equals(result, 5, 'works on an arguments object');
    equals(_.indexOf(null, 2), -1, 'handles nulls properly');
  });

  test("arrays: range", function() {
    equals(_.range(0).join(''), '', 'range with 0 as a first argument generates an empty array');
    equals(_.range(4).join(' '), '0 1 2 3', 'range with a single positive argument generates an array of elements 0,1,2,...,n-1');
    equals(_.range(5, 8).join(' '), '5 6 7', 'range with two arguments a &amp; b, a&lt;b generates an array of elements a,a+1,a+2,...,b-2,b-1');
    equals(_.range(8, 5).join(''), '', 'range with two arguments a &amp; b, b&lt;a generates an empty array');
    equals(_.range(3, 10, 3).join(' '), '3 6 9', 'range with three arguments a &amp; b &amp; c, c &lt; b-a, a &lt; b generates an array of elements a,a+c,a+2c,...,b - (multiplier of a) &lt; c');
    equals(_.range(3, 10, 15).join(''), '3', 'range with three arguments a &amp; b &amp; c, c &gt; b-a, a &lt; b generates an array with a single element, equal to a');
    equals(_.range(12, 7, -2).join(' '), '12 10 8', 'range with three arguments a &amp; b &amp; c, a &gt; b, c &lt; 0 generates an array of elements a,a-c,a-2c and ends with the number not less than b');
    equals(_.range(0, -10, -1).join(' '), '0 -1 -2 -3 -4 -5 -6 -7 -8 -9', 'final example in the Python docs');
  });

  test("chaining: map/flatten/reduce", function() {
    var lyrics = [
      "I'm a lumberjack and I'm okay",
      "I sleep all night and I work all day",
      "He's a lumberjack and he's okay",
      "He sleeps all night and he works all day"
    ];
    var counts = _(lyrics).chain()
      .map(function(line) { return line.split(''); })
      .flatten()
      .reduce(function(hash, l) {
        hash[l] = hash[l] || 0;
        hash[l]++;
        return hash;
    }, {}).value();
    ok(counts['a'] == 16 && counts['e'] == 10, 'counted all the letters in the song');
  });

  test("chaining: select/reject/sortBy", function() {
    var numbers = [1,2,3,4,5,6,7,8,9,10];
    numbers = _(numbers).chain().select(function(n) {
      return n % 2 == 0;
    }).reject(function(n) {
      return n % 4 == 0;
    }).sortBy(function(n) {
      return -n;
    }).value();
    equals(numbers.join(', '), "10, 6, 2", "filtered and reversed the numbers");
  });

  test("chaining: reverse/concat/unshift/pop/map", function() {
    var numbers = [1,2,3,4,5];
    numbers = _(numbers).chain()
      .reverse()
      .concat([5, 5, 5])
      .unshift(17)
      .pop()
      .map(function(n){ return n * 2; })
      .value();
    equals(numbers.join(', '), "34, 10, 8, 6, 4, 2, 10, 10", 'can chain together array functions.');
  });

  test("collections: each", function() {
    _.each([1, 2, 3], function(num, i) {
      equals(num, i + 1, 'each iterators provide value and iteration count');
    });

    var answers = [];
    _.each([1, 2, 3], function(num){ answers.push(num * this.multiplier);}, {multiplier : 5});
    equals(answers.join(', '), '5, 10, 15', 'context object property accessed');

    answers = [];
    _.forEach([1, 2, 3], function(num){ answers.push(num); });
    equals(answers.join(', '), '1, 2, 3', 'aliased as "forEach"');

    answers = [];
    var obj = {one : 1, two : 2, three : 3};
    obj.constructor.prototype.four = 4;
    _.each(obj, function(value, key){ answers.push(key); });
    equals(answers.join(", "), 'one, two, three', 'iterating over objects works, and ignores the object prototype.');
    delete obj.constructor.prototype.four;

    answer = null;
    _.each([1, 2, 3], function(num, index, arr){ if (_.include(arr, num)) answer = true; });
    ok(answer, 'can reference the original collection from inside the iterator');

    answers = 0;
    _.each(null, function(){ ++answers; });
    equals(answers, 0, 'handles a null properly');
  });

  test('collections: map', function() {
    var doubled = _.map([1, 2, 3], function(num){ return num * 2; });
    equals(doubled.join(', '), '2, 4, 6', 'doubled numbers');

    var tripled = _.map([1, 2, 3], function(num){ return num * this.multiplier; }, {multiplier : 3});
    equals(tripled.join(', '), '3, 6, 9', 'tripled numbers with context');

    var doubled = _([1, 2, 3]).map(function(num){ return num * 2; });
    equals(doubled.join(', '), '2, 4, 6', 'OO-style doubled numbers');

// DOM-specific, not including


    var ifnull = _.map(null, function(){});
    ok(_.isArray(ifnull) && ifnull.length === 0, 'handles a null properly');
  });

  test('collections: reduce', function() {
    var sum = _.reduce([1, 2, 3], function(sum, num){ return sum + num; }, 0);
    equals(sum, 6, 'can sum up an array');

    var context = {multiplier : 3};
    sum = _.reduce([1, 2, 3], function(sum, num){ return sum + num * this.multiplier; }, 0, context);
    equals(sum, 18, 'can reduce with a context object');

    sum = _.inject([1, 2, 3], function(sum, num){ return sum + num; }, 0);
    equals(sum, 6, 'aliased as "inject"');

    sum = _([1, 2, 3]).reduce(function(sum, num){ return sum + num; }, 0);
    equals(sum, 6, 'OO-style reduce');

    var sum = _.reduce([1, 2, 3], function(sum, num){ return sum + num; });
    equals(sum, 6, 'default initial value');


    var ifnull;
    try {
      _.reduce(null, function(){});
    } catch (ex) {
      ifnull = ex;
    }
    ok(ifnull instanceof TypeError, 'handles a null (without inital value) properly');

    ok(_.reduce(null, function(){}, 138) === 138, 'handles a null (with initial value) properly');

    // Sparse arrays:
    var sparseArray  = [];
    sparseArray[100] = 10;
    sparseArray[200] = 20;

    equals(_.reduce(sparseArray, function(a, b){ return a + b }), 30, 'initially-sparse arrays with no memo');
  });

  test('collections: reduceRight', function() {
    var list = _.reduceRight(["foo", "bar", "baz"], function(memo, str){ return memo + str; }, '');
    equals(list, 'bazbarfoo', 'can perform right folds');

    var list = _.foldr(["foo", "bar", "baz"], function(memo, str){ return memo + str; }, '');
    equals(list, 'bazbarfoo', 'aliased as "foldr"');

    var list = _.foldr(["foo", "bar", "baz"], function(memo, str){ return memo + str; });
    equals(list, 'bazbarfoo', 'default initial value');

    var ifnull;
    try {
      _.reduceRight(null, function(){});
    } catch (ex) {
      ifnull = ex;
    }
    ok(ifnull instanceof TypeError, 'handles a null (without inital value) properly');

    ok(_.reduceRight(null, function(){}, 138) === 138, 'handles a null (with initial value) properly');
  });

  test('collections: detect', function() {
    var result = _.detect([1, 2, 3], function(num){ return num * 2 == 4; });
    equals(result, 2, 'found the first "2" and broke the loop');
  });

  test('collections: select', function() {
    var evens = _.select([1, 2, 3, 4, 5, 6], function(num){ return num % 2 == 0; });
    equals(evens.join(', '), '2, 4, 6', 'selected each even number');

    evens = _.filter([1, 2, 3, 4, 5, 6], function(num){ return num % 2 == 0; });
    equals(evens.join(', '), '2, 4, 6', 'aliased as "filter"');
  });

  test('collections: reject', function() {
    var odds = _.reject([1, 2, 3, 4, 5, 6], function(num){ return num % 2 == 0; });
    equals(odds.join(', '), '1, 3, 5', 'rejected each even number');
  });

  test('collections: all', function() {
    ok(_.all([], _.identity), 'the empty set');
    ok(_.all([true, true, true], _.identity), 'all true values');
    ok(!_.all([true, false, true], _.identity), 'one false value');
    ok(_.all([0, 10, 28], function(num){ return num % 2 == 0; }), 'even numbers');
    ok(!_.all([0, 11, 28], function(num){ return num % 2 == 0; }), 'an odd number');
    ok(_.every([true, true, true], _.identity), 'aliased as "every"');
  });

  test('collections: any', function() {
    var nativeSome = Array.prototype.some;
    Array.prototype.some = null;
    ok(!_.any([]), 'the empty set');
    ok(!_.any([false, false, false]), 'all false values');
    ok(_.any([false, false, true]), 'one true value');
    ok(!_.any([1, 11, 29], function(num){ return num % 2 == 0; }), 'all odd numbers');
    ok(_.any([1, 10, 29], function(num){ return num % 2 == 0; }), 'an even number');
    ok(_.some([false, false, true]), 'aliased as "some"');
    Array.prototype.some = nativeSome;
  });

  test('collections: include', function() {
    ok(_.include([1,2,3], 2), 'two is in the array');
    ok(!_.include([1,3,9], 2), 'two is not in the array');
    ok(_.contains({moe:1, larry:3, curly:9}, 3) === true, '_.include on objects checks their values');
    ok(_([1,2,3]).include(2), 'OO-style include');
  });

  test('collections: invoke', function() {
    var list = [[5, 1, 7], [3, 2, 1]];
    var result = _.invoke(list, 'sort');
    equals(result[0].join(', '), '1, 5, 7', 'first array sorted');
    equals(result[1].join(', '), '1, 2, 3', 'second array sorted');
  });

  test('collections: invoke w/ function reference', function() {
    var list = [[5, 1, 7], [3, 2, 1]];
    var result = _.invoke(list, Array.prototype.sort);
    equals(result[0].join(', '), '1, 5, 7', 'first array sorted');
    equals(result[1].join(', '), '1, 2, 3', 'second array sorted');
  });

  test('collections: pluck', function() {
    var people = [{name : 'moe', age : 30}, {name : 'curly', age : 50}];
    equals(_.pluck(people, 'name').join(', '), 'moe, curly', 'pulls names out of objects');
  });

  test('collections: max', function() {
    equals(3, _.max([1, 2, 3]), 'can perform a regular Math.max');

    var neg = _.max([1, 2, 3], function(num){ return -num; });
    equals(neg, 1, 'can perform a computation-based max');

    equals(-Infinity, _.max({}), 'Maximum value of an empty object');
    equals(-Infinity, _.max([]), 'Maximum value of an empty array');
  });

  test('collections: min', function() {
    equals(1, _.min([1, 2, 3]), 'can perform a regular Math.min');

    var neg = _.min([1, 2, 3], function(num){ return -num; });
    equals(neg, 3, 'can perform a computation-based min');

    equals(Infinity, _.min({}), 'Minimum value of an empty object');
    equals(Infinity, _.min([]), 'Minimum value of an empty array');
  });

  test('collections: sortBy', function() {
    var people = [{name : 'curly', age : 50}, {name : 'moe', age : 30}];
    people = _.sortBy(people, function(person){ return person.age; });
    equals(_.pluck(people, 'name').join(', '), 'moe, curly', 'stooges sorted by age');
  });

  test('collections: groupBy', function() {
    var parity = _.groupBy([1, 2, 3, 4, 5, 6], function(num){ return num % 2; });
    ok('0' in parity && '1' in parity, 'created a group for each value');
    equals(parity[0].join(', '), '2, 4, 6', 'put each even number in the right group');

    var list = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"];
    var grouped = _.groupBy(list, 'length');
    equals(grouped['3'].join(' '), 'one two six ten');
    equals(grouped['4'].join(' '), 'four five nine');
    equals(grouped['5'].join(' '), 'three seven eight');
  });

  test('collections: sortedIndex', function() {
    var numbers = [10, 20, 30, 40, 50], num = 35;
    var index = _.sortedIndex(numbers, num);
    equals(index, 3, '35 should be inserted at index 3');
  });

  test('collections: shuffle', function() {
    var numbers = _.range(10);
	var shuffled = _.shuffle(numbers).sort();
	notStrictEqual(numbers, shuffled, 'original object is unmodified');
    equals(shuffled.join(','), numbers.join(','), 'contains the same members before and after shuffle');
  });

  test('collections: toArray', function() {
    ok(!_.isArray(arguments), 'arguments object is not an array');
    ok(_.isArray(_.toArray(arguments)), 'arguments object converted into array');
    var a = [1,2,3];
    ok(_.toArray(a) !== a, 'array is cloned');
    equals(_.toArray(a).join(', '), '1, 2, 3', 'cloned array contains same elements');

    var numbers = _.toArray({one : 1, two : 2, three : 3});
    equals(numbers.join(', '), '1, 2, 3', 'object flattened into array');
  });

  test('collections: size', function() {
    equals(_.size({one : 1, two : 2, three : 3}), 3, 'can compute the size of an object');
  });

  test("functions: bind", function() {
    var context = {name : 'moe'};
    var func = function(arg) { return "name: " + (this.name || arg); };
    var bound = _.bind(func, context);
    equals(bound(), 'name: moe', 'can bind a function to a context');

    bound = _(func).bind(context);
    equals(bound(), 'name: moe', 'can do OO-style binding');

    bound = _.bind(func, null, 'curly');
    equals(bound(), 'name: curly', 'can bind without specifying a context');

    func = function(salutation, name) { return salutation + ': ' + name; };
    func = _.bind(func, this, 'hello');
    equals(func('moe'), 'hello: moe', 'the function was partially applied in advance');

    var func = _.bind(func, this, 'curly');
    equals(func(), 'hello: curly', 'the function was completely applied in advance');

    var func = function(salutation, firstname, lastname) { return salutation + ': ' + firstname + ' ' + lastname; };
    func = _.bind(func, this, 'hello', 'moe', 'curly');
    equals(func(), 'hello: moe curly', 'the function was partially applied in advance and can accept multiple arguments');

    func = function(context, message) { equals(this, context, message); };
    _.bind(func, 0, 0, 'can bind a function to `0`')();
    _.bind(func, '', '', 'can bind a function to an empty string')();
    _.bind(func, false, false, 'can bind a function to `false`')();

    // These tests are only meaningful when using a browser without a native bind function
    // To test this with a modern browser, set underscore's nativeBind to undefined
    var F = function () { return this; };
    var Boundf = _.bind(F, {hello: "moe curly"});
    equal(new Boundf().hello, undefined, "function should not be bound to the context, to comply with ECMAScript 5");
    equal(Boundf().hello, "moe curly", "When called without the new operator, it's OK to be bound to the context");
  });

  test("functions: bindAll", function() {
    var curly = {name : 'curly'}, moe = {
      name    : 'moe',
      getName : function() { return 'name: ' + this.name; },
      sayHi   : function() { return 'hi: ' + this.name; }
    };
    curly.getName = moe.getName;
    _.bindAll(moe, 'getName', 'sayHi');
    curly.sayHi = moe.sayHi;
    equals(curly.getName(), 'name: curly', 'unbound function is bound to current object');
    equals(curly.sayHi(), 'hi: moe', 'bound function is still bound to original object');

    curly = {name : 'curly'};
    moe = {
      name    : 'moe',
      getName : function() { return 'name: ' + this.name; },
      sayHi   : function() { return 'hi: ' + this.name; }
    };
    _.bindAll(moe);
    curly.sayHi = moe.sayHi;
    equals(curly.sayHi(), 'hi: moe', 'calling bindAll with no arguments binds all functions to the object');
  });

  test("functions: memoize", function() {
    var fib = function(n) {
      return n < 2 ? n : fib(n - 1) + fib(n - 2);
    };
    var fastFib = _.memoize(fib);
    equals(fib(10), 55, 'a memoized version of fibonacci produces identical results');
    equals(fastFib(10), 55, 'a memoized version of fibonacci produces identical results');

    var o = function(str) {
      return str;
    };
    var fastO = _.memoize(o);
    equals(o('toString'), 'toString', 'checks hasOwnProperty');
    equals(fastO('toString'), 'toString', 'checks hasOwnProperty');
  });

  asyncTest("functions: delay", 2, function() {
    var delayed = false;
    _.delay(function(){ delayed = true; }, 100);
    setTimeout(function(){ ok(!delayed, "didn't delay the function quite yet"); }, 50);
    setTimeout(function(){ ok(delayed, 'delayed the function'); start(); }, 150);
  });

  asyncTest("functions: defer", 1, function() {
    var deferred = false;
    _.defer(function(bool){ deferred = bool; }, true);
    _.delay(function(){ ok(deferred, "deferred the function"); start(); }, 50);
  });

  asyncTest("functions: throttle", 2, function() {
    var counter = 0;
    var incr = function(){ counter++; };
    var throttledIncr = _.throttle(incr, 100);
    throttledIncr(); throttledIncr(); throttledIncr();
    setTimeout(throttledIncr, 70);
    setTimeout(throttledIncr, 120);
    setTimeout(throttledIncr, 140);
    setTimeout(throttledIncr, 190);
    setTimeout(throttledIncr, 220);
    setTimeout(throttledIncr, 240);
    _.delay(function(){ ok(counter == 1, "incr was called immediately"); }, 30);
    _.delay(function(){ ok(counter == 4, "incr was throttled"); start(); }, 400);
  });

  asyncTest("functions: throttle arguments", 2, function() {
    var value = 0;
    var update = function(val){ value = val; };
    var throttledUpdate = _.throttle(update, 100);
    throttledUpdate(1); throttledUpdate(2); throttledUpdate(3);
    setTimeout(function(){ throttledUpdate(4); }, 120);
    setTimeout(function(){ throttledUpdate(5); }, 140);
    setTimeout(function(){ throttledUpdate(6); }, 260);
    setTimeout(function(){ throttledUpdate(7); }, 270);
    _.delay(function(){ ok(value == 1, "updated to latest value"); }, 40);
    _.delay(function(){ ok(value == 7, "updated to latest value"); start(); }, 400);
  });

  asyncTest("functions: throttle once", 1, function() {
    var counter = 0;
    var incr = function(){ counter++; };
    var throttledIncr = _.throttle(incr, 100);
    throttledIncr();
    _.delay(function(){ ok(counter == 1, "incr was called once"); start(); }, 220);
  });

  asyncTest("functions: throttle twice", 1, function() {
    var counter = 0;
    var incr = function(){ counter++; };
    var throttledIncr = _.throttle(incr, 100);
    throttledIncr(); throttledIncr();
    _.delay(function(){ ok(counter == 2, "incr was called twice"); start(); }, 220);
  });

  asyncTest("functions: debounce", 1, function() {
    var counter = 0;
    var incr = function(){ counter++; };
    var debouncedIncr = _.debounce(incr, 50);
    debouncedIncr(); debouncedIncr(); debouncedIncr();
    setTimeout(debouncedIncr, 30);
    setTimeout(debouncedIncr, 60);
    setTimeout(debouncedIncr, 90);
    setTimeout(debouncedIncr, 120);
    setTimeout(debouncedIncr, 150);
    _.delay(function(){ ok(counter == 1, "incr was debounced"); start(); }, 220);
  });

  test("functions: once", function() {
    var num = 0;
    var increment = _.once(function(){ num++; });
    increment();
    increment();
    equals(num, 1);
  });

  test("functions: wrap", function() {
    var greet = function(name){ return "hi: " + name; };
    var backwards = _.wrap(greet, function(func, name){ return func(name) + ' ' + name.split('').reverse().join(''); });
    equals(backwards('moe'), 'hi: moe eom', 'wrapped the saluation function');

    var inner = function(){ return "Hello "; };
    var obj   = {name : "Moe"};
    obj.hi    = _.wrap(inner, function(fn){ return fn() + this.name; });
    equals(obj.hi(), "Hello Moe");
  });

  test("functions: compose", function() {
    var greet = function(name){ return "hi: " + name; };
    var exclaim = function(sentence){ return sentence + '!'; };
    var composed = _.compose(exclaim, greet);
    equals(composed('moe'), 'hi: moe!', 'can compose a function that takes another');

    composed = _.compose(greet, exclaim);
    equals(composed('moe'), 'hi: moe!', 'in this case, the functions are also commutative');
  });

  test("functions: after", function() {
    var testAfter = function(afterAmount, timesCalled) {
      var afterCalled = 0;
      var after = _.after(afterAmount, function() {
        afterCalled++;
      });
      while (timesCalled--) after();
      return afterCalled;
    };

    equals(testAfter(5, 5), 1, "after(N) should fire after being called N times");
    equals(testAfter(5, 4), 0, "after(N) should not fire unless called N times");
  });

  test("objects: keys", function() {
    var exception = /object/;
    equals(_.keys({one : 1, two : 2}).join(', '), 'one, two', 'can extract the keys from an object');
    // the test above is not safe because it relies on for-in enumeration order
    var a = []; a[1] = 0;
    equals(_.keys(a).join(', '), '1', 'is not fooled by sparse arrays; see issue #95');
    raises(function() { _.keys(null); }, exception, 'throws an error for `null` values');
    raises(function() { _.keys(void 0); }, exception, 'throws an error for `undefined` values');
    raises(function() { _.keys(1); }, exception, 'throws an error for number primitives');
    raises(function() { _.keys('a'); }, exception, 'throws an error for string primitives');
    raises(function() { _.keys(true); }, exception, 'throws an error for boolean primitives');
  });

  test("objects: values", function() {
    equals(_.values({one : 1, two : 2}).join(', '), '1, 2', 'can extract the values from an object');
  });

  test("objects: functions", function() {
    var obj = {a : 'dash', b : _.map, c : (/yo/), d : _.reduce};
    ok(_.isEqual(['b', 'd'], _.functions(obj)), 'can grab the function names of any passed-in object');

    var Animal = function(){};
    Animal.prototype.run = function(){};
    equals(_.functions(new Animal).join(''), 'run', 'also looks up functions on the prototype');
  });

  test("objects: extend", function() {
    var result;
    equals(_.extend({}, {a:'b'}).a, 'b', 'can extend an object with the attributes of another');
    equals(_.extend({a:'x'}, {a:'b'}).a, 'b', 'properties in source override destination');
    equals(_.extend({x:'x'}, {a:'b'}).x, 'x', 'properties not in source dont get overriden');
    result = _.extend({x:'x'}, {a:'a'}, {b:'b'});
    ok(_.isEqual(result, {x:'x', a:'a', b:'b'}), 'can extend from multiple source objects');
    result = _.extend({x:'x'}, {a:'a', x:2}, {a:'b'});
    ok(_.isEqual(result, {x:2, a:'b'}), 'extending from multiple source objects last property trumps');
    result = _.extend({}, {a: void 0, b: null});
    equals(_.keys(result).join(''), 'b', 'extend does not copy undefined values');
  });

  test("objects: defaults", function() {
    var result;
    var options = {zero: 0, one: 1, empty: "", nan: NaN, string: "string"};

    _.defaults(options, {zero: 1, one: 10, twenty: 20});
    equals(options.zero, 0, 'value exists');
    equals(options.one, 1, 'value exists');
    equals(options.twenty, 20, 'default applied');

    _.defaults(options, {empty: "full"}, {nan: "nan"}, {word: "word"}, {word: "dog"});
    equals(options.empty, "", 'value exists');
    ok(_.isNaN(options.nan), "NaN isn't overridden");
    equals(options.word, "word", 'new value is added, first one wins');
  });

  test("objects: clone", function() {
    var moe = {name : 'moe', lucky : [13, 27, 34]};
    var clone = _.clone(moe);
    equals(clone.name, 'moe', 'the clone as the attributes of the original');

    clone.name = 'curly';
    ok(clone.name == 'curly' && moe.name == 'moe', 'clones can change shallow attributes without affecting the original');

    clone.lucky.push(101);
    equals(_.last(moe.lucky), 101, 'changes to deep attributes are shared with the original');

    equals(_.clone(undefined), void 0, 'non objects should not be changed by clone');
    equals(_.clone(1), 1, 'non objects should not be changed by clone');
    equals(_.clone(null), null, 'non objects should not be changed by clone');
  });

  test("objects: isEqual", function() {
    function First() {
      this.value = 1;
    }
    First.prototype.value = 1;
    function Second() {
      this.value = 1;
    }
    Second.prototype.value = 2;

    // Basic equality and identity comparisons.
    ok(_.isEqual(null, null), "`null` is equal to `null`");
    ok(_.isEqual(), "`undefined` is equal to `undefined`");

    ok(!_.isEqual(0, -0), "`0` is not equal to `-0`");
    ok(!_.isEqual(-0, 0), "Commutative equality is implemented for `0` and `-0`");
    ok(!_.isEqual(null, undefined), "`null` is not equal to `undefined`");
    ok(!_.isEqual(undefined, null), "Commutative equality is implemented for `null` and `undefined`");

    // String object and primitive comparisons.
    ok(_.isEqual("Curly", "Curly"), "Identical string primitives are equal");
    ok(_.isEqual(new String("Curly"), new String("Curly")), "String objects with identical primitive values are equal");

    ok(!_.isEqual("Curly", "Larry"), "String primitives with different values are not equal");
    ok(!_.isEqual(new String("Curly"), "Curly"), "String primitives and their corresponding object wrappers are not equal");
    ok(!_.isEqual("Curly", new String("Curly")), "Commutative equality is implemented for string objects and primitives");
    ok(!_.isEqual(new String("Curly"), new String("Larry")), "String objects with different primitive values are not equal");
    ok(!_.isEqual(new String("Curly"), {toString: function(){ return "Curly"; }}), "String objects and objects with a custom `toString` method are not equal");

    // Number object and primitive comparisons.
    ok(_.isEqual(75, 75), "Identical number primitives are equal");
    ok(_.isEqual(new Number(75), new Number(75)), "Number objects with identical primitive values are equal");

    ok(!_.isEqual(75, new Number(75)), "Number primitives and their corresponding object wrappers are not equal");
    ok(!_.isEqual(new Number(75), 75), "Commutative equality is implemented for number objects and primitives");
    ok(!_.isEqual(new Number(75), new Number(63)), "Number objects with different primitive values are not equal");
    ok(!_.isEqual(new Number(63), {valueOf: function(){ return 63; }}), "Number objects and objects with a `valueOf` method are not equal");

    // Comparisons involving `NaN`.
    ok(_.isEqual(NaN, NaN), "`NaN` is equal to `NaN`");
    ok(!_.isEqual(61, NaN), "A number primitive is not equal to `NaN`");
    ok(!_.isEqual(new Number(79), NaN), "A number object is not equal to `NaN`");
    ok(!_.isEqual(Infinity, NaN), "`Infinity` is not equal to `NaN`");

    // Boolean object and primitive comparisons.
    ok(_.isEqual(true, true), "Identical boolean primitives are equal");
    ok(_.isEqual(new Boolean, new Boolean), "Boolean objects with identical primitive values are equal");
    ok(!_.isEqual(true, new Boolean(true)), "Boolean primitives and their corresponding object wrappers are not equal");
    ok(!_.isEqual(new Boolean(true), true), "Commutative equality is implemented for booleans");
    ok(!_.isEqual(new Boolean(true), new Boolean), "Boolean objects with different primitive values are not equal");

    // Common type coercions.
    ok(!_.isEqual(true, new Boolean(false)), "Boolean objects are not equal to the boolean primitive `true`");
    ok(!_.isEqual("75", 75), "String and number primitives with like values are not equal");
    ok(!_.isEqual(new Number(63), new String(63)), "String and number objects with like values are not equal");
    ok(!_.isEqual(75, "75"), "Commutative equality is implemented for like string and number values");
    ok(!_.isEqual(0, ""), "Number and string primitives with like values are not equal");
    ok(!_.isEqual(1, true), "Number and boolean primitives with like values are not equal");
    ok(!_.isEqual(new Boolean(false), new Number(0)), "Boolean and number objects with like values are not equal");
    ok(!_.isEqual(false, new String("")), "Boolean primitives and string objects with like values are not equal");
    ok(!_.isEqual(12564504e5, new Date(2009, 9, 25)), "Dates and their corresponding numeric primitive values are not equal");

    // Dates.
    ok(_.isEqual(new Date(2009, 9, 25), new Date(2009, 9, 25)), "Date objects referencing identical times are equal");
    ok(!_.isEqual(new Date(2009, 9, 25), new Date(2009, 11, 13)), "Date objects referencing different times are not equal");
    ok(!_.isEqual(new Date(2009, 11, 13), {
      getTime: function(){
        return 12606876e5;
      }
    }), "Date objects and objects with a `getTime` method are not equal");
    ok(!_.isEqual(new Date("Curly"), new Date("Curly")), "Invalid dates are not equal");

    // Functions.
    ok(!_.isEqual(First, Second), "Different functions with identical bodies and source code representations are not equal");

    // RegExps.
    ok(_.isEqual(/(?:)/gim, /(?:)/gim), "RegExps with equivalent patterns and flags are equal");
    ok(!_.isEqual(/(?:)/g, /(?:)/gi), "RegExps with equivalent patterns and different flags are not equal");
    ok(!_.isEqual(/Moe/gim, /Curly/gim), "RegExps with different patterns and equivalent flags are not equal");
    ok(!_.isEqual(/(?:)/gi, /(?:)/g), "Commutative equality is implemented for RegExps");
    ok(!_.isEqual(/Curly/g, {source: "Larry", global: true, ignoreCase: false, multiline: false}), "RegExps and RegExp-like objects are not equal");

    // Empty arrays, array-like objects, and object literals.
    ok(_.isEqual({}, {}), "Empty object literals are equal");
    ok(_.isEqual([], []), "Empty array literals are equal");
    ok(_.isEqual([{}], [{}]), "Empty nested arrays and objects are equal");
    ok(!_.isEqual({length: 0}, []), "Array-like objects and arrays are not equal.");
    ok(!_.isEqual([], {length: 0}), "Commutative equality is implemented for array-like objects");

    ok(!_.isEqual({}, []), "Object literals and array literals are not equal");
    ok(!_.isEqual([], {}), "Commutative equality is implemented for objects and arrays");

    // Arrays with primitive and object values.
    ok(_.isEqual([1, "Larry", true], [1, "Larry", true]), "Arrays containing identical primitives are equal");
    ok(_.isEqual([/Moe/g, new Date(2009, 9, 25)], [/Moe/g, new Date(2009, 9, 25)]), "Arrays containing equivalent elements are equal");

    // Multi-dimensional arrays.
    var a = [new Number(47), false, "Larry", /Moe/, new Date(2009, 11, 13), ['running', 'biking', new String('programming')], {a: 47}];
    var b = [new Number(47), false, "Larry", /Moe/, new Date(2009, 11, 13), ['running', 'biking', new String('programming')], {a: 47}];
    ok(_.isEqual(a, b), "Arrays containing nested arrays and objects are recursively compared");

    // Overwrite the methods defined in ES 5.1 section 15.4.4.
    a.forEach = a.map = a.filter = a.every = a.indexOf = a.lastIndexOf = a.some = a.reduce = a.reduceRight = null;
    b.join = b.pop = b.reverse = b.shift = b.slice = b.splice = b.concat = b.sort = b.unshift = null;

    // Array elements and properties.
    ok(!_.isEqual(a, b), "Arrays containing equivalent elements and different non-numeric properties are not equal");
    a.push("White Rocks");
    ok(!_.isEqual(a, b), "Arrays of different lengths are not equal");
    a.push("East Boulder");
    b.push("Gunbarrel Ranch", "Teller Farm");
    ok(!_.isEqual(a, b), "Arrays of identical lengths containing different elements are not equal");

    // Sparse arrays.
    ok(_.isEqual(Array(3), Array(3)), "Sparse arrays of identical lengths are equal");
    ok(!_.isEqual(Array(3), Array(6)), "Sparse arrays of different lengths are not equal when both are empty");

    // According to the Microsoft deviations spec, section 2.1.26, JScript 5.x treats `undefined`
    // elements in arrays as elisions. Thus, sparse arrays and dense arrays containing `undefined`
    // values are equivalent.
    if (0 in [undefined]) {
      ok(!_.isEqual(Array(3), [undefined, undefined, undefined]), "Sparse and dense arrays are not equal");
      ok(!_.isEqual([undefined, undefined, undefined], Array(3)), "Commutative equality is implemented for sparse and dense arrays");
    }

    // Simple objects.
    ok(_.isEqual({a: "Curly", b: 1, c: true}, {a: "Curly", b: 1, c: true}), "Objects containing identical primitives are equal");
    ok(_.isEqual({a: /Curly/g, b: new Date(2009, 11, 13)}, {a: /Curly/g, b: new Date(2009, 11, 13)}), "Objects containing equivalent members are equal");
    ok(!_.isEqual({a: 63, b: 75}, {a: 61, b: 55}), "Objects of identical sizes with different values are not equal");
    ok(!_.isEqual({a: 63, b: 75}, {a: 61, c: 55}), "Objects of identical sizes with different property names are not equal");
    ok(!_.isEqual({a: 1, b: 2}, {a: 1}), "Objects of different sizes are not equal");
    ok(!_.isEqual({a: 1}, {a: 1, b: 2}), "Commutative equality is implemented for objects");
    ok(!_.isEqual({x: 1, y: undefined}, {x: 1, z: 2}), "Objects with identical keys and different values are not equivalent");

    // `A` contains nested objects and arrays.
    a = {
      name: new String("Moe Howard"),
      age: new Number(77),
      stooge: true,
      hobbies: ["acting"],
      film: {
        name: "Sing a Song of Six Pants",
        release: new Date(1947, 9, 30),
        stars: [new String("Larry Fine"), "Shemp Howard"],
        minutes: new Number(16),
        seconds: 54
      }
    };

    // `B` contains equivalent nested objects and arrays.
    b = {
      name: new String("Moe Howard"),
      age: new Number(77),
      stooge: true,
      hobbies: ["acting"],
      film: {
        name: "Sing a Song of Six Pants",
        release: new Date(1947, 9, 30),
        stars: [new String("Larry Fine"), "Shemp Howard"],
        minutes: new Number(16),
        seconds: 54
      }
    };
    ok(_.isEqual(a, b), "Objects with nested equivalent members are recursively compared");

    // Instances.
    ok(_.isEqual(new First, new First), "Object instances are equal");
    ok(!_.isEqual(new First, new Second), "Objects with different constructors and identical own properties are not equal");
    ok(!_.isEqual({value: 1}, new First), "Object instances and objects sharing equivalent properties are not identical");
    ok(!_.isEqual({value: 2}, new Second), "The prototype chain of objects should not be examined");

    // Circular Arrays.
    (a = []).push(a);
    (b = []).push(b);
    ok(_.isEqual(a, b), "Arrays containing circular references are equal");
    a.push(new String("Larry"));
    b.push(new String("Larry"));
    ok(_.isEqual(a, b), "Arrays containing circular references and equivalent properties are equal");
    a.push("Shemp");
    b.push("Curly");
    ok(!_.isEqual(a, b), "Arrays containing circular references and different properties are not equal");

    // Circular Objects.
    a = {abc: null};
    b = {abc: null};
    a.abc = a;
    b.abc = b;
    ok(_.isEqual(a, b), "Objects containing circular references are equal");
    a.def = 75;
    b.def = 75;
    ok(_.isEqual(a, b), "Objects containing circular references and equivalent properties are equal");
    a.def = new Number(75);
    b.def = new Number(63);
    ok(!_.isEqual(a, b), "Objects containing circular references and different properties are not equal");

    // Cyclic Structures.
    a = [{abc: null}];
    b = [{abc: null}];
    (a[0].abc = a).push(a);
    (b[0].abc = b).push(b);
    ok(_.isEqual(a, b), "Cyclic structures are equal");
    a[0].def = "Larry";
    b[0].def = "Larry";
    ok(_.isEqual(a, b), "Cyclic structures containing equivalent properties are equal");
    a[0].def = new String("Larry");
    b[0].def = new String("Curly");
    ok(!_.isEqual(a, b), "Cyclic structures containing different properties are not equal");

    // Complex Circular References.
    a = {foo: {b: {foo: {c: {foo: null}}}}};
    b = {foo: {b: {foo: {c: {foo: null}}}}};
    a.foo.b.foo.c.foo = a;
    b.foo.b.foo.c.foo = b;
    ok(_.isEqual(a, b), "Cyclic structures with nested and identically-named properties are equal");

    // Chaining.
    ok(!_.isEqual(_({x: 1, y: undefined}).chain(), _({x: 1, z: 2}).chain()), 'Chained objects containing different values are not equal');
    equals(_({x: 1, y: 2}).chain().isEqual(_({x: 1, y: 2}).chain()).value(), true, '`isEqual` can be chained');

    // Custom `isEqual` methods.
    var isEqualObj = {isEqual: function (o) { return o.isEqual == this.isEqual; }, unique: {}};
    var isEqualObjClone = {isEqual: isEqualObj.isEqual, unique: {}};

    ok(_.isEqual(isEqualObj, isEqualObjClone), 'Both objects implement identical `isEqual` methods');
    ok(_.isEqual(isEqualObjClone, isEqualObj), 'Commutative equality is implemented for objects with custom `isEqual` methods');
    ok(!_.isEqual(isEqualObj, {}), 'Objects that do not implement equivalent `isEqual` methods are not equal');
    ok(!_.isEqual({}, isEqualObj), 'Commutative equality is implemented for objects with different `isEqual` methods');

    // Custom `isEqual` methods - comparing different types
    LocalizedString = (function() {
      function LocalizedString(id) { this.id = id; this.string = (this.id===10)? 'Bonjour': ''; }
      LocalizedString.prototype.isEqual = function(that) {
        if (_.isString(that)) return this.string == that;
        else if (that instanceof LocalizedString) return this.id == that.id;
        return false;
      };
      return LocalizedString;
    })();
    var localized_string1 = new LocalizedString(10), localized_string2 = new LocalizedString(10), localized_string3 = new LocalizedString(11);
    ok(_.isEqual(localized_string1, localized_string2), 'comparing same typed instances with same ids');
    ok(!_.isEqual(localized_string1, localized_string3), 'comparing same typed instances with different ids');
    ok(_.isEqual(localized_string1, 'Bonjour'), 'comparing different typed instances with same values');
    ok(_.isEqual('Bonjour', localized_string1), 'comparing different typed instances with same values');
    ok(!_.isEqual('Bonjour', localized_string3), 'comparing two localized strings with different ids');
    ok(!_.isEqual(localized_string1, 'Au revoir'), 'comparing different typed instances with different values');
    ok(!_.isEqual('Au revoir', localized_string1), 'comparing different typed instances with different values');

    // Custom `isEqual` methods - comparing with serialized data
    Date.prototype.toJSON = function() {
      return {
        _type:'Date',
        year:this.getUTCFullYear(),
        month:this.getUTCMonth(),
        day:this.getUTCDate(),
        hours:this.getUTCHours(),
        minutes:this.getUTCMinutes(),
        seconds:this.getUTCSeconds()
      };
    };
    Date.prototype.isEqual = function(that) {
      var this_date_components = this.toJSON();
      var that_date_components = (that instanceof Date) ? that.toJSON() : that;
      delete this_date_components['_type']; delete that_date_components['_type']
      return _.isEqual(this_date_components, that_date_components);
    };

    var date = new Date();
    var date_json = {
      _type:'Date',
      year:date.getUTCFullYear(),
      month:date.getUTCMonth(),
      day:date.getUTCDate(),
      hours:date.getUTCHours(),
      minutes:date.getUTCMinutes(),
      seconds:date.getUTCSeconds()
    };

    ok(_.isEqual(date_json, date), 'serialized date matches date');
    ok(_.isEqual(date, date_json), 'date matches serialized date');
  });

  test("objects: isEmpty", function() {
    ok(!_([1]).isEmpty(), '[1] is not empty');
    ok(_.isEmpty([]), '[] is empty');
    ok(!_.isEmpty({one : 1}), '{one : 1} is not empty');
    ok(_.isEmpty({}), '{} is empty');
    ok(_.isEmpty(new RegExp('')), 'objects with prototype properties are empty');
    ok(_.isEmpty(null), 'null is empty');
    ok(_.isEmpty(), 'undefined is empty');
    ok(_.isEmpty(''), 'the empty string is empty');
    ok(!_.isEmpty('moe'), 'but other strings are not');

    var obj = {one : 1};
    delete obj.one;
    ok(_.isEmpty(obj), 'deleting all the keys from an object empties it');
  });

  test("objects: isArguments", function() {
    var args = (function(){ return arguments; })(1, 2, 3);
    ok(!_.isArguments('string'), 'a string is not an arguments object');
    ok(!_.isArguments(_.isArguments), 'a function is not an arguments object');
    ok(_.isArguments(args), 'but the arguments object is an arguments object');
    ok(!_.isArguments(_.toArray(args)), 'but not when it\'s converted into an array');
    ok(!_.isArguments([1,2,3]), 'and not vanilla arrays.');
  });

  test("objects: isObject", function() {
    ok(_.isObject(arguments), 'the arguments object is object');
    ok(_.isObject([1, 2, 3]), 'and arrays');
    ok(_.isObject(function () {}), 'and functions');
    ok(!_.isObject(null), 'but not null');
    ok(!_.isObject(undefined), 'and not undefined');
    ok(!_.isObject('string'), 'and not string');
    ok(!_.isObject(12), 'and not number');
    ok(!_.isObject(true), 'and not boolean');
    ok(_.isObject(new String('string')), 'but new String()');
  });

  test("objects: isArray", function() {
    ok(!_.isArray(arguments), 'the arguments object is not an array');
    ok(_.isArray([1, 2, 3]), 'but arrays are');
  });

  test("objects: isString", function() {
    ok(_.isString([1, 2, 3].join(', ')), 'but strings are');
  });

  test("objects: isNumber", function() {
    ok(!_.isNumber('string'), 'a string is not a number');
    ok(!_.isNumber(arguments), 'the arguments object is not a number');
    ok(!_.isNumber(undefined), 'undefined is not a number');
    ok(_.isNumber(3 * 4 - 7 / 10), 'but numbers are');
    ok(_.isNumber(NaN), 'NaN *is* a number');
    ok(_.isNumber(Infinity), 'Infinity is a number');
    ok(!_.isNumber('1'), 'numeric strings are not numbers');
  });

  test("objects: isBoolean", function() {
    ok(!_.isBoolean(2), 'a number is not a boolean');
    ok(!_.isBoolean("string"), 'a string is not a boolean');
    ok(!_.isBoolean("false"), 'the string "false" is not a boolean');
    ok(!_.isBoolean("true"), 'the string "true" is not a boolean');
    ok(!_.isBoolean(arguments), 'the arguments object is not a boolean');
    ok(!_.isBoolean(undefined), 'undefined is not a boolean');
    ok(!_.isBoolean(NaN), 'NaN is not a boolean');
    ok(!_.isBoolean(null), 'null is not a boolean');
    ok(_.isBoolean(true), 'but true is');
    ok(_.isBoolean(false), 'and so is false');
  });

  test("objects: isFunction", function() {
    ok(!_.isFunction([1, 2, 3]), 'arrays are not functions');
    ok(!_.isFunction('moe'), 'strings are not functions');
    ok(_.isFunction(_.isFunction), 'but functions are');
  });

  test("objects: isDate", function() {
    ok(!_.isDate(100), 'numbers are not dates');
    ok(!_.isDate({}), 'objects are not dates');
    ok(_.isDate(new Date()), 'but dates are');
  });

  test("objects: isRegExp", function() {
    ok(!_.isRegExp(_.identity), 'functions are not RegExps');
    ok(_.isRegExp(/identity/), 'but RegExps are');
  });

  test("objects: isNaN", function() {
    ok(!_.isNaN(undefined), 'undefined is not NaN');
    ok(!_.isNaN(null), 'null is not NaN');
    ok(!_.isNaN(0), '0 is not NaN');
    ok(_.isNaN(NaN), 'but NaN is');
  });

  test("objects: isNull", function() {
    ok(!_.isNull(undefined), 'undefined is not null');
    ok(!_.isNull(NaN), 'NaN is not null');
    ok(_.isNull(null), 'but null is');
  });

  test("objects: isUndefined", function() {
    ok(!_.isUndefined(1), 'numbers are defined');
    ok(!_.isUndefined(null), 'null is defined');
    ok(!_.isUndefined(false), 'false is defined');
    ok(!_.isUndefined(NaN), 'NaN is defined');
    ok(_.isUndefined(), 'nothing is undefined');
    ok(_.isUndefined(undefined), 'undefined is undefined');
  });

  test("objects: tap", function() {
    var intercepted = null;
    var interceptor = function(obj) { intercepted = obj; };
    var returned = _.tap(1, interceptor);
    equals(intercepted, 1, "passes tapped object to interceptor");
    equals(returned, 1, "returns tapped object");

    returned = _([1,2,3]).chain().
      map(function(n){ return n * 2; }).
      max().
      tap(interceptor).
      value();
    ok(returned == 6 && intercepted == 6, 'can use tapped objects in a chain');
  });
  
  test("utility: noConflict", function() {
    var underscore = _.noConflict();
    ok(underscore.isUndefined(_), "The '_' variable has been returned to its previous state.");
    var intersection = underscore.intersect([-1, 0, 1, 2], [1, 2, 3, 4]);
    equals(intersection.join(', '), '1, 2', 'but the intersection function still works');
    window._ = underscore;
  });

  test("utility: identity", function() {
    var moe = {name : 'moe'};
    equals(_.identity(moe), moe, 'moe is the same as his identity');
  });

  test("utility: uniqueId", function() {
    var ids = [], i = 0;
    while(i++ < 100) ids.push(_.uniqueId());
    equals(_.uniq(ids).length, ids.length, 'can generate a globally-unique stream of ids');
  });

  test("utility: times", function() {
    var vals = [];
    _.times(3, function (i) { vals.push(i); });
    ok(_.isEqual(vals, [0,1,2]), "is 0 indexed");
    //
    vals = [];
    _(3).times(function (i) { vals.push(i); });
    ok(_.isEqual(vals, [0,1,2]), "works as a wrapper");
  });

  test("utility: mixin", function() {
    _.mixin({
      myReverse: function(string) {
        return string.split('').reverse().join('');
      }
    });
    equals(_.myReverse('panacea'), 'aecanap', 'mixed in a function to _');
    equals(_('champ').myReverse(), 'pmahc', 'mixed in a function to the OOP wrapper');
  });

  test("utility: _.escape", function() {
    equals(_.escape("Curly & Moe"), "Curly &amp; Moe");
    equals(_.escape("Curly &amp; Moe"), "Curly &amp;amp; Moe");
  });
  
  test("utility: template", function() {
    var basicTemplate = _.template("<%= thing %> is gettin' on my noives!");
    var result = basicTemplate({thing : 'This'});
    equals(result, "This is gettin' on my noives!", 'can do basic attribute interpolation');

    var backslashTemplate = _.template("<%= thing %> is \\ridanculous");
    equals(backslashTemplate({thing: 'This'}), "This is \\ridanculous");

    var fancyTemplate = _.template("<ul><% \
      for (key in people) { \
    %><li><%= people[key] %></li><% } %></ul>");
    result = fancyTemplate({people : {moe : "Moe", larry : "Larry", curly : "Curly"}});
    equals(result, "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", 'can run arbitrary javascript in templates');

    var namespaceCollisionTemplate = _.template("<%= pageCount %> <%= thumbnails[pageCount] %> <% _.each(thumbnails, function(p) { %><div class=\"thumbnail\" rel=\"<%= p %>\"></div><% }); %>");
    result = namespaceCollisionTemplate({
      pageCount: 3,
      thumbnails: {
        1: "p1-thumbnail.gif",
        2: "p2-thumbnail.gif",
        3: "p3-thumbnail.gif"
      }
    });
    equals(result, "3 p3-thumbnail.gif <div class=\"thumbnail\" rel=\"p1-thumbnail.gif\"></div><div class=\"thumbnail\" rel=\"p2-thumbnail.gif\"></div><div class=\"thumbnail\" rel=\"p3-thumbnail.gif\"></div>");

    var noInterpolateTemplate = _.template("<div><p>Just some text. Hey, I know this is silly but it aids consistency.</p></div>");
    result = noInterpolateTemplate();
    equals(result, "<div><p>Just some text. Hey, I know this is silly but it aids consistency.</p></div>");

    var quoteTemplate = _.template("It's its, not it's");
    equals(quoteTemplate({}), "It's its, not it's");

    var quoteInStatementAndBody = _.template("<%\
      if(foo == 'bar'){ \
    %>Statement quotes and 'quotes'.<% } %>");
    equals(quoteInStatementAndBody({foo: "bar"}), "Statement quotes and 'quotes'.");

    var withNewlinesAndTabs = _.template('This\n\t\tis: <%= x %>.\n\tok.\nend.');
    equals(withNewlinesAndTabs({x: 'that'}), 'This\n\t\tis: that.\n\tok.\nend.');

    var template = _.template("<i><%- value %></i>");
    var result = template({value: "<script>"});
    equals(result, '<i>&lt;script&gt;</i>');

    _.templateSettings = {
      evaluate    : /\{\{([\s\S]+?)\}\}/g,
      interpolate : /\{\{=([\s\S]+?)\}\}/g
    };

    var custom = _.template("<ul>{{ for (key in people) { }}<li>{{= people[key] }}</li>{{ } }}</ul>");
    result = custom({people : {moe : "Moe", larry : "Larry", curly : "Curly"}});
    equals(result, "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", 'can run arbitrary javascript in templates');

    var customQuote = _.template("It's its, not it's");
    equals(customQuote({}), "It's its, not it's");

    var quoteInStatementAndBody = _.template("{{ if(foo == 'bar'){ }}Statement quotes and 'quotes'.{{ } }}");
    equals(quoteInStatementAndBody({foo: "bar"}), "Statement quotes and 'quotes'.");

    _.templateSettings = {
      evaluate    : /<\?([\s\S]+?)\?>/g,
      interpolate : /<\?=([\s\S]+?)\?>/g
    };

    var customWithSpecialChars = _.template("<ul><? for (key in people) { ?><li><?= people[key] ?></li><? } ?></ul>");
    result = customWithSpecialChars({people : {moe : "Moe", larry : "Larry", curly : "Curly"}});
    equals(result, "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", 'can run arbitrary javascript in templates');

    var customWithSpecialCharsQuote = _.template("It's its, not it's");
    equals(customWithSpecialCharsQuote({}), "It's its, not it's");

    var quoteInStatementAndBody = _.template("<? if(foo == 'bar'){ ?>Statement quotes and 'quotes'.<? } ?>");
    equals(quoteInStatementAndBody({foo: "bar"}), "Statement quotes and 'quotes'.");

    _.templateSettings = {
      interpolate : /\{\{(.+?)\}\}/g
    };

    var mustache = _.template("Hello {{planet}}!");
    equals(mustache({planet : "World"}), "Hello World!", "can mimic mustache.js");
  });
  

//*/
})();