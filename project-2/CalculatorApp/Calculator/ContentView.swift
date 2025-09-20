import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        CalculatorViewWrapper()
    }
}

struct CalculatorViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return CalculatorRouter.createModule()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    ContentView()
}
