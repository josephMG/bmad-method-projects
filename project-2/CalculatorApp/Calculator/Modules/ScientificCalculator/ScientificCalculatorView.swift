// ScientificCalculatorView.swift
import SwiftUI

struct ScientificCalculatorView: View {
    @ObservedObject var presenter: ScientificCalculatorPresenter

    var body: some View {
        VStack(spacing: 1) {
            // Display
            HStack {
                Spacer()
                Text(presenter.displayText)
                    .font(.system(size: 90))
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .padding()
            }
            .padding(.horizontal)

            // Button Grid
            VStack(spacing: 1) {
                ForEach(buttonLayout, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(row, id: \.self) { buttonTitle in
                            Button(action: {
                                self.didTapButton(buttonTitle)
                            }) {
                                Text(buttonTitle)
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(buttonBackgroundColor(for: buttonTitle))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.black)
        .onAppear {
            self.presenter.viewDidLoad()
        }
    }

    // Button Tap Logic
    private func didTapButton(_ button: String) {
        switch button {
        case "0"..."9":
            presenter.didTapDigit(button)
        case "+", "-", "×", "÷":
            presenter.didTapOperator(button)
        case "=":
            presenter.didTapEquals()
        case "AC":
            presenter.didTapClear()
        case ".":
            presenter.didTapDecimal()
        case "+/-":
            presenter.didTapSign()
        case "x²":
            presenter.didTapPowerOfTwo()
        case "sin":
            presenter.didTapSine()
        case "cos":
            presenter.didTapCosine()
        case "tan":
            presenter.didTapTangent()
        case "ln":
            presenter.didTapNaturalLogarithm()
        case "log10":
            presenter.didTapBase10Logarithm()
        case "e^x":
            presenter.didTapEToThePowerOfX()
        case "10^x":
            presenter.didTapTenToThePowerOfX()
        case "x^y":
            presenter.didTapXToThePowerOfY()
        case "³√":
            presenter.didTapCubeRoot()
        case "x!":
            presenter.didTapFactorial()
        default:
            break
        }
    }

    // Button Layout Definition
    private let buttonLayout: [[String]] = [
        ["AC", "+/-", "x²", "÷"],
        ["sin", "cos", "tan", "×"],
        ["ln", "log10", "e^x", "10^x"],
        ["x^y", "³√", "x!", ""],
        ["7", "8", "9", "-"],
        ["4", "5", "6", "+"],
        ["1", "2", "3", "="],
        ["0", ".", "", ""]
    ]

    // Button Color Logic
    private func buttonBackgroundColor(for button: String) -> Color {
        switch button {
        case "AC", "+/-", "x²", "sin", "cos", "tan", "ln", "log10", "e^x", "10^x", "x^y", "³√", "x!":
            return Color(.lightGray)
        case "÷", "×", "-", "+", "=":
            return Color(.orange)
        case "0"..."9", ".":
            return Color(.darkGray)
        default:
            return Color(.darkGray)
        }
    }
}

struct ScientificCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let presenter = ScientificCalculatorPresenter()
        return ScientificCalculatorView(presenter: presenter)
    }
}
