import Foundation

class CalculatorInteractor: CalculatorInteractorInputProtocol {
    weak var presenter: CalculatorInteractorOutputProtocol?
    private var state = CalculationState()

    func processDigit(_ digit: String) {
        guard let digitValue = Decimal(string: digit) else { return }

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
        guard let operation = Operation(rawValue: opString) else { return }
        
        // If there's a pending operation, calculate it first
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
        
        // Reset for next calculation
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
    
    func processPercent() {
        state.displayValue /= 100
        presenter?.didUpdateDisplayValue(formatDisplay(state.displayValue))
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
        }
    }
    
    private func formatDisplay(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        // Use a number formatter to avoid scientific notation and trailing zeros
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: number) ?? "0"
    }
}
