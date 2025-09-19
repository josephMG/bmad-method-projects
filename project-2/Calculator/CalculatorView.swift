import SwiftUI

struct CalculatorView: View, CalculatorViewProtocol {
    @State private var displayText = "0"
    var presenter: CalculatorPresenterProtocol?

    init(presenter: CalculatorPresenterProtocol? = nil) {
        self.presenter = presenter
    }
    
    var body: some View {
        VStack(spacing: 1) {
            // Display
            HStack {
                Spacer()
                Text(displayText)
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
            self.presenter?.viewDidLoad()
        }
    }

    // Button Tap Logic
    private func didTapButton(_ button: String) {
        switch button {
        case "0"..."9":
            presenter?.didTapDigit(button)
        case "+", "-", "×", "÷":
            presenter?.didTapOperator(button)
        case "=":
            presenter?.didTapEquals()
        case "AC":
            presenter?.didTapClear()
        case ".":
            presenter?.didTapDecimal()
        case "+/-":
            presenter?.didTapSign()
        case "%":
            presenter?.didTapPercent()
        default:
            break
        }
    }
    
    // Presenter -> View
    func updateDisplay(with text: String) {
        self.displayText = text
    }

    // Button Layout Definition
    private let buttonLayout: [[String]] = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    // Button Color Logic
    private func buttonBackgroundColor(for button: String) -> Color {
        switch button {
        case "AC", "+/-", "%":
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

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let presenter = CalculatorPresenter()
        let view = CalculatorView(presenter: presenter)
        presenter.view = view // A simplified connection for preview
        return view
    }
}
