test("do while", function() {
    do {
        assert(true);
        return;
    } while(false);
    assert(false, "did not execute");
});

test("do while and continue", function() {
    var flag = false;
    do {
        if(flag) {
            assert(false, "loop executed again after continue in do..while(false)");
        }
        flag = true;
        continue;
    } while(false);
    assert(true);
});

test("with", function() {
    var b = 0;
    var x = { a: 1 };
    with(x) {
        assert_equal("number", typeof a);
        assert_equal(1, a);
        var y = 2;
        b = 3;
        a = 4;
    }
    assert_equal(4, x.a);
    assert_equal(2, y);
    assert_equal("undefined", typeof x.b);
    assert_equal(3, b);
});

test("default in switch", function() {
    switch(1) {
        case 1: assert(true); break;
        default: assert(false); break;
    }

    switch(2) {
        case 1: assert(false); break;
        default: assert(true); break;
    }

    switch(1) {
        default: assert(false); break;
        case 1: assert(true); break;
    }

    switch(2) {
        default: assert(true); break;
        case 1: assert(false); break;
    }
});

test("combo-assignment-arithmetic on member", function() {
    var x = { a: 1 };
    assert_equal(3, x.a += 2);
    assert_equal(3, x.a);
});

test("combo-assignment-arithmetic on index", function() {
    var x = { a: 1 };
    assert_equal(3, x["a"] += 2);
    assert_equal(3, x["a"]);
});

test("assignment non-lval throws", function() {
    try {
        eval("hi() = 123");
        assert(false, "didn't throw");
    } catch(e) {
        assert(e instanceof SyntaxError);
    }
});

test("combo-assignment-arithmetic on non-lval throws", function() {
    try {
        eval("hi() += 123");
        assert(false, "didn't throw");
    } catch(e) {
        assert(e instanceof SyntaxError);
    }
});

test("post-increment", function() {
    var i = 0;
    var a = [1];
    var o = { x: 2 };
    assert_equal(0, i++);
    assert_equal(1, a[0]++);
    assert_equal(2, o.x++);
    assert_equal(1, i);
    assert_equal(2, a[0]);
    assert_equal(3, o.x);
});

test("pre-increment", function() {
    var i = 0;
    var a = [1];
    var o = { x: 2 };
    assert_equal(1, ++i);
    assert_equal(2, ++a[0]);
    assert_equal(3, ++o.x);
    assert_equal(1, i);
    assert_equal(2, a[0]);
    assert_equal(3, o.x);
});

test("post/pre increment on non-lval throws", function() {
    try {
        eval("hi()++;");
        assert(false, "didn't throw");
    } catch(e) {
        assert(e instanceof SyntaxError);
    }
    try {
        eval("++hi();");
        assert(false, "didn't throw");
    } catch(e) {
        assert(e instanceof SyntaxError);
    }
});

test("calling", function() {
    var x = { a: function() { return this; } };
    assert_equal(x, x["a"]());
    assert_equal(x, x.a());
    assert_equal(123, Number(x.a.call(123)));
    function closure() {
        var fn = x.a;
        assert_equal(this, fn());
    }
    closure();
});

test("delete", function() {	
    window.x = 123;
    var y = { a:1, b:2, c:3 };
    var z = [1,2,3,4];

    assert_equal("number", typeof x);
    delete x;
    assert_equal("undefined", typeof x);

    assert_equal("number", typeof y.b);
    delete y.b;
    assert_equal("undefined", typeof y.b);
    
    assert_equal("number", typeof y.c);
    with(y) delete c;
    assert_equal("undefined", typeof y.c);

    assert("1,2,3,4" == z);
    delete z[2];
    assert("1,2,,4" == z);

    var fncalled = false;
    function fn() { fncalled = true; }
    assert_equal(true, delete fn());
    assert_equal("function", typeof fn);
    assert_equal("undefined", typeof fn());
    assert_equal(true, fncalled);

    function Fn() { }
    Fn.prototype.hi = 123;
    assert_equal(true, delete Fn.prototype);
    assert_equal(123, Fn.prototype.hi);
});

test("break label", function() {
    br: while(true) {
        while(true) {
            break br;
            assert(false, "did not break");
        }
        assert(false, "did not escape second loop");
    }
    assert(true);
});

test("can't continue to non existant label", function() {
    try {
        eval('while(false) continue foo;');
    } catch(e) {
        assert(e instanceof SyntaxError);
        assert(/foo/.test(e.toString()));
    }
});

test("labelled continue while", function() {
    var x = false;
    a:while(true) {
        if(x) {
            assert(true);
            return;
        }
        while(true) {
            x = true;
            continue a;
            assert(false, "did not continue");
        }
    }
});

test("labelled continue do-while", function() {
    a:do {
        do {
            continue a;
            assert(false);
        } while(false);
        assert(false);
    } while(false);
});

test("labelled continue for-loop", function() {
    var x = false;
    function init() {
        if(x) {
            assert(false, "reran initializer");
        }
        x = true;
    }
    var i = 0;
    a: for(init(); i < 10; i++) {
        assert(true);
        do {
            continue a;
            assert(false);
        } while(false);
        assert(false);
    }
    assert(true);
});

test("labelled continue for-in", function() {
    var a = 0, c = [1, 2, 3, 4, 5];
    l: for(var x in c) {
        if(c.hasOwnProperty(x)) {
            do {
                a += c[x];
                continue l;
                assert(false);
            } while(false);
            assert(false);
        }
    }
    assert_equal(15, a);
});

test("floating point is used for large numbers but not for small numbers", function() {
    assert_equal(99999999999999999999999999999999999999, 99999999999999999999999999999999999999 + 1);
    assert(999999 !== 999999 + 1);
});

test("redeclaring a variable", function() {
    assert_equal(123, (function(a) {
       var a;
       return a;
    })(123));
});