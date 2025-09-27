Shader "shader lab/week 1/gradient" {
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
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

                float3 color = float3(uv.x * 5, uv.y, 0.0);     //r g b, if float4 it has alpha toos
                //color = uv.xyx;     //making color just the x component for all three; it's the same as below
                // color = float3(uv.x, uv.y, uv.x); is same as above

                
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
