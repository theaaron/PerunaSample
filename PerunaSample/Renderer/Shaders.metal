//
//  Shaders.metal
//  asdf
//
//  Created by aaron on 3/31/25.


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
