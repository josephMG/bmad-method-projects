import Foundation

// Represents the core state of the calculator at any given moment.
struct CalculationState {
    var displayValue: Decimal = 0
    var firstOperand: Decimal?
    var secondOperand: Decimal?
    var pendingOperation: Operation?
    var isEnteringDecimal = false
    var isNewValue = true
}

// Enum for all supported arithmetic operations.
enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
}

// Enum for potential calculation errors.
enum CalculationError: Error {
    case divisionByZero
    case invalidInput
}
