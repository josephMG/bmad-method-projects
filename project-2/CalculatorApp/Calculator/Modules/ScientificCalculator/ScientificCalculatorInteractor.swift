// ScientificCalculatorInteractor.swift
import Foundation

class ScientificCalculatorInteractor: ScientificCalculatorInteractorInputProtocol {
    weak var presenter: ScientificCalculatorInteractorOutputProtocol?
    private var state = CalculationState()

    func processDigit(_ digit: String) {
        guard let digitValue = Decimal(string: digit) else {
            return
        }

        if state.isNewValue {
            state.displayValue = digitValue
            state.isNewValue = false
        } else {
            let currentDisplayString = NSDecimalNumber(decimal: state.displayValue).stringValue
            let newDisplayString = currentDisplayString + digit
            if let newDisplayValue = Decimal(string: newDisplayString) {
                state.displayValue = newDisplayValue
            }
        }
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
    }

    func processOperator(_ opString: String) {
        guard let operation = Operation(rawValue: opString) else {
            return
        }
        
        if let firstOperand = state.firstOperand, let pendingOperation = state.pendingOperation {
            let result = performCalculation(firstOperand: firstOperand, secondOperand: state.displayValue, operation: pendingOperation)
            state.displayValue = result
            presenter?.didUpdateDisplayValue(formatDisplay(result))
        }
        
        state.firstOperand = state.displayValue
        state.pendingOperation = operation
        state.isNewValue = true
    }

    func processEquals() {
        guard let firstOperand = state.firstOperand, let operation = state.pendingOperation else {
            return
        }
        
        let result = performCalculation(firstOperand: firstOperand, secondOperand: state.displayValue, operation: operation)
        state.displayValue = result
        presenter?.didUpdateDisplayValue(formatDisplay(result))
        
        state.firstOperand = nil
        state.pendingOperation = nil
        state.isNewValue = true
    }

    func processClear() {
        state = CalculationState()
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
    }
    
    func processDecimal() {
        if state.isNewValue {
            state.displayValue = 0
            state.isNewValue = false
        }
        
        let currentDisplayString = NSDecimalNumber(decimal: state.displayValue).stringValue
        if !currentDisplayString.contains(".") {
            let newDisplayString = currentDisplayString + "."
            if let newDisplayValue = Decimal(string: newDisplayString) {
                state.displayValue = newDisplayValue
                presenter?.didUpdateDisplayValue(newDisplayString)
            }
        }
    }
    
    func processSign() {
        state.displayValue.negate()
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
    }

    func processPowerOfTwo() {
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = pow(number, 2)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processSine() {
        let degrees = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let radians = degrees * .pi / 180
        let result = sin(radians)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processCosine() {
        let degrees = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let radians = degrees * .pi / 180
        let result = cos(radians)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processTangent() {
        let degrees = NSDecimalNumber(decimal: state.displayValue).doubleValue
        if degrees.truncatingRemainder(dividingBy: 90) == 0 && degrees.truncatingRemainder(dividingBy: 180) != 0 {
            presenter?.didEncounterError("Invalid input for trigonometric function")
            return
        }
        let radians = degrees * .pi / 180
        let result = tan(radians)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processNaturalLogarithm() {
        if state.displayValue <= 0 {
            presenter?.didEncounterError("Logarithm of non-positive number")
            return
        }
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = log(number)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processBase10Logarithm() {
        if state.displayValue <= 0 {
            presenter?.didEncounterError("Logarithm of non-positive number")
            return
        }
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = log10(number)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processEToThePowerOfX() {
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = exp(number)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processTenToThePowerOfX() {
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = pow(10, number)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processXToThePowerOfY() {
        if state.firstOperand == nil {
            state.firstOperand = state.displayValue
            state.pendingOperation = .xToThePowerOfY
            state.isNewValue = true
        } else if let firstOperand = state.firstOperand, state.pendingOperation == .xToThePowerOfY {
            let base = NSDecimalNumber(decimal: firstOperand).doubleValue
            let exponent = NSDecimalNumber(decimal: state.displayValue).doubleValue
            let result = pow(base, exponent)
            state.displayValue = Decimal(result, roundingMode: .plain)
            presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
            state.firstOperand = nil
            state.pendingOperation = nil
            state.isNewValue = true
        }
    }

    func processCubeRoot() {
        let number = NSDecimalNumber(decimal: state.displayValue).doubleValue
        let result = cbrt(number)
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }

    func processFactorial() {
        if state.displayValue < 0 || NSDecimalNumber(decimal: state.displayValue).doubleValue.truncatingRemainder(dividingBy: 1) != 0 {
            presenter?.didEncounterError("Factorial of negative or non-integer number")
            return
        }
        let number = NSDecimalNumber(decimal: state.displayValue).intValue
        var result = 1
        if number == 0 {
            result = 1
        } else {
            for i in 1...number {
                result *= i
            }
        }
        state.displayValue = Decimal(result, roundingMode: .plain)
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
        state.isNewValue = true
    }
    
    private func performCalculation(firstOperand: Decimal, secondOperand: Decimal, operation: Operation) -> Decimal {
        switch operation {
        case .add:
            return firstOperand + secondOperand
        case .subtract:
            return firstOperand - secondOperand
        case .multiply:
            return firstOperand * secondOperand
        case .divide:
            if secondOperand == 0 {
                presenter?.didEncounterError("Error")
                return 0
            }
            return firstOperand / secondOperand
        case .percentage, .squareRoot, .powerOfTwo, .sine, .cosine, .tangent, .naturalLogarithm, .base10Logarithm, .eToThePowerOfX, .tenToThePowerOfX, .xToThePowerOfY, .cubeRoot, .factorial, .signChange:
            // These are handled in their own methods or require two operands
            return state.displayValue
        }
    }
    
    private func formatDisplay(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.usesGroupingSeparator = false // Ensure no grouping separators for consistent testing
        formatter.decimalSeparator = "." // Ensure dot as decimal separator for consistent testing
        return formatter.string(from: number) ?? "0"
    }
}

