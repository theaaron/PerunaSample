//
//  Triangle.swift
//  asdf
//
//  Created by aaron on 3/13/25.
//


import Foundation
import MetalKit

// MARK: - Triangle Implementation

class PTriangle: PShape {
    
    private let vertexBuffer: MTLBuffer
    private let isStrokeBuffer: MTLBuffer
    private let strokeWidth: Float
    private let hasStroke: Bool
    private let fillColor: SIMD4<Float>
    private let strokeColor: SIMD4<Float>
    private var currentTransform: Transform
    
    init(device: MTLDevice,
         x1: Float, y1: Float,
         x2: Float, y2: Float,
         x3: Float, y3: Float,
         canvasWidth: Float, canvasHeight: Float,
         fillColor: SIMD4<Float> = SIMD4<Float>(1.0, 0.2, 0.5, 1.0),
         strokeColor: SIMD4<Float> = SIMD4<Float>(1.0, 1.0, 1.0, 1.0),
         strokeWidth: Float = 0,
         hasStroke: Bool) {
        
        self.strokeWidth = strokeWidth
        self.hasStroke = hasStroke
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.currentTransform = Transform()
        
        // Convert coordinates to normalized device coordinates (-1 to 1)
        let ndcX1 = (x1 - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY1 = ((canvasHeight / 2) - y1) / (canvasHeight / 2)
        let ndcX2 = (x2 - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY2 = ((canvasHeight / 2) - y2) / (canvasHeight / 2)
        let ndcX3 = (x3 - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY3 = ((canvasHeight / 2) - y3) / (canvasHeight / 2)
        
        // Calculate stroke width in NDC space
        let strokeWidthNDC = strokeWidth / min(canvasWidth, canvasHeight)
        
        var vertices: [Float] = []
        var isStroke: [Bool] = []
        
        if hasStroke && strokeWidth > 0 {
            // Calculate edge vectors
            let edge1 = SIMD2<Float>(ndcX2 - ndcX1, ndcY2 - ndcY1)
            let edge2 = SIMD2<Float>(ndcX3 - ndcX2, ndcY3 - ndcY2)
            let edge3 = SIMD2<Float>(ndcX1 - ndcX3, ndcY1 - ndcY3)
            
            // Calculate perpendicular vectors for stroke
            let perp1 = SIMD2<Float>(-edge1.y, edge1.x)
            let perp2 = SIMD2<Float>(-edge2.y, edge2.x)
            let perp3 = SIMD2<Float>(-edge3.y, edge3.x)
            
            // Normalize perpendicular vectors
            let len1 = length(perp1)
            let len2 = length(perp2)
            let len3 = length(perp3)
            
            let normPerp1 = perp1 / len1 * strokeWidthNDC
            let normPerp2 = perp2 / len2 * strokeWidthNDC
            let normPerp3 = perp3 / len3 * strokeWidthNDC
            
            // Create vertices for the stroke
            // Edge 1
            vertices += [ndcX1 + normPerp1.x, ndcY1 + normPerp1.y, 0, 1]
            vertices += [ndcX2 + normPerp1.x, ndcY2 + normPerp1.y, 0, 1]
            vertices += [ndcX1 - normPerp1.x, ndcY1 - normPerp1.y, 0, 1]
            
            vertices += [ndcX1 - normPerp1.x, ndcY1 - normPerp1.y, 0, 1]
            vertices += [ndcX2 + normPerp1.x, ndcY2 + normPerp1.y, 0, 1]
            vertices += [ndcX2 - normPerp1.x, ndcY2 - normPerp1.y, 0, 1]
            
            // Edge 2
            vertices += [ndcX2 + normPerp2.x, ndcY2 + normPerp2.y, 0, 1]
            vertices += [ndcX3 + normPerp2.x, ndcY3 + normPerp2.y, 0, 1]
            vertices += [ndcX2 - normPerp2.x, ndcY2 - normPerp2.y, 0, 1]
            
            vertices += [ndcX2 - normPerp2.x, ndcY2 - normPerp2.y, 0, 1]
            vertices += [ndcX3 + normPerp2.x, ndcY3 + normPerp2.y, 0, 1]
            vertices += [ndcX3 - normPerp2.x, ndcY3 - normPerp2.y, 0, 1]
            
            // Edge 3
            vertices += [ndcX3 + normPerp3.x, ndcY3 + normPerp3.y, 0, 1]
            vertices += [ndcX1 + normPerp3.x, ndcY1 + normPerp3.y, 0, 1]
            vertices += [ndcX3 - normPerp3.x, ndcY3 - normPerp3.y, 0, 1]
            
            vertices += [ndcX3 - normPerp3.x, ndcY3 - normPerp3.y, 0, 1]
            vertices += [ndcX1 + normPerp3.x, ndcY1 + normPerp3.y, 0, 1]
            vertices += [ndcX1 - normPerp3.x, ndcY1 - normPerp3.y, 0, 1]
            
            // All of these vertices are for stroke
            for _ in 0..<18 {
                isStroke.append(true)
            }
            
            // Create vertices for the fill
            vertices += [ndcX1, ndcY1, 0, 1]
            vertices += [ndcX2, ndcY2, 0, 1]
            vertices += [ndcX3, ndcY3, 0, 1]
            
            // These vertices are for fill
            for _ in 0..<3 {
                isStroke.append(false)
            }
        } else {
            // Create vertices for the triangle without stroke
            vertices += [ndcX1, ndcY1, 0, 1]
            vertices += [ndcX2, ndcY2, 0, 1]
            vertices += [ndcX3, ndcY3, 0, 1]
            
            // All vertices are fill
            for _ in 0..<3 {
                isStroke.append(false)
            }
        }
        
        // Create vertex buffer
        guard let buffer = device.makeBuffer(bytes: vertices,
                                           length: vertices.count * MemoryLayout<Float>.size,
                                           options: []) else {
            fatalError("Could not create vertex buffer")
        }
        self.vertexBuffer = buffer
        
        // Create is-stroke buffer
        guard let strokeBuffer = device.makeBuffer(bytes: isStroke,
                                              length: isStroke.count * MemoryLayout<Bool>.size,
                                              options: []) else {
            fatalError("Could not create stroke buffer")
        }
        self.isStrokeBuffer = strokeBuffer
    }
    
    func draw(encoder: MTLRenderCommandEncoder) {
        // Update uniforms with current transform
        var uniforms = Uniforms(
            fillColor: fillColor,
            strokeColor: strokeColor,
            hasStroke: hasStroke ? 1 : 0,
            transform: currentTransform.getMatrix()
        )
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 2)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(isStrokeBuffer, offset: 0, index: 1)
        
        let vertexCount = hasStroke && strokeWidth > 0 ? 21 : 3
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
    
    func updateTransform(_ transform: Transform) {
        currentTransform = transform
    }
}

