//
//  RayTracer.swift
//  ComputerGraphics
//
//  Created by chris on 1/25/22.
//

import Foundation
import simd

private let MinDistance = 1.0
private let MaxDistance = CGFloat.infinity

struct RayTracer {
    
    let scene: Scene
    let bounds: CGRect
    
    init(scene: Scene, bounds: CGRect) {
        self.scene = scene
        self.bounds = bounds
    }
    
    /**
        Runs the ray tracer against the scene, rendering pixels to the provided canvas
     */
    func run(canvas: CanvasView) {
        print("Running ray tracer")
        
        // Camera lives at 0,0,0
        let observer = simd_double3(x: 0, y: 0, z: 0)
        
        // This method will execute the passed closure for every pixel in the canvas and batch the updates together
        canvas.draw { (x: Int, y: Int) -> Color in
            // Calculate the vector of a ray passing through this pixel
            let D = canvasToViewport(x: x, y: y)
            
            // Calculate the color for this pixel
            let color = traceRay(
                O: observer,
                D: D,
                minDistance: MinDistance,
                maxDistance: MaxDistance,
                recursiveDepth: 2 // reflection depth
            )
            return color
        }
    }
    
    /**
        Returns the vector of a ray that originates in the camera, and passes through (x, y) in the viewport
     */
    func canvasToViewport(x: Int, y: Int) -> simd_double3 {
        let cH = bounds.height
        let cW = bounds.width
        
        // We are currently defining the viewport dimensions to be equal to 1 for convenience
        let vH = 1.0
        let vW = cW / cH// With an adjustment for non 1:1 aspect ratios
        
        let dx = CGFloat(x) * (vW / cW)
        let dy = CGFloat(y) * (vH / cH)
        let dz = 1.0 // this is a constant for now, we know the viewport will always be 1 unit from the camera on the z axis
        return simd_double3(x: dx, y: dy, z: dz)
    }
    
    /**
        Traces a ray from point O in direction D, returning the Color value discovered.
        - Parameters:
            - O: The origin point
            - D: Ray vector
            - minDistance: The minimum distance of the ray
            - maxDistance: the maximum distance of the ray
            - recursiveDepth: How deep should the reflectionr rabbit hole go?
        - Returns: The color discovered by this ray
     */
    func traceRay(
        O: simd_double3,
        D: simd_double3,
        minDistance: CGFloat,
        maxDistance: CGFloat,
        recursiveDepth: Int
    ) -> Color {
        let (closestSphere, closestT) = scene.closestIntersection(
            O: O,
            D: D,
            minDistance: minDistance,
            maxDistance: maxDistance
        )
        
        guard let closestSphere = closestSphere else {
            // We've missed, return the environment
            return scene.backgroundColor
        }

        // Do lighting
        // Find the point we are calculating lighting for
        let P = O + (D * closestT)
        // Calculate the normal of this point
        let N = simd_normalize(P - closestSphere.center)
        // How illuminated is this point (0 - 1)
        let illumination = scene.lighting.reduce(0.0) { partialResult, lighting in
            return partialResult + lighting.computeLighting(
                scene: scene,
                P: P,
                N: N,
                V: D * -1.0,
                s: closestSphere.specular
            )
        }
        // localColor would be the final color, but we will check reflections from other objects first
        let localColor = closestSphere.color * illumination
        
        // If we hit the recursion limit or the object is not reflective, we're done
        let r = closestSphere.reflective
        if recursiveDepth <= 0 || r <= 0 {
           return localColor
        }
        
        // Calculate the reflected ray
        let R = simd_reflect(D, N)
        // Calculate the color of the reflected ray
        let reflectedColor = traceRay(
            O: P,
            D: R,
            minDistance: 0.001,
            maxDistance: .infinity,
            recursiveDepth: recursiveDepth - 1
        )
        return (localColor * (1 - r)) + reflectedColor * r
    }
}
