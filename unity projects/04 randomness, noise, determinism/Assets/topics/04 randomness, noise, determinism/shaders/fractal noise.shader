﻿Shader "shader lab/week 4/fractal noise" {
    Properties {
        _scale ("noise scale", Range(2, 100)) = 50  
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _scale;
            CBUFFER_END

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
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
                float2 uv = i.uv * _scale;

                float fn = 0;

                float f1 = (1 / 2.0) * value_noise(uv * 1);
                float f2 = (1 / 4.0) * value_noise(uv * 2);
                float f3 = (1 / 8.0) * value_noise(uv * 4);
                float f4 = (1 / 16.0) * value_noise(uv * 8);
                fn = f1 + f2 + f3 + f4;
                fn = fn * 0.3 - 0.1;        //changing the dynamic range
                
                return float4(fn.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}