//
//  Renderer.swift
//  PerunaSample
//
//  Created by aaron on 2/25/25.
//

import SwiftUI
import MetalKit
import Combine


// Metal View Bridge for SwiftUI
struct MetalView: UIViewRepresentable {

    var renderer: MetalRenderer
    var shouldClear = false
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = renderer
        mtkView.device = renderer.device
        mtkView.clearColor = MTLClearColor(red: Double(renderer.backgroundColor.x), green: Double(renderer.backgroundColor.y), blue: Double(renderer.backgroundColor.z), alpha: Double(renderer.backgroundColor.w))
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.framebufferOnly = true
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update view size
        renderer.width = Float(uiView.bounds.width)
        renderer.height = Float(uiView.bounds.height)
    }
}

struct Uniforms {
    var fillColor: SIMD4<Float>   // 16 bytes
    var strokeColor: SIMD4<Float> // 16 bytes
    var hasStroke: Int32          // 4 bytes
    var transform: float4x4       // 64 bytes
}

// Metal Renderer
class MetalRenderer: NSObject, ObservableObject, MTKViewDelegate {
    let smuRed = SIMD4<Float>(204/255, 0.0, 53/255, 1.0)
    let smuBlue = SIMD4<Float>(53/255, 76/255, 161/255, 1.0)
    
    internal let device: MTLDevice
    internal let commandQueue: MTLCommandQueue
    internal var pipelineState: MTLRenderPipelineState!
    public var backgroundColor: SIMD4<Float>
    
    private var metalKitView: MTKView?
    
    internal var fillColor: SIMD4<Float>
    internal var strokeColor: SIMD4<Float>
    internal var hasStroke: Bool
    internal var hasFill: Bool
    
    private var animationTimer: AnyCancellable?
    private var frameCount: Int = 0
    private var drawHandler: ((_ p: MetalRenderer, _ frameCount: Int) -> Void)?
    
    // Canvas dimensions
    var width: Float = 300
    var height: Float = 300
    
    // Drawing buffer
    internal var shapes: [PShape] = [] 
    
    override init() {
        self.backgroundColor = SIMD4<Float>(0.1, 0.1, 0.1, 1.0)
        self.fillColor = SIMD4<Float>(204/255, 0.0, 53/255, 1.0)
        self.strokeColor = SIMD4<Float>(38/255, 38/255, 38/255, 1.0)
        self.hasStroke = true
        self.hasFill = true
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            fatalError("Could not create command queue")
        }
        self.commandQueue = queue
        
        super.init()
        setupRenderPipeline()
    }
    
    private func setupRenderPipeline() {
        // Define shaders as string
        let shaderSource = """
        #include <metal_stdlib>
        using namespace metal;

        struct VertexOut {
            float4 position [[position]];
            float4 color;
            bool isStroke;
        };

        struct Uniforms {
            packed_float4 fillColor;      // 16 bytes
            packed_float4 strokeColor;    // 16 bytes
            int32_t hasStroke;            // 4 bytes
            float4x4 transform;           // 64 bytes
        };

        vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                                  constant float4 *positions [[buffer(0)]],
                                  constant bool *isStroke [[buffer(1)]],
                                  constant Uniforms &uniforms [[buffer(2)]]) {
            VertexOut out;
            float4 pos = positions[vertexID];
            out.position = uniforms.transform * pos;
            out.isStroke = isStroke[vertexID];
            return out;
        }

        fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                     constant Uniforms &uniforms [[buffer(0)]]) {
            return in.isStroke ? uniforms.strokeColor : uniforms.fillColor;
        }
        """
        
        // Create shader library
        let library: MTLLibrary
        do {
            library = try device.makeLibrary(source: shaderSource, options: nil)
        } catch {
            fatalError("Could not create shader library: \(error)")
        }
        
        // Get shader functions
        guard let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("Could not create shader functions")
        }
        
        // Create render pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create render pipeline state: \(error)")
        }
    }
    
    // MARK: - Animation Methods
    func startAnimationLoop(drawHandler: @escaping (_ p: MetalRenderer, _ frameCount: Int) -> Void) {
        self.drawHandler = drawHandler
        self.frameCount = 0
        
        // run the draw loop at 60fps
        self.animationTimer = Timer.publish(every: 1.0/60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.clear()
                self.drawHandler?(self, self.frameCount)
                self.frameCount += 1
                
                if let view = self.metalKitView {
                    view.setNeedsDisplay()
                }
            }
    }
    
    func stopAnimationLoop() {
        animationTimer?.cancel()
        animationTimer = nil
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        width = Float(size.width)
        height = Float(size.height)
        
        self.metalKitView = view
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        // Create command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        // Create render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        view.clearColor = MTLClearColor(red: Double(self.backgroundColor.x), green: Double(self.backgroundColor.y), blue: Double(self.backgroundColor.z), alpha: Double(self.backgroundColor.w))
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Draw all shapes
        for shape in shapes {
            shape.draw(encoder: renderEncoder)
        }
        
        renderEncoder.endEncoding()
        
        // Present drawable and commit command buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func clear() {
        shapes.removeAll()
    }
}

// MARK: - Transform Support
struct Transform {
    var translation: SIMD2<Float> = SIMD2<Float>(0, 0)
    var rotation: Float = 0
    var scale: SIMD2<Float> = SIMD2<Float>(1, 1)
    
    func getMatrix() -> float4x4 {
        // Convert translation to NDC space (-1 to 1)
        // In NDC space, (0,0) is the center, (-1,-1) is bottom-left, (1,1) is top-right
        let ndcX = (translation.x / 100)  // Scale down to reasonable range
        let ndcY = (translation.y / 100)  // Scale down to reasonable range
        
        // Create translation matrix
        let translationMatrix = float4x4(rows: [
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(ndcX, ndcY, 0, 1)
        ])
        
        // Create rotation matrix
        let cosA = cos(rotation)
        let sinA = sin(rotation)
        let rotationMatrix = float4x4(rows: [
            SIMD4<Float>(cosA, -sinA, 0, 0),
            SIMD4<Float>(sinA, cosA, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
        
        // Create scale matrix
        let scaleMatrix = float4x4(rows: [
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
        
        // Combine matrices in the correct order: translate * rotate * scale
        // This order means: first scale, then rotate around origin, then translate
        return translationMatrix * rotationMatrix * scaleMatrix
    }
}

