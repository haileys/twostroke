test("__noSuchMethod__", function() {
    var obj = {};
    var called = false;
    obj.__noSuchMethod__ = function(id, args) {
        called = true;
        assert_equal("foo", id);
        assert_equal(2, args.length);
        assert_equal("bar", args[0]);
        assert_equal("baz", args[1]);
    };
    obj.foo("bar", "baz");
    assert(called);
});

test("__noSuchMethod__ is called if prop exists but is not callable", function() {
    var obj = {};
    var called = false;
    obj.foo = 123;
    obj.__noSuchMethod__ = function(id, args) {
        called = true;
        assert_equal(123, this.foo);
    };
    assert_equal(123, obj.foo);
    obj.foo();
    assert(called);
});

test("line tracing", function() {
    var t = 0;
    Twostroke.setLineTrace(function(a, b, c) {
        assert(a && b);
        assert_equal("undefined", typeof c);
        t++;
    });
    // do some stuff:
    1 + 2;
    3 + 4;
    Twostroke.setLineTrace(null);
    assert(t > 0, "trace func did not run");
    var u = t;
    // do more things
    5 + 6;
    7 + 8;
    assert(t == u, "setLineTrace(null) did not disable tracing");
});

test("instruction tracing", function() {
    var t = 0, u = 0;
    Twostroke.setInstructionTrace(function(a, b, c, d, e) {
        assert(a && b && c);
        if(d) u++; // d isn't there all of the time, but we want to make sure
                   // it's there some of the time
        assert_equal("undefined", typeof e);
        t++;
    });
    // do some stuff:
    1 + 2;
    3 + 4;
    Twostroke.setInstructionTrace(null);
    assert(u > 0);
    assert(t > 0, "trace func did not run");
    var u = t;
    // do more things
    5 + 6;
    7 + 8;
    assert(t == u, "setInstructionTrace(null) did not disable tracing");
});