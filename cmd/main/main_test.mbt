///|
test "cmd/main: demo_output is stable" {
  let (a, b) = run_demo()
  inspect(a, content="<Map: { \"a\": 3, \"b\": 6, \"c\": 13 }>")
  let esc = "\u001b"
  let expected = [
    "<Map:",
    "{ \"a\": 3,",
    "  \"b\": " + esc + "[31m-6" + esc + "[0m " + esc + "[32m+9" + esc + "[0m,",
    "  \"c\": 13 }>",
  ].join("\n"[:])
  inspect(b, content=expected)
}
