// CurrencyExchangeEntity.swift
import Foundation

// Enum for supported currencies
enum Currency: String, CaseIterable, Identifiable {
    case TWD, USD, JPY, KRW
    var id: String { self.rawValue }
}

// Struct to hold constant exchange rates
struct ExchangeRates {
    static let rates: [Currency: [Currency: Decimal]] = [
        .TWD: [
            .USD: 0.032, // 1 TWD = 0.032 USD
            .JPY: 4.80,  // 1 TWD = 4.80 JPY
            .KRW: 43.00  // 1 TWD = 43.00 KRW
        ],
        .USD: [
            .TWD: 31.25, // 1 USD = 31.25 TWD
            .JPY: 150.00, // 1 USD = 150.00 JPY
            .KRW: 1340.00 // 1 USD = 1340.00 KRW
        ],
        .JPY: [
            .TWD: 0.208, // 1 JPY = 0.208 TWD
            .USD: 0.0066, // 1 JPY = 0.0066 USD
            .KRW: 8.90   // 1 JPY = 8.90 KRW
        ],
        .KRW: [
            .TWD: 0.023, // 1 KRW = 0.023 TWD
            .USD: 0.00075, // 1 KRW = 0.00075 USD
            .JPY: 0.11   // 1 KRW = 0.11 JPY
        ]
    ]
}

// Enum for potential currency exchange errors
enum CurrencyExchangeError: Error {
    case invalidAmount
    case unsupportedCurrencyPair
}
