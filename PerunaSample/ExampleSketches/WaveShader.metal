//
//  WaveShader.metal
//  PerunaSample
//
//  Created by aaron on 4/9/25.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 waveGradient(float2 position, half4 currentColor, float phase, half4 color1, half4 color2) {
    float2 uv = position / float2(1000.0, 1000.0);
    
    float wave1 = sin(uv.x * 4.0 + phase) * 0.3;
    float wave2 = cos(uv.y * 3.0 + phase * 0.7) * 0.2;
    float wave3 = sin((uv.x + uv.y) * 2.0 + phase * 0.5) * 0.15;
    
    float2 distortedUV = float2(
        uv.x + sin(uv.y * 2.0 + phase) * 0.1,
        uv.y + cos(uv.x * 2.0 + phase * 0.5) * 0.1
    );
    
    float combinedWave = sin(distortedUV.x * 3.0 + wave1 + wave2 + wave3 + phase);
    
    float pattern = (sin(combinedWave * 2.0) + 1.0) * 0.5;
    pattern *= (cos(distortedUV.y * 4.0 + phase * 0.3) + 1.0) * 0.5;
    
    return mix(color1, color2, pattern) * currentColor.a;
}
