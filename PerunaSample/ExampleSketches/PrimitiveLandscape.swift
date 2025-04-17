//
//  PrimitiveLandscape.swift
//  PerunaSample
//
//  Created by aaron on 4/9/25.
//
import SwiftUI

struct PrimitiveLandscape: View {
    @State var ellSize: Float = 0
    
    var body: some View {
        PerunaCanvas { p in
            ellSize = p.width/15
        } draw: { p, frameCount in
            p.background(color: p.color(cos(Float(frameCount)*0.02)*60, 20, sin(Float(frameCount)*0.02)*60))
            drawBG(p: p, frameCount: frameCount)
            drawGrass(p: p, frameCount: frameCount, xOff: 0)
        }

    }
    
    
    func drawBG(p: MetalRenderer, frameCount: Int) {
        let gridW = p.width/ellSize
        let gridH = p.height/ellSize
        for i in 0..<Int(gridW) {
            for j in 0...Int(gridH+1) {
                let noiseFactor: Float = 30
                let noiseAmount = p.noise2(Float(i) * noiseFactor, Float(j) * noiseFactor, Float(frameCount)*0.01)

                let r = p.map(noiseAmount, from: 0, to: 1, from: 15, to: 60)
                let g = p.map(noiseAmount, from: 0, to: 1, from: 15, to: 50)
                let b = p.map(noiseAmount, from: 0, to: 1, from: 50, to: 100)
                
                p.fill(r, g, b)
                p.ellipse(x: Float(i)*ellSize + (ellSize/2), y: Float(j)*ellSize + (ellSize/2), width: ellSize*2, height: ellSize*2)
            }
        }
    }
    
    func drawGrass(p: MetalRenderer, frameCount: Int, xOff: Float) {
        let gridW = p.width/ellSize
        let gridH = p.height/ellSize
        for i in 0..<Int(gridW) {
            for j in 0...Int(gridH/2.5) {
                let noiseFactor: Float = 30
                let noiseAmount = p.noise2(Float(i) * noiseFactor, Float(j) * noiseFactor, Float(frameCount))
                let rNoiseVal = p.noise2(Float(i) * noiseFactor, Float(j) * noiseFactor, Float(frameCount+500))
                let gNoiseVal = p.noise2(Float(i) * noiseFactor, Float(j) * noiseFactor, Float(frameCount+1000))
                let bNoiseVal = p.noise2(Float(i) * noiseFactor, Float(j) * noiseFactor, Float(frameCount+1500))

                var r = p.map(rNoiseVal, from: 0, to: 1, from: 20, to: 60)
                var g = p.map(gNoiseVal, from: 0, to: 1, from: 40, to: 150)
                var b = p.map(bNoiseVal, from: 0, to: 1, from: 20, to: 40)
                
                let offset = p.map(noiseAmount, from: 0, to: 1, from: 0, to: p.width/5)
                
                p.fill(r, g, b)
                r = p.map(rNoiseVal, from: 0, to: 1, from: 0, to: 255)
                g = p.map(gNoiseVal, from: 0, to: 1, from: 0, to: 255)
                b = p.map(bNoiseVal, from: 0, to: 1, from: 0, to: 255)
                p.stroke(b, g, r)
                let yVal = (Float(j) * ellSize)
                p.ellipse(x: Float(i)*ellSize + (ellSize/2),
                          y: p.height - yVal + offset,
                          width: ellSize*2,
                          height: ellSize*2
                )
            }
        }
    }
    
}


//#Preview {
//    PrimitiveLandscape()
//}
