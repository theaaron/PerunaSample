//
//  PerunaCanvas.swift
//  PerunaSample
//
//  Created by aaron on 3/5/25.
//

import SwiftUI
import MetalKit
import Combine

typealias PColor = SIMD4<Float>

struct PerunaCanvas: View {
    @StateObject public var p = MetalRenderer()
    let setupHandler: ((_ p: MetalRenderer) -> Void)?
    let drawHandler: ((_ p: MetalRenderer, _ frameCount: Int) -> Void)?
    
    // Main initializer that takes setup and draw handlers
    init(setup: @escaping (_ p: MetalRenderer) -> Void,
         draw: @escaping (_ p: MetalRenderer, _ frameCount: Int) -> Void) {
        self.setupHandler = setup
        self.drawHandler = draw
    }
    
    // Alternative initializer that takes just a draw handler
    init(draw: @escaping (_ p: MetalRenderer, _ frameCount: Int) -> Void) {
        self.setupHandler = nil
        self.drawHandler = draw
    }
    
    var body: some View {
        MetalView(renderer: p)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Run setup once when the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    p.clear()
                    
                    // Run setup if provided
                    setupHandler?(p)
                    
                    // If we have a draw handler, enable animation
                    if let drawHandler = drawHandler {
                        p.startAnimationLoop(drawHandler: drawHandler)
                    }
                }
            }
            .onDisappear {
                // Stop the animation when view disappears
                p.stopAnimationLoop()
            }
    }
}
