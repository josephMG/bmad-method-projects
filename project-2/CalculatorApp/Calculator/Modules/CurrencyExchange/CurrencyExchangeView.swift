// CurrencyExchangeView.swift
import SwiftUI

struct CurrencyExchangeView: View {
    @ObservedObject var presenter: CurrencyExchangePresenter

    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Exchange")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 10) {
                Text("Source Currency")
                    .foregroundColor(.white)
                Picker("Source Currency", selection: $presenter.selectedSourceCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                TextField("Enter amount", text: $presenter.sourceAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                Text("Target Currency")
                    .foregroundColor(.white)
                Picker("Target Currency", selection: $presenter.selectedTargetCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                Text(presenter.targetAmount)
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            Button(action: {
                presenter.didTapConvert()
            }) {
                Text("Convert")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            presenter.viewDidLoad()
        }
    }
}

struct CurrencyExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        let presenter = CurrencyExchangePresenter()
        return CurrencyExchangeView(presenter: presenter)
    }
}
