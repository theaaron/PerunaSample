//
//  ContentView.swift
//  PerunaSample
//
//  Created by aaron on 2/24/25.
//
import SwiftUI
import MetalKit

// MARK: - Start Here!

struct Sketch: View {
    // declare variable and constants in SwiftUI
    
    var body: some View {
        PerunaCanvas { p in
            // setup here (initialize arrays, objects, etc)
            
        } draw: { p, frameCount in
            // giving a background color with p.background
            // you can use 1, or 3 arguments. 1 argument will
            // provide you with a gray color, 3 arguments will
            // let you choose the red, green, and blue values
            p.background(color: p.color(
                r: sin(Float(frameCount)*0.01)*255,
                g: sin(Float(frameCount)*0.02)*255,
                b: sin(Float(frameCount)*0.03)*255
                )
            )
            // draw a rectangle, give colors to the outline with stroke()
            // and fill it with color with p.fill()
            // smuRed and smuBlue are easy to use built-in colors
            // meant for quick prototyping
            p.fill(p.smuRed)
            p.stroke(p.smuBlue)
            p.rect(
                x: p.width/2,
                y: p.height/2,
                width: p.width/2,
                height: p.height/2 )
            
            // draw an ellipse, give colors to the outline with stroke()
            // and fill it with color with p.fill()
            p.fill(p.smuBlue)
            p.stroke(p.smuRed)
            p.ellipse(
                x: p.width/2,
                y: p.height/4,
                width: p.width/3,
                height: p.width/3 )
        }
    }
}

#Preview {
    Sketch()
}

