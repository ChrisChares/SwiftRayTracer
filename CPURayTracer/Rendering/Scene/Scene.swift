//
//  Scene.swift
//  ComputerGraphics
//
//  Created by chris on 1/25/22.
//

import Foundation
import simd

struct Scene {
    
    let backgroundColor: Color
    let spheres: [Sphere]
    let lighting: [Lighting]
    
    /*
     Checks if a ray emitted from point O in direction D intsersects with any spheres from the scene.
     - Parameters:
        - O: The origin of the ray
        - D: The direction of the ray
        - minDistance: the minDistance a hit can be from O
        - maxDistance: the maxDistance a hit can be from O
     - Returns: The closest sphere intersected (if any) and how far in a tuple
     */
    func closestIntersection(
        O: simd_double3,
        D: simd_double3,
        minDistance: CGFloat,
        maxDistance: CGFloat
    ) -> (Sphere?, CGFloat) {
        var closestT = CGFloat.infinity
        var closestSphere: Sphere? = nil
        
        let validRange = (minDistance..<maxDistance)

        for sphere in spheres {
            // It's possible to intersect the sphere in 0, 1, or 2 spots
            let (t1, t2) = sphere.intersects(O: O, D: D)
            if validRange.contains(t1) &&  t1 < closestT {
                closestT = t1
                closestSphere = sphere
            }
            if validRange.contains(t2) && t2 < closestT {
                closestT = t2
                closestSphere = sphere
            }
        }
        
        return (closestSphere, closestT)
    }
}



// MARK: Samples
extension Scene {
    struct Samples {
        static let fourSpheres: Scene = Scene(
            backgroundColor: .black,
            spheres: [
                Sphere(radius: 2.0, center: simd_double3(x: 2, y: 2, z: 5), color: .red, specular: 500, reflective: 0.5),
                Sphere(radius: 1.0, center: simd_double3(x: -2, y: 2, z: 7), color: .blue, specular: 500, reflective: 0.5),
                Sphere(radius: 1.0, center: simd_double3(x: 0, y: 1, z: 9), color: .green, specular: 500, reflective: 0.5),
                Sphere(radius: 5000, center: simd_double3(x: 0, y: -5001, z: 0), color: .gray, specular: 1000, reflective: 0.5)
            ],
            lighting: [
                LightingSource.ambient(intensity: 0.2),
                LightingSource.point(intensity: 0.6, position: simd_double3(x: 2, y: 1, z: 0)),
                LightingSource.directional(intensity: 0.2, direction: simd_double3(x: 1, y: 4, z: 4))
            ]
        )
    }
}

