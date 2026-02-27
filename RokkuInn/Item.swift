//
//  Item.swift
//  RokkuInn
//
//  Created by Marcus Chang on 2026/02/26.
//

import Foundation
import SwiftData

/// Template SwiftData model left from the project bootstrap.
@Model
final class Item {
    /// Example field representing when the entry was created.
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
