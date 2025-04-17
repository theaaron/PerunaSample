//
//  Sketch2.swift
//  PerunaSample
//
//  Created by aaron on 4/17/25.
//
import SwiftUI

struct Sketch2: View {
    // declaring variable and constants in SwiftUI
    @State var shapeArray: [CoolShape] = []
    let numberOfShapes: Int = 10
    
    var body: some View {
        PerunaCanvas { p in
            // setup here (initialize arrays, objects, etc)
            for _ in 0..<numberOfShapes {
                let x = p.random(to: p.width)
                let y = p.random(to: p.height)
                let w = p.random(from: p.width/10, to: p.width/2)
                let h = p.random(from: p.height/10, to: p.height/2)
                
                shapeArray.append(CoolShape(x: x, y: y, width: w, height: h))
            }
            
        } draw: { p, frameCount in
            // animation goes here
            p.background(color: p.color(
                r: sin(Float(frameCount)*0.01)*255,
                g: sin(Float(frameCount)*0.02)*255,
                b: sin(Float(frameCount)*0.03)*255)
            )
            var drawRect = true
            for shape in shapeArray {
                if drawRect {
                    p.fill(p.smuRed)
                    p.stroke(p.smuBlue)
                    p.ellipse(x: shape.x, y: shape.y, width: shape.width, height: shape.height)
                    drawRect.toggle()
                } else {
                    p.fill(p.smuBlue)
                    p.stroke(p.smuRed)
                    p.rect(x: shape.x, y: shape.y, width: shape.width, height: shape.height)
                    drawRect.toggle()
                }
            }
        }
    }
}


struct CoolShape {
    let x: Float
    let y: Float
    let width: Float
    let height: Float
}

#Preview {
    Sketch2()
}
