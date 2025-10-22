﻿Shader "shader lab/week 5/vertex displacement" {
    Properties {
        _scale ("noise scale", Range(2, 50)) = 15.5
        _displacement ("displacement", Range(0, 0.75)) = 0.33
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
            float _displacement;
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

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                
                return n;
            }

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                
            };

            Interpolators vert (MeshData v) {
                Interpolators o;

                v.vertex.xyz += v.normal * fractal_noise(v.uv * _scale) * _displacement;        //doing it this way ensures we stay in float3
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;        
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float fn = fractal_noise(i.uv * _scale);
                return float4(fn.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}