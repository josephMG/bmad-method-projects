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
    case percentage = "%"
    case squareRoot = "√"
    case powerOfTwo = "x²"
    case sine = "sin"
    case cosine = "cos"
    case tangent = "tan"
    case naturalLogarithm = "ln"
    case base10Logarithm = "log10"
    case eToThePowerOfX = "e^x"
    case tenToThePowerOfX = "10^x"
    case xToThePowerOfY = "x^y"
    case cubeRoot = "³√"
    case factorial = "x!"
    case signChange = "+/-"
}

// Enum for potential calculation errors.
enum CalculationError: Error {
    case divisionByZero
    case invalidInput
    case invalidInputForSquareRoot
    case invalidInputForTrigonometricFunction
    case logarithmOfNonPositiveNumber
    case factorialOfNegativeNumber
}
