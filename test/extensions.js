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
