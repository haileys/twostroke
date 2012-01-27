test("new Date", function() {
  assert_equal(1970, new Date(9876543210).getFullYear());
});

test("string coercion", function() {
  assert(/^Sat Apr 25 1970 /.test(String(new Date(9876543210))), "string did not start with what was expected, it is: " + String(new Date(9876543210)));
});

test("number coercion", function() {
  assert_equal(9876543210, Number(new Date(9876543210)));
});

test("calling date without new gives current date as string", function() {
  assert_equal("string", typeof Date());
  assert("Sat Apr 25 1970 17:29:03 GMT+1000 (EST)" !== String(Date(9876543210)));
});

test("date prefers to be coerced to a number", function() {
  // this is true:
  // String(new Date(9876543211)) < String(new Date(0))
  // because that ends up as:
  // "Sat Apr 25 1970 17:29:03 GMT+1000 (EST)" < "Thu Jan 01 1970 10:00:00 GMT+1000 (EST)"
  // which is true in the string sense.
  // implicit number corecion should go the other way
  assert(new Date(9876543211) > new Date(0), "implicit (to number) coercion goes the other way");
});

test("getDate", function() {
  assert_equal(25, new Date(9876543210).getDate());
  assert_equal(12, new Date(1350000000000).getDate());
});

test("getDay", function() {
  assert_equal(6, new Date(9876543210).getDay());
  assert_equal(5, new Date(1350000000000).getDay());
});

test("getFullYear", function() {
  assert_equal(1970, new Date(9876543210).getFullYear());
  assert_equal(2012, new Date(1350000000000).getFullYear());
});

test("getYear", function() {
  assert_equal(70, new Date(9876543210).getYear());
  assert_equal(112, new Date(1350000000000).getYear());
});

test("getMilliseconds", function() {
  assert_equal(210, new Date(9876543210).getMilliseconds());
  assert_equal(0, new Date(1350000000000).getMilliseconds());
});

test("getMinutes", function() {
  assert_equal(29, new Date(9876543210).getMinutes());
  assert_equal(0, new Date(1350000000000).getMinutes());
});

test("getTime", function() {
  assert_equal(9876543210, new Date(9876543210).getTime());
  assert_equal(1350000000000, new Date(1350000000000).getTime());
});

test("UTC", function() {
  assert_equal(776307723004, Date.UTC(1994, 7, 8, 1, 2, 3, 4));
  assert_equal(775699200000, Date.UTC(1994, 7));
  assert(isNaN(Date.UTC()));
});