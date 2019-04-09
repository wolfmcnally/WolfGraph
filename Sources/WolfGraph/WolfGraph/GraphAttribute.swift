//
//  GraphAttribute.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/10/18.
//

import Foundation
import WolfGraphics
import WolfCore

public protocol GraphAttribute { }

extension Bool: GraphAttribute { }
extension Int: GraphAttribute { }
extension Double: GraphAttribute { }

struct StringTag: ExtensibleEnumeratedName {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension StringTag {
    static let string = StringTag("s")
    static let date = StringTag("ymd")
    static let url = StringTag("url")
    static let uuid = StringTag("id")
    static let point = StringTag("xy")
    static let size = StringTag("wh")
    static let rect = StringTag("xywh")
    static let color = StringTag("rgba")
}

protocol StringEncodable: GraphAttribute {
    var tag: StringTag { get }
    var stringValue: String { get }
    var stringEncoding: String { get }
}

extension StringEncodable {
    var stringEncoding: String {
        return tag.rawValue + ":" + stringValue
    }
}

protocol StringDecodable {
    init(stringValue: String) throws
}

protocol StringCodable: StringEncodable, StringDecodable { }

extension String: StringCodable {
    var tag: StringTag { return .string }

    var stringValue: String { return self }

    init(stringValue: String) throws {
        self = stringValue
    }
}

extension Date: StringCodable {
    private typealias `Self` = Date

    var tag: StringTag { return .date }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    var stringValue: String {
        return Self.formatter.string(from: self)
    }

    init(stringValue: String) throws {
        guard let date = Self.formatter.date(from: stringValue) else {
            throw GraphError("Invalid Date")
        }
        self = date
    }
}

extension URL: StringCodable {
    var tag: StringTag { return .url }
    var stringValue: String { return self.absoluteString }

    init(stringValue: String) throws {
        guard let url = URL(string: stringValue) else {
            throw GraphError("Invalid URL")
        }
        self = url
    }
}

extension UUID: StringCodable {
    var tag: StringTag { return .uuid }
    var stringValue: String { return self.uuidString }

    init(stringValue: String) throws {
        guard let uuid = UUID(uuidString: stringValue) else {
            throw GraphError("Invalid UUID")
        }
        self = uuid
    }
}

extension Point: StringCodable {
    var tag: StringTag { return .point }
    var stringValue: String { return String(x) + "," + String(y) }

    init(stringValue: String) throws {
        let elements = stringValue.split(separator: ",")
        guard elements.count == 2,
            let x = Double(elements[0]),
            let y = Double(elements[1]) else {
            throw GraphError("Invalid Point")
        }
        self = Point(x: x, y: y)
    }
}

extension Size: StringCodable {
    var tag: StringTag { return .size }
    var stringValue: String { return String(width) + "," + String(height) }

    init(stringValue: String) throws {
        let elements = stringValue.split(separator: ",")
        guard elements.count == 2,
            let width = Double(elements[0]),
            let height = Double(elements[1]) else {
                throw GraphError("Invalid Size")
        }
        self = Size(width: width, height: height)
    }
}

extension Rect: StringCodable {
    var tag: StringTag { return .rect }
    var stringValue: String { return [origin.x, origin.y, size.width, size.height].map( { String($0) }).joined(separator: ",") }

    init(stringValue: String) throws {
        let elements = stringValue.split(separator: ",")
        guard elements.count == 4,
            let x = Double(elements[0]),
            let y = Double(elements[1]),
            let width = Double(elements[2]),
            let height = Double(elements[3]) else {
                throw GraphError("Invalid Rect")
        }
        self = Rect(x: x, y: y, width: width, height: height)
    }
}

extension Color: StringCodable {
    var tag: StringTag { return .color }
    var stringValue: String { return [red, green, blue, alpha].map( { String($0) }).joined(separator: ",") }

    init(stringValue: String) throws {
        let elements = stringValue.split(separator: ",")
        guard elements.count == 4,
        let red = Double(elements[0]),
        let green = Double(elements[1]),
        let blue = Double(elements[2]),
        let alpha = Double(elements[3]) else {
            throw GraphError("Invalid Color")
        }
        self = Color(red: red, green: green, blue: blue, alpha: alpha)
    }
}

func decodeString(_ s: String) throws -> GraphAttribute {
    let elements = s.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
    guard elements.count == 2 else {
        throw GraphError("Untagged string")
    }
    let tag = StringTag(String(elements[0]))
    let stringValue = String(elements[1])

    switch tag {
    case .string:
        return try String(stringValue: stringValue)
    case .date:
        return try Date(stringValue: stringValue)
    case .url:
        return try URL(stringValue: stringValue)
    case .uuid:
        return try UUID(stringValue: stringValue)
    case .point:
        return try Point(stringValue: stringValue)
    case .size:
        return try Size(stringValue: stringValue)
    case .rect:
        return try Rect(stringValue: stringValue)
    case .color:
        return try Color(stringValue: stringValue)
    default:
        throw GraphError("Unknown tag in string")
    }
}
