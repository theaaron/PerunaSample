//
//  Line.swift
//  PerunaSample
//
//  Created by aaron on 2/27/25.
//

import MetalKit

class PLine: PShape {
    
    private let vertexBuffer: MTLBuffer
    private let isStrokeBuffer: MTLBuffer
    private let strokeWidth: Float
    private let hasStroke: Bool
    private let strokeColor: SIMD4<Float>
    private var currentTransform: Transform
    
    init(device: MTLDevice,
         x1: Float, y1: Float,
         x2: Float, y2: Float,
         canvasWidth: Float, canvasHeight: Float,
         strokeColor: SIMD4<Float> = SIMD4<Float>(1.0, 1.0, 1.0, 1.0),
         strokeWidth: Float = 0,
         hasStroke: Bool) {
        
        self.strokeWidth = strokeWidth
        self.hasStroke = hasStroke
        self.strokeColor = strokeColor
        self.currentTransform = Transform()
        
        let ndcX1 = (x1 - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY1 = ((canvasHeight / 2) - y1) / (canvasHeight / 2)
        let ndcX2 = (x2 - (canvasWidth / 2)) / (canvasWidth / 2)
        let ndcY2 = ((canvasHeight / 2) - y2) / (canvasHeight / 2)
        
        let dx = ndcX2 - ndcX1
        let dy = ndcY2 - ndcY1
        let length = sqrt(dx * dx + dy * dy)
        
        let strokeWidthNDC = strokeWidth / min(canvasWidth, canvasHeight)
        let perpX = -dy / length * strokeWidthNDC
        let perpY = dx / length * strokeWidthNDC
        
        var vertices: [Float] = []
        var isStroke: [Bool] = []
        
        if hasStroke && strokeWidth > 0 {
            vertices += [ndcX1 + perpX, ndcY1 + perpY, 0, 1]
            vertices += [ndcX2 + perpX, ndcY2 + perpY, 0, 1]
            vertices += [ndcX1 - perpX, ndcY1 - perpY, 0, 1]
            
            vertices += [ndcX1 - perpX, ndcY1 - perpY, 0, 1]
            vertices += [ndcX2 + perpX, ndcY2 + perpY, 0, 1]
            vertices += [ndcX2 - perpX, ndcY2 - perpY, 0, 1]
            
            for _ in 0..<6 {
                isStroke.append(true)
            }
        } else {
            vertices += [ndcX1, ndcY1, 0, 1]
            vertices += [ndcX2, ndcY2, 0, 1]
            
            for _ in 0..<2 {
                isStroke.append(true)
            }
        }
        
        guard let buffer = device.makeBuffer(bytes: vertices,
                                           length: vertices.count * MemoryLayout<Float>.size,
                                           options: []) else {
            fatalError("Could not create vertex buffer")
        }
        self.vertexBuffer = buffer
        
        guard let strokeBuffer = device.makeBuffer(bytes: isStroke,
                                              length: isStroke.count * MemoryLayout<Bool>.size,
                                              options: []) else {
            fatalError("Could not create stroke buffer")
        }
        self.isStrokeBuffer = strokeBuffer
    }
    
    func draw(encoder: MTLRenderCommandEncoder) {
        var uniforms = Uniforms(
            fillColor: strokeColor, // Use stroke color for fill since lines don't have fill
            strokeColor: strokeColor,
            hasStroke: hasStroke ? 1 : 0,
            transform: currentTransform.getMatrix()
        )
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 2)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(isStrokeBuffer, offset: 0, index: 1)
        
        let vertexCount = hasStroke && strokeWidth > 0 ? 6 : 2
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
    
    func updateTransform(_ transform: Transform) {
        currentTransform = transform
    }
} 
