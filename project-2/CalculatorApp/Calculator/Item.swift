//
//  Item.swift
//  Calculator
//
//  Created by Yuhsuan Lin on 2025/9/20.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
