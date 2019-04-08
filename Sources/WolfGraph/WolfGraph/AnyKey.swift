//
//  AnyKey.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/10/18.
//

import Foundation

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(_ key: String) {
        self.stringValue = key
        self.intValue = Int(key)
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}
