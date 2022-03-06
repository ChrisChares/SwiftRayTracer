//
//  Lighting.swift
//  ComputerGraphics
//
//  Created by chris on 1/27/22.
//

import Foundation
import simd

// MARK: Protocol
protocol Lighting {
    /**
        Compute the intensity of the light hitting point P
        - Parameters:
            - P: The point we are calculating lighting for
            - N: The reflection vector of light from this point
            - V:  The vector back to the observer
            - s: The specular rating of the surface
        - Returns: 0-1 adjustment of lighting to be applied to the pixel
     */
    func computeLighting(
        scene: Scene,
        P: simd_double3,
        N: simd_double3,
        V: simd_double3,
        s: CGFloat
    ) -> CGFloat
}

// MARK: Factory Helpers
struct LightingSource {
    
    /// In our simplistic render-world, ambient lighting is a constant everywhere in the scene
    static func ambient(intensity: CGFloat) -> some Lighting {
        return AmbientLight(intensity: intensity)
    }
    
    /// Directional lighting is essential a point light that is very far away.  Sol is the prime example.
    static func directional(intensity: CGFloat, direction: simd_double3) -> some Lighting {
        return DirectionalLighting(intensity: intensity, direction: direction)
    }
    
    /// A point light that radiates equally in all directions
    static func point(intensity: CGFloat, position: simd_double3) -> some Lighting {
        return PointLighting(intensity: intensity, position: position)
    }
}


// MARK: Private Helpers
extension Lighting {
    /**
        Compute the intensity of the light hitting point P
        - Parameters:
            - P: The point we are calculating lighting for
            - N: The reflection vector of light from this point
            - V:  The vector back to the observer
            - L: the vector from light to point
            - tMax: TODO: who the fuck knows
            - s: The specular rating of the surface
        - Returns: 0-1 adjustment of lighting to be applied to the pixel
     */
    fileprivate func calculateLightingIntensity(
        scene: Scene,
        inputItensity: CGFloat,
        P: simd_double3,
        N: simd_double3,
        V: simd_double3,
        L: simd_double3,
        tMax: CGFloat,
        s: CGFloat
    ) -> CGFloat {
        
        let (shadowSPhere, _) = scene.closestIntersection(
            O: P,
            D: L,
            minDistance: 0.001,
            maxDistance: tMax
        )
        if (shadowSPhere != nil) {
            // If another sphere is occluding, there is no light
            return 0;
        }
        
        var illumination = 0.0;
        
        /*
         Calculate defused lighting
         */
        let nDot1 = simd_dot(N, L)
        if nDot1 > 0 {
            illumination += (inputItensity * nDot1 / (simd_length(N) * simd_length(L)))
        }
        
        /*
         Calculate specular lighting
         */
        if s != -1 {
            let R = ((N * 2.0) * simd_dot(N, L)) - L
            let rDotV = simd_dot(R, V)
            if rDotV > 0 {
                illumination += inputItensity * pow(rDotV/(simd_length(R) * simd_length(V)), s)
            }
        }
        
        return illumination;
    }
    
}

// MARK: Implementations
struct AmbientLight: Lighting {
    
    let intensity: CGFloat
    
    func computeLighting(
        scene: Scene,
        P: simd_double3,
        N: simd_double3,
        V: simd_double3,
        s: CGFloat
    ) -> CGFloat {
        return intensity
    }
}

struct DirectionalLighting: Lighting {
    let intensity: CGFloat
    let direction: simd_double3
    
    func computeLighting(
        scene: Scene,
        P: simd_double3,
        N: simd_double3,
        V: simd_double3,
        s: CGFloat
    ) -> CGFloat {
        return calculateLightingIntensity(
            scene: scene,
            inputItensity: intensity,
            P: P,
            N: N,
            V: V,
            L: direction,
            tMax: 1,
            s: s
        )
    }
}

struct PointLighting: Lighting {
    let intensity: CGFloat
    let position: simd_double3
    
    func computeLighting(
        scene: Scene,
        P: simd_double3,
        N: simd_double3,
        V: simd_double3,
        s: CGFloat
    ) -> CGFloat {
        return calculateLightingIntensity(
            scene: scene,
            inputItensity: intensity,
            P: P,
            N: N,
            V: V,
            L: position - P,
            tMax: 1,
            s: s
        )
    }
}
