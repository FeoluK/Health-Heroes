//
//  Extensions.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/25/25.
//

import Foundation
import RealityFoundation

extension SIMD3 where Scalar == Float {
    func distance(to vector: SIMD3<Float>) -> Float {
        return simd_distance(self, vector)
    }
}
