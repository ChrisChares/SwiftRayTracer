//
//  CanvasView.swift
//  ComputerGraphics
//
//  Created by chris on 1/24/22.
//

import AppKit
import CoreGraphics
import simd

class CanvasView: NSView {
    var imageView: NSImageView!
    var bitmap: Bitmap!

    override init(frame frameRect: NSRect) {
        bitmap = Bitmap(width: Int(frameRect.width), height: Int(frameRect.height), color: .white)
        imageView = NSImageView(image: NSImage(bitmap: bitmap)!)

        super.init(frame: frameRect)
        
        addSubview(imageView)
        /*
            Autolayout
         */
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func draw(_ fn: (Int, Int) -> Color) {
        let startDate = Date()

        for (x, y) in self {
            updatePixel(x: x, y: y, color: fn(x, y))
        }
        
        print("Computed pixels, total elapsed: \(Date().timeIntervalSince(startDate))")
        drawScreen()
        print("Updated canvas, total elapsed: \(Date().timeIntervalSince(startDate))")
    }

    // Still expects to be receiving screen coordinates, will perform conversion
    func updatePixel(x: Int, y: Int, color: Color) {
        let convertedX = convert(toBitmapX: x)
        let convertedY = convert(toBitmapY: y)
        
        if convertedX < 0 || convertedX >= Int(bounds.width) || convertedY < 0 || convertedY >= Int(bounds.height) {
            print("Attempting to draw outside of bounds at (x: \(x), y: \(y))")
            return
        }

        bitmap[convertedX, convertedY] = color
    }
    
    func drawScreen() {
        // TODO: there is probably a more appropriate abstraction somewhere between NSImage and Metal for updating the screen by pixel
        imageView.image = NSImage(bitmap: bitmap)
    }
}

/*
    Coordinate conversion
*/
extension CanvasView {
    var pixels: Int { Int(bounds.width * bounds.height) }
    
    func convert(toBitmapX x: Int) -> Int {
        return Int(bounds.width) / 2 + x
    }
    
    func convert(toBitmapY y: Int) -> Int {
        return Int(bounds.height) / 2 - y - 1
    }
}

/*
    Sequence / Iteration
*/
extension CanvasView: Sequence {
    typealias Element = (Int, Int)

    func makeIterator() -> CanvasPixelIterator {
        return CanvasPixelIterator(canvasSize: self.bounds.size)
    }
}

class CanvasPixelIterator: IteratorProtocol {
    typealias Element = (Int, Int)
    
    let size: NSSize
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    
    var currentX: Int
    var currentY: Int
    
    init(canvasSize: NSSize) {
        self.size = canvasSize
        
        minX = Int(size.width) / -2
        minY = Int(size.height) / -2
        maxX = Int(size.width) / 2
        maxY = Int(size.height) / 2
        
        currentX = minX
        currentY = minY
    }
    
    func next() -> (Int, Int)? {
        // End our iteration here
        guard currentX < maxX && currentY < maxY else { return nil }
        
        defer {
            // Iterate by column
            if (currentY == (maxY - 1)) {
                // Reset Y
                currentY = minY
                // Increment X
                currentX += 1
            } else {
                // Increment Y
                currentY += 1
            }
        }
        
        return (currentX, currentY)
    }
}
