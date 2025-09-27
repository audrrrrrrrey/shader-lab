﻿Shader "shader lab/week 1/color blending" {
    Properties {
        _color1 ("color one", Color) = (1, 0, 0, 1)
        _color2 ("color two", Color) = (0, 0, 1, 1)
    }
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float3 _color1;
            float3 _color2;
            CBUFFER_END
            
            float circle (float2 uv, float2 offset, float size) {
                return smoothstep(0.0, 0.01, 1 - length(uv - offset) / size);
            }

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float2 uv = i.uv * 2 - 1;
                float3 base  = circle(uv, float2(0.0, -0.3), 0.5) * _color1;
                float3 blend = circle(uv, float2(0.0,  0.3), 0.5) * _color2;
                
                float3 color = float3(base.r, blend.g, 0);
                //same as color = base + blend, since when u add (1,0,0) and (0,1,0) together you get (1,1,0)

                color = base / blend;
                color = base - blend;
                color = base * blend;
                color = base + blend;
                
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
