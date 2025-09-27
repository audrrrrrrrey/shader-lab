Shader "shader lab/week 4/random 1D" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                float2 uv = i.uv;
                
                float rand = 0;

                rand = frac(sin(uv.x) * 437587.5453);     //taking sin function, making amplitude really high, and then clamping it back down to 0,1 range
                    //this weird number at the end acts like a seed
                    //whatever number is plugged into uv.x will always generate the same outcome (color)
                
                return float4(rand.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}