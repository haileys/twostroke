test("return is greedily semicolon inserted", function() {
    assert_equal(undefined, (function() {
        return 
        1
    })());
});

test("fragmented statement parses", function() {
    var x = { a: 1 };
    eval("delete\nx.a");
    assert(1 !== x.a);
});

test("fragmented statement parses", function() {
    var x = { a: 1 };
    eval("delete x.a\n");
    assert(1 !== x.a);
});