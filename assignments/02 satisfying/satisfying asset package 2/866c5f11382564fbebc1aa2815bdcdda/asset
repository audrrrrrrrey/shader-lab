Shader "shader lab/week 2/satisfying" {
    Properties {
        _spaceBlend ("space blend", Range(0,1)) = 0
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define TAU 6.283185307

            CBUFFER_START(UnityPerMaterial)
            float _spaceBlend;
            CBUFFER_END

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

            float circle (float radius, float2 uv) {
                float distance = length(uv);
                distance -= radius;
                float aa = 0.005;
                return 1-smoothstep(0, aa, distance);
            }

            float4 frag (Interpolators i) : SV_Target {
                float t =_Time.y * 0.3;
                float aa = 0.5;             //anti aliasing

                float3 output = 0;
                float bw = 0;
                float3 color = float3(cos(t), cos(t), 1);

                float2 uv = i.uv;
                uv = uv * 2 - 1;
                uv *= uv;
                
                float angle = atan2(uv.y,uv.x);
                float2 polarUV = float2(angle, length(uv));

                polarUV.x = polarUV.x / TAU + 0.5;
                polarUV.y = polarUV.y / TAU + 0.5;

                float angle2 = atan2(polarUV.y, polarUV.x) * 2;
                float radius = tan(angle2 + t);
                
                bw = smoothstep(0, aa, abs(tan(radius*angle)));
                // output = smoothstep(0, aa, (tan(radius*angle)));
                output = 0.5 * abs(bw + color - 1);         //linear burn with an absolute value and dampened with 0.5

                return float4(output, 1.0);
            }
            ENDHLSL
        }
    }
}