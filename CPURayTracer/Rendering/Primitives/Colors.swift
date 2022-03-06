//
//  Colors.swift
//  ComputerGraphics
//
//  Created by chris on 1/27/22.
//

import Foundation

// TODO: SIMD conversion
struct Color: Equatable {
    var r, g, b: UInt8
    var a: UInt8 = 255
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 255.0) {
        self.r = UInt8(max(min(r, 255), 0))
        self.g = UInt8(max(min(g, 255), 0))
        self.b = UInt8(max(min(b, 255), 0))
        self.a = UInt8(max(min(a, 255), 0))
    }
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

extension Color {
    static let clear = Color(r: 0.0, g: 0.0, b: 0, a: 0)
    static let black = Color(r: 0.0, g: 0.0, b: 0)
    static let white = Color(r: 255.0, g: 255, b: 255)
    static let gray = Color(r: 192.0, g: 192, b: 192)
    static let darkGray = Color(r: 96.0, g: 96, b: 96)
    static let red = Color(r: 255.0, g: 0, b: 0)
    static let green = Color(r: 0.0, g: 255, b: 0)
    static let blue = Color(r: 0.0, g: 0, b: 255)
    static let yellow = Color(r: 255.0, g: 255, b: 0)
    static let purple = Color(r: 255.0, g: 0, b: 255)
    static let cyan = Color(r: 0, g: 255.0, b: 255.0)
}

func * (_ lhs: Color, _ rhs: CGFloat) -> Color {
    return Color(
        r: CGFloat(lhs.r) * rhs,
        g: CGFloat(lhs.g) * rhs,
        b: CGFloat(lhs.b) * rhs
    )
}

func + (lhs: Color, rhs: Color) -> Color {
    return Color(
        r: CGFloat(rhs.r) + CGFloat(lhs.r),
        g: CGFloat(lhs.g) + CGFloat(rhs.g),
        b: CGFloat(lhs.b) + CGFloat(rhs.b),
        a: CGFloat(lhs.a) + CGFloat(rhs.a)
    )
}

