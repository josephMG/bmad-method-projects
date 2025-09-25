# Test-Driven Development (TDD) Workflow

## Overview

Test-Driven Development (TDD) is a software development process that relies on the repetition of a very short development cycle: requirements are turned into very specific test cases, then the software is improved to pass the new tests, only then the new code is refactored.

## The Red-Green-Refactor Cycle

The core of TDD is the Red-Green-Refactor cycle:

1.  **Red: Write a failing test.**
    *   Write a new test case that defines a small piece of new functionality or a bug fix.
    *   Run all tests to ensure the new test fails (and only the new test fails). This confirms that the test is correctly identifying the missing or incorrect functionality.

2.  **Green: Write just enough code to make the test pass.**
    *   Write the minimum amount of production code necessary to make the failing test pass.
    *   Do not worry about code quality, design, or elegance at this stage. The goal is simply to pass the test.
    *   Run all tests again to ensure everything passes.

3.  **Refactor: Improve the code.**
    *   Once all tests are green, refactor the newly written code (and potentially existing code) to improve its design, readability, and maintainability.
    *   Ensure that the refactoring does not change the external behavior of the code.
    *   Run all tests after each small refactoring step to ensure no regressions have been introduced.

## Key Principles

*   **Small Steps:** TDD encourages working in very small, incremental steps. This reduces complexity and makes debugging easier.
*   **Continuous Testing:** Tests are run frequently throughout the development process, providing immediate feedback.
*   **Clear Requirements:** Writing tests first forces a clear understanding of the requirements before implementation begins.
*   **High Test Coverage:** TDD naturally leads to high test coverage, especially for unit tests.

## Mocking Strategies

For unit tests, external dependencies (e.g., database calls, API requests, external services) should be mocked to isolate the code under test. This ensures that unit tests are fast, reliable, and truly test a single unit of functionality.

*   Use `unittest.mock` or `pytest-mock` for creating mock objects.
*   Mock dependencies at the boundary of the unit being tested.

## Test Data Management

*   **Factory Pattern:** Use `factory-boy` for generating realistic and consistent test data.
*   **Pytest Fixtures:** Leverage Pytest fixtures in `conftest.py` for reusable test setup and teardown, including database sessions and client setup.
*   **Isolated Transactions:** For integration tests involving the database, ensure each test runs within an isolated transaction that is rolled back after the test completes. This prevents test data from polluting the database and ensures test independence.
