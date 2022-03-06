//
//  Models.swift
//  CPURayTracer
//
//  Created by chris on 2/21/22.
//

import Foundation
import simd

protocol Intersectable {
    func intersects(
        O: simd_double3,
        D: simd_double3
    ) -> (CGFloat, CGFloat)
}

struct Sphere: Intersectable {
    let radius: CGFloat
    let center: simd_double3
    let color: Color
    // How much does light itself reflect from the surface?
    let specular: CGFloat
    // How reflective is the surface?
    let reflective: CGFloat
    
    func intersects(
        O: simd_double3,
        D: simd_double3
    ) -> (CGFloat, CGFloat) {
        let r = radius
        let CO: simd_double3 = O - center
            
        let a: CGFloat = simd_dot(D, D)
        let b: CGFloat = 2.0 * simd_dot(CO, D)
        let c: CGFloat = simd_dot(CO, CO) - r * r
        
        let discriminant: CGFloat = b * b - 4.0 * a * c
        
        guard discriminant >= 0 else {
            return (-1, -1)
        }
        
        let t1 = ((-1.0 * b) + sqrt(discriminant)) / (2.0 * a)
        let t2 = ((-1.0 * b) - sqrt(discriminant)) / (2.0 * a)
                
        return (t1, t2)
    }
}
