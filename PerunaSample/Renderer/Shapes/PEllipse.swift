//
//  Ellipse.swift
//  asdf
//
//  Created by aaron on 3/13/25.
//

import MetalKit
import Foundation

// MARK: - Ellipse Implementation


class PEllipse: PShape {
    
    private let vertexBuffer: MTLBuffer
    private let isStrokeBuffer: MTLBuffer
    private let strokeWidth: Float
    private let hasStroke: Bool
    private let fillColor: SIMD4<Float>
    private let strokeColor: SIMD4<Float>
    private var currentTransform: Transform
    private let segmentCount: Int
    
    init(device: MTLDevice,
         x: Float, y: Float,
         width: Float, height: Float,
         canvasWidth: Float, canvasHeight: Float,
         fillColor: SIMD4<Float> = SIMD4<Float>(1.0, 0.2, 0.5, 1.0),
         strokeColor: SIMD4<Float> = SIMD4<Float>(1.0, 1.0, 1.0, 1.0),
         strokeWidth: Float = 0,
         hasStroke: Bool,
         segmentCount: Int = 36) {
        
        self.strokeWidth = strokeWidth
        self.hasStroke = hasStroke
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.currentTransform = Transform()
        self.segmentCount = segmentCount
        
        // Convert coordinates to normalized device coordinates (-1 to 1)
        let ndcX = (x - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY = ((canvasHeight / 2) - y) / (canvasHeight / 2)
        
        let ndcRadiusX = (width / 2) / canvasWidth
        let ndcRadiusY = (height / 2) / canvasHeight
        
        var vertices: [Float] = []
        var isStroke: [Bool] = []
        
        if hasStroke && strokeWidth > 0 {
            // For an ellipse with stroke, we create an inner and outer ellipse
            // The inner ellipse radius is reduced by the stroke width
            let strokeWidthNDC = strokeWidth / min(canvasWidth, canvasHeight)
            let innerRadiusX = max(0.0, ndcRadiusX - strokeWidthNDC)
            let innerRadiusY = max(0.0, ndcRadiusY - strokeWidthNDC)
            
            // Create triangles for the stroke
            for i in 0..<segmentCount {
                let theta1 = Float(2.0 * Double.pi * Double(i) / Double(segmentCount))
                let theta2 = Float(2.0 * Double.pi * Double(i+1) / Double(segmentCount))
                
                let outerX1 = ndcX + cos(theta1) * ndcRadiusX
                let outerY1 = ndcY + sin(theta1) * ndcRadiusY
                let outerX2 = ndcX + cos(theta2) * ndcRadiusX
                let outerY2 = ndcY + sin(theta2) * ndcRadiusY
                
                let innerX1 = ndcX + cos(theta1) * innerRadiusX
                let innerY1 = ndcY + sin(theta1) * innerRadiusY
                let innerX2 = ndcX + cos(theta2) * innerRadiusX
                let innerY2 = ndcY + sin(theta2) * innerRadiusY
                
                // First triangle (outer1, outer2, inner1)
                vertices += [outerX1, outerY1, 0, 1]
                vertices += [outerX2, outerY2, 0, 1]
                vertices += [innerX1, innerY1, 0, 1]
                
                // Second triangle (inner1, outer2, inner2)
                vertices += [innerX1, innerY1, 0, 1]
                vertices += [outerX2, outerY2, 0, 1]
                vertices += [innerX2, innerY2, 0, 1]
                
                // These are for stroke
                for _ in 0..<6 {
                    isStroke.append(true)
                }
            }
            
            // Create triangles for the fill (interior of the ellipse)
            for i in 0..<segmentCount {
                let theta1 = Float(2.0 * Double.pi * Double(i) / Double(segmentCount))
                let theta2 = Float(2.0 * Double.pi * Double(i+1) / Double(segmentCount))
                
                let x1 = ndcX + cos(theta1) * innerRadiusX
                let y1 = ndcY + sin(theta1) * innerRadiusY
                let x2 = ndcX + cos(theta2) * innerRadiusX
                let y2 = ndcY + sin(theta2) * innerRadiusY
                
                // Triangle fan around center
                vertices += [ndcX, ndcY, 0, 1]
                vertices += [x1, y1, 0, 1]
                vertices += [x2, y2, 0, 1]
                
                // These are for fill
                for _ in 0..<3 {
                    isStroke.append(false)
                }
            }
        } else {
            // Create triangles for a simple ellipse without stroke
            for i in 0..<segmentCount {
                let theta1 = Float(2.0 * Double.pi * Double(i) / Double(segmentCount))
                let theta2 = Float(2.0 * Double.pi * Double(i+1) / Double(segmentCount))
                
                let x1 = ndcX + cos(theta1) * ndcRadiusX
                let y1 = ndcY + sin(theta1) * ndcRadiusY
                let x2 = ndcX + cos(theta2) * ndcRadiusX
                let y2 = ndcY + sin(theta2) * ndcRadiusY
                
                // Triangle fan around center
                vertices += [ndcX, ndcY, 0, 1]
                vertices += [x1, y1, 0, 1]
                vertices += [x2, y2, 0, 1]
                
                // All vertices are fill
                for _ in 0..<3 {
                    isStroke.append(false)
                }
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
        
        var vertexCount: Int
        if hasStroke && strokeWidth > 0 {
            vertexCount = segmentCount * 6 + segmentCount * 3 // 6 vertices per stroke segment + 3 vertices per fill segment
        } else {
            vertexCount = segmentCount * 3 // 3 vertices per segment
        }
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
    
    func updateTransform(_ transform: Transform) {
        currentTransform = transform
    }
}
