Shader "shader lab/week 5/vertex animation" {
    Properties {
        _frequency ("frequency", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.1)) = 0.05
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _frequency;
            float _displacement;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;          //this is how we're accessing data from the mesh
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float disp : TEXCOORD1;         //you can safely use up to 8 of these, we're defining them here to each grab different types of data (uv, diplacement)
                                                //GPU hardware function that runs to figure out where fragment is given three vertices
            };

            Interpolators vert (MeshData v) {
                Interpolators o;

                o.disp = sin(((v.uv.x + v.uv.y) * _frequency) + _Time.z) * 0.5 + 0.5;

                v.vertex.xyz += v.normal * o.disp * _displacement;

                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;        //o is the output, v is the data for an exact vertex
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float3 color = float3(i.uv.x, i.disp, i.uv.y);      //playing with shading according to vertex displacement
                color = float3(i.uv.x, 0, i.uv.y);
                color *= i.disp;
                color = color * 0.5 + 0.5;
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}