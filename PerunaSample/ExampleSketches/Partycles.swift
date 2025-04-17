//
//  LineSketch.swift
//  PerunaSample
//
//  Created by aaron on 4/10/25.
//

import SwiftUI

struct Partycles: View {
    @State var particles: [ParticleSystem] = []
    
    var body: some View {
        PerunaCanvas { p in

        } draw: { p, frameCount in
            doSomething(p, frameCount: frameCount)
        }
    }
    
    func doSomething(_ p: MetalRenderer, frameCount: Int) {
        for i in (0..<particles.count).reversed() {
            particles[i].update()
            particles[i].draw(p)
            
            if particles[i].isDead() {
                particles.remove(at: i)
            }
        }
        
        if frameCount % 10 == 0 {
            let newParticle = ParticleSystem(
                x: Float.random(in: 0...p.width),
                y: Float.random(in: 0...p.height),
                vx: Float.random(in: -1...1),
                vy: Float.random(in: -1...1),
                size: Float.random(in: 2...800),
                color: p.color(r: p.random(to: 255), g: p.random(to: 255), b: p.random(to: 255)),
                life: Float.random(in: 50...150)
            )
            particles.append(newParticle)
        }
    }
}

class ParticleSystem {
    var x: Float
    var y: Float
    var vx: Float
    var vy: Float
    var size: Float
    var color: SIMD4<Float>
    var life: Float
    var maxLife: Float
    
    init(x: Float, y: Float, vx: Float = 0, vy: Float = 0, size: Float = 5, color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1), life: Float = 100) {
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.size = size
        self.color = color
        self.life = life
        self.maxLife = life
    }
    
    func update() {
        x += vx
        y += vy
        life -= 1
    }
    
    func isDead() -> Bool {
        return life <= 0
    }
    
    func draw(_ p: MetalRenderer) {
        let alpha = (life / maxLife) * 255
        p.fill(color.r, color.g, color.b, alpha)
        p.circle(x: x, y: y, diameter: size)
    }
}

#Preview {
    Partycles()
}
