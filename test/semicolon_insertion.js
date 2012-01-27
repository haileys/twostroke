test("return is a restricted production", function() {
    assert_equal(undefined, (function() {
        return 
        1
    })());
});

test("throw is a restricted production", function() {
    try {
        eval("throw\n1;")
    } catch(e) {
        assert(e instanceof SyntaxError);
    }
});

test("break is a restricted production", function() {
    a:while(true) {
        while(true) {
            break
            a;
        }
        assert(true);
        return;
    }
    assert(false);
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