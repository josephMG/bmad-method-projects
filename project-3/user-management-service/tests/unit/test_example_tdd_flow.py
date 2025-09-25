import pytest

# RED: Write a failing test first
def test_add_two_numbers_red():
    # This test should initially fail because the add function doesn't exist yet
    assert add(1, 2) == 3

# GREEN: Write just enough code to make the test pass
# def add(a, b):
#     return a + b

# REFACTOR: Improve the code (if necessary) and ensure tests still pass
# (No refactoring needed for this simple function, but this is where it would go)

# RED: Add another failing test for a new requirement
def test_add_two_numbers_negative_red():
    # This test should initially fail because the add function might not handle negative numbers correctly
    assert add(-1, -2) == -3

# GREEN: Write just enough code to make the new test pass
# (The existing add function already handles this, so no change needed for this specific test)

# RED: Add a test for a different operation (e.g., subtraction)
def test_subtract_two_numbers_red():
    # This test should initially fail because the subtract function doesn't exist yet
    assert subtract(5, 2) == 3

# GREEN: Write just enough code to make the test pass
# def subtract(a, b):
#     return a - b

# Final working functions (after Red-Green-Refactor cycles)
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b