//
//  Renderer+.swift
//  PerunaSample
//
//  Created by aaron on 2/27/25.
//
import MetalKit
import SwiftUI

extension MetalRenderer {
    // p5 functions
    func color(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 255) -> SIMD4<Float> {
        return simd_float4(r/255, g/255, b/255, a/255)
    }
    
    func color(r: Float, g: Float, b: Float, a: Float = 255) -> SIMD4<Float> {
        return simd_float4(r/255, g/255, b/255, a/255)
    }
    
    func fill(_ color: SIMD4<Float>) {
        self.fillColor = color
    }
    
    func fill(r: Float, g: Float, b: Float, a: Float = 255) {
        self.fillColor = color(r: r, g: g, b: b, a: a)
    }
    
    func fill(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 255) {
        self.fillColor = color(r: r, g: g, b: b, a: a)
    }
    
    func fill(_ gray: Float, _ a: Float = 255) {
        self.fillColor = color(r: gray, g: gray, b: gray, a: a)
    }
    
    func stroke(color: SIMD4<Float>) {
        self.strokeColor = color
    }
    
    func stroke(_ color: SIMD4<Float>) {
        self.strokeColor = color
    }
    
    func stroke(r: Float, g: Float, b: Float, a: Float = 255) {
        self.strokeColor = color(r: r, g: g, b: b, a: a)
    }
    
    func stroke(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 255) {
        self.strokeColor = color(r: r, g: g, b: b, a: a)
    }
    
    func stroke(_ gray: Float, _ a: Float = 255) {
        self.strokeColor = color(r: gray, g: gray, b: gray, a: a)
    }
    
    func random(from num1: Float = 0, to num2: Float) -> Float {
        return Float.random(in: (num1...num2))
    }
    
    func background(color: SIMD4<Float>) {
        self.backgroundColor = color
    }
    
    func background(r: Float, g: Float, b: Float, a: Float = 255) {
        self.backgroundColor = color(r: r, g: g, b: b, a: a)
    }
    
    func background(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 255) {
        self.backgroundColor = color(r: r, g: g, b: b, a: a)
    }
    
    func background(_ gray: Float, _ a: Float = 255) {
        self.backgroundColor = color(r: gray, g: gray, b: gray, a: a)
    }
    
    func map(_ value: Float, from start1: Float, to stop1: Float, from start2: Float, to stop2: Float, clamp: Bool = false) -> Float {
        let normalizedValue = (value - start1) / (stop1 - start1)
        
        var result = start2 + normalizedValue * (stop2 - start2)
        
        if clamp {
            if start2 < stop2 {
                result = Swift.max(start2, Swift.min(result, stop2))
            } else {
                result = Swift.max(stop2, Swift.min(result, start2))
            }
        }
        
        return result
    }
    
    // MARK: - Noise Functions
    
    /// Returns a noise value between 0 and 1 for a given coordinate
    /// - Parameters:
    ///   - x: x-coordinate in noise space
    ///   - y: y-coordinate in noise space (optional)
    ///   - z: z-coordinate in noise space (optional)
    /// - Returns: A value between 0 and 1
    func noise(_ x: Float, _ y: Float = 0, _ z: Float = 0) -> Float {
        // Scale the input coordinates to get more variation
        let scale: Float = 0.01
        
        // Get the noise value
        let value = perlinNoise(x * scale, y * scale, z * scale)
        
        // Normalize to 0-1 range
        return (value + 1) * 0.5
    }

    // MARK: - Perlin Noise Implementation
    
    private func perlinNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        // Permutation table
        let p = [
            151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
            190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,
            125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,
            105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,
            135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,
            82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,
            153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,
            251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,
            157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,
            66,215,61,156,180
        ]
        
        // Fade function
        func fade(_ t: Float) -> Float {
            return t * t * t * (t * (t * 6 - 15) + 10)
        }
        
