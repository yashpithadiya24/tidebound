extends GutTest
## Smoke test. It proves GUT can run from the command line.


func test_math_works() -> void:
	assert_eq(1 + 1, 2, "1 + 1 should be 2")
