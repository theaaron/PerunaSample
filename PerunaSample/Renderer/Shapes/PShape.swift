//
//  PShape.swift
//  PerunaSample
//
//  Created by aaron on 2/27/25.
//

import Foundation
import MetalKit

// MARK: - Shape Protocol and Implementation

protocol PShape {
    func draw(encoder: MTLRenderCommandEncoder)
}

extension PShape {
    func createUniformsBuffer(device: MTLDevice, fillColor: SIMD4<Float>, strokeColor: SIMD4<Float>, hasStroke: Bool, transform: float4x4) -> MTLBuffer {
        var uniforms = Uniforms(
            fillColor: fillColor,
            strokeColor: strokeColor,
            hasStroke: hasStroke ? 1 : 0,
            transform: transform
        )
        
        guard let buffer = device.makeBuffer(bytes: &uniforms,
                                           length: MemoryLayout<Uniforms>.size,
                                           options: []) else {
            fatalError("Could not create uniforms buffer")
        }
        return buffer
    }
}