        // Gradient function
        func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
            let h = hash & 15
            let u = h < 8 ? x : y
            let v = h < 4 ? y : h == 12 || h == 14 ? x : z
            return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
        }
        
        // Get integer parts and ensure they're in range
        let xi = Int(x) & 255
        _ = Int(y) & 255
        _ = Int(z) & 255
        
        // Get fractional parts
        let xf = x - Float(Int(x))
        let yf = y - Float(Int(y))
        let zf = z - Float(Int(z))
        
        // Fade curves
        let u = fade(xf)
        let v = fade(yf)
        let w = fade(zf)
        
        // Hash coordinates and ensure they're in range
        let A = p[xi] & 255
        let AA = p[A] & 255
        let AB = p[A + 1] & 255
        let B = p[xi + 1] & 255
        let BA = p[B] & 255
        let BB = p[B + 1] & 255
        
        // Blend results
        let result = lerp(
            lerp(
                lerp(grad(p[AA], xf, yf, zf), grad(p[BA], xf-1, yf, zf), u),
                lerp(grad(p[AB], xf, yf-1, zf), grad(p[BB], xf-1, yf-1, zf), u),
                v
            ),
            lerp(
                lerp(grad(p[AA+1], xf, yf, zf-1), grad(p[BA+1], xf-1, yf, zf-1), u),
                lerp(grad(p[AB+1], xf, yf-1, zf-1), grad(p[BB+1], xf-1, yf-1, zf-1), u),
                v
            ),
            w
        )
        
        return result
    }
    
    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + t * (b - a)
    }
    
    func noise2(x: Float, y: Float, z: Float = 0) -> Float {
        let n = PerlinNoise()
        return n.noise(x, y, z)
    }
    
    func noise2(_ x: Float, _ y: Float, _ z: Float = 0) -> Float {
        let n = PerlinNoise()
        return n.noise(x, y, z)
    }
    
    class PerlinNoise {
        // MARK: - Public Interface
        
        /// Generates Perlin noise for the given coordinates
        /// - Parameters:
        ///   - x: X coordinate
        ///   - y: Y coordinate (optional, default 0)
        ///   - z: Z coordinate (optional, default 0)
        /// - Returns: Noise value in range 0...1
        func noise(_ x: Float, _ y: Float = 0, _ z: Float = 0) -> Float {
            // Scale the input coordinates to get more variation
            let scale: Float = 0.01
            
            // Get the noise value
            let value = perlinNoise(x * scale, y * scale, z * scale)
            
            // Normalize to 0-1 range
            return (value + 1) * 0.5
        }
        
        // MARK: - Perlin Noise Implementation
        
        private func perlinNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
            // Permutation table
            let p = [
                151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
                190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,
                125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,
                105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,
                135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,
                82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,
                153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,
                251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,
                157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,
                66,215,61,156,180
            ]
            
            // Create a permutation table with 512 values to avoid indexing issues
            var perm = [Int](repeating: 0, count: 512)
            for i in 0..<256 {
                perm[i] = p[i]
                perm[i + 256] = p[i]
            }
            
            // Fade function
            func fade(_ t: Float) -> Float {
                return t * t * t * (t * (t * 6 - 15) + 10)
            }
            
            // Gradient function
            func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
                let h = hash & 15
                let u = h < 8 ? x : y
                let v = h < 4 ? y : (h == 12 || h == 14) ? x : z
                return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
            }
            
            // Get integer parts and ensure they're in range
            let xi = Int(floor(x)) & 255
            let yi = Int(floor(y)) & 255
            let zi = Int(floor(z)) & 255
            
            // Get fractional parts
            let xf = x - floor(x)
            let yf = y - floor(y)
            let zf = z - floor(z)
            
            // Fade curves
            let u = fade(xf)
            let v = fade(yf)
            let w = fade(zf)
            
            // Hash coordinates
            let aaa = perm[perm[perm[xi] + yi] + zi]
            let aba = perm[perm[perm[xi] + yi + 1] + zi]
            let aab = perm[perm[perm[xi] + yi] + zi + 1]
            let abb = perm[perm[perm[xi] + yi + 1] + zi + 1]
            let baa = perm[perm[perm[xi + 1] + yi] + zi]
            let bba = perm[perm[perm[xi + 1] + yi + 1] + zi]
            let bab = perm[perm[perm[xi + 1] + yi] + zi + 1]
            let bbb = perm[perm[perm[xi + 1] + yi + 1] + zi + 1]
            
            // Blend results
            let x1 = lerp(
                grad(aaa, xf, yf, zf),
                grad(baa, xf - 1, yf, zf),
                u
            )
            let x2 = lerp(
                grad(aba, xf, yf - 1, zf),
                grad(bba, xf - 1, yf - 1, zf),
                u
            )
            let y1 = lerp(x1, x2, v)
            
            let x3 = lerp(
                grad(aab, xf, yf, zf - 1),
                grad(bab, xf - 1, yf, zf - 1),
                u
            )
            let x4 = lerp(
                grad(abb, xf, yf - 1, zf - 1),
                grad(bbb, xf - 1, yf - 1, zf - 1),
                u
            )
            let y2 = lerp(x3, x4, v)
            
            let result = lerp(y1, y2, w)
            
            return result
        }
        
        private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
            return a + t * (b - a)
        }
        
        // Helper function to ensure we get the correct floor value
        // (Swift's floor behaves differently than some other languages for negative numbers)
        private func floor(_ x: Float) -> Float {
            return Float(Int(x) - (x < 0 && x != Float(Int(x)) ? 1 : 0))
        }
    }
}
