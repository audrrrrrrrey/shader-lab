Shader "shader lab/week 1/gradient exercise" {
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
                // float3 color = 0;

                // add your code here
                float3 colorA = float3(200, 0, 0)/255;
                float3 colorB = float3(0, 200, 200)/255;
                float3 colorC = float3(0, 200, 0)/255;
                float3 colorD = float3(0, 0, 200)/255;
                float3 colorF = float3(uv.x, uv.y, uv.x);

                float3 lerp1 = lerp(colorA, colorB, uv.x);
                float3 lerp2 = lerp(colorC, colorD, uv.x);


                float3 color = colorF/colorA;
                color = colorF;
                color = lerp2;
                color = lerp(lerp1, lerp2, uv.y);

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
