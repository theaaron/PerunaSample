//
//  SIMD4Float+.swift
//  PerunaSample
//
//  Created by aaron on 4/9/25.
//


extension SIMD4<Float> {
    var r: Float {
        return self.x * 255
    }
    var g: Float {
        return self.y * 255
    }
    var b: Float {
        return self.z * 255
    }
    var a: Float {
        return self.w * 255
    }
    
    var rInt: Int {
        return Int(self.x*255)
    }
    var gInt: Int {
        return Int(self.y*255)
    }
    var bInt: Int {
        return Int(self.z*255)
    }
    var aInt: Int {
        return Int(self.w*255)
    }
}