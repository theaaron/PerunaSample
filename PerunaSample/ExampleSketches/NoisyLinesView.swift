//
//  NoisyLinesView.swift
//  PerunaSample
//
//  Created by aaron on 2/27/25.
//

import SwiftUI

struct NoisyLinesView: View {
    let rad = 100
    @State var centerX: Float = 0
    @State var centerY: Float = 0
    let lineHeight = 25
    let numOfLines = 100
    @State var transX: [Float] = []
    @State var transY: [Float] = []
    @State var colors: [PColor] = []
    @State var ballX: Float = 0
    @State var ballY: Float = 0
    
    var body: some View {
        PerunaCanvas { p in
            centerX = p.width/2
            centerY = p.height/2
            for _ in 0..<40 {
                transX.append(p.random(from: -p.width*0.25, to: p.width))
                transY.append(p.random(from: -p.height*0.25, to: p.height))
                colors.append(p.color(r: p.random(to: 255), g: p.random(to: 255), b: p.random(to: 255)))
            }
        } draw: { p, frameCount in
            p.background(1)
            drawLines(p: p)
            for i in 0..<transX.count {
                drawDiagLines(p: p, tx: transX[i], ty: transY[i], col: colors[i], frame: Float(frameCount))
            }
        }
    }
    
    func drawLines(p: MetalRenderer) {
        let div: Float = 60
        let gridw = p.width/div
        p.stroke(20)
        for i in 0..<Int(div) {
            p.line(Float(i)*gridw + gridw/2, 0, Float(i)*gridw + gridw/2, p.height)
        }
    }
    
    func drawDiagLines(p: MetalRenderer, tx: Float, ty: Float, col: PColor, frame: Float) {
//        let noiseValue: Float = 10.0
        let noiseScale: Float = 0.2
        let noiseAmount: Float = 40
        
        let div: Float = 60
        let gridw = p.width/div
        for i in 0..<15 {
            p.stroke(color: col)
            
            let snx = p.noise(Float(i) * noiseScale, frame * noiseScale) * noiseAmount
            let sny = p.noise(Float(i) * noiseScale, (frame+1000) * noiseScale) * noiseAmount
            let snx2 = p.noise(Float(i+1000) * noiseScale, frame * noiseScale) * noiseAmount
            let sny2 = p.noise(Float(i+2000) * noiseScale, (1000) * noiseScale) * noiseAmount
            
            let x1 = Float(i)*gridw + gridw/2 + tx + snx
            let y1 = p.height/4 + Float(i)*10 + ty + sny
            let x2 = Float(i)*gridw + gridw/2 + tx + snx2
            let y2 = p.height*0.5 + Float(i)*10 + ty + sny2
            p.line(x1, y1, x2, y2)
        }
    }
}

#Preview {
    NoisyLinesView()
}
