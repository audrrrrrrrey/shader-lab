Shader "shader lab/week 4/value noise 1D" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float rand (float v) {
                return frac(sin(v) * 43758.5453123);
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
                float2 uv = i.uv;
                float vn = 0;
                uv *= 20;
                
                float ipos = floor(uv.x);       //initial position blend between
                float fpos = frac(uv.x);        //final position to blend between

                //percent
                float percent = fpos;           //our "gradient driver", in range 0 to 1, so we can blend in each section
                percent = smoothstep(0, 1, percent);      //without this line, the transition is purely linear, so peaks and valleys are sharp

                vn = lerp(rand(ipos), rand(ipos+1), percent);       //blending between
                
                return float4(vn.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}