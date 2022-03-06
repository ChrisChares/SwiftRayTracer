//
//  Bitmap.swift
//  ComputerGraphics
//
//  Created by chris on 1/28/22.
//

import Foundation
import AppKit

struct Bitmap {
    let width: Int
    var pixels: [Color]
    
    var height: Int {
        pixels.count / width
    }
    
    subscript(x: Int, y: Int) -> Color {
        get { pixels[y * width + x] }
        set { pixels[y * width + x] = newValue }
    }
    
    init(width: Int, height: Int, color: Color) {
        self.width = width
        pixels = Array(repeating: color, count: width * height)
    }
}

// MARK: Image Rendering
extension NSImage {
    convenience init?(bitmap: Bitmap) {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixel = MemoryLayout<Color>.stride
        let bytesPerRow = bitmap.width * bytesPerPixel

        guard let providerRef = CGDataProvider(data: Data(bytes: bitmap.pixels, count: bitmap.height * bytesPerRow) as CFData) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: bitmap.width,
            height: bitmap.height,
            bitsPerComponent: 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        self.init(cgImage: cgImage, size: NSSize(width: bitmap.width, height: bitmap.height))
    }
}
