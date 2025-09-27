Shader "shader lab/week 4/texture mapping" {
    Properties {
       _tex ("texture", 2D) = "white" {}        //STARTEND added this part ourselves
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //START added this part ourselves
            CBUFFER_START(UnityPerMaterial)         
            float4 _tex_ST;
            CBUFFER_END

            TEXTURE2D(_tex);
            SAMPLER(sampler_tex);
            //END added this part ourselves

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
                // mesh uv
                float2 uv = i.uv;
                float3 color = 0;
                
                // color = _tex.Sample(sampler.tex, uv);            //same as below, except below is the unity version and this is the HLSL version
                color = SAMPLE_TEXTURE2D(_tex, sampler_tex, TRANSFORM_TEX(uv, _tex));       
                    //TRANSFORM_TEX is a built in Unity function that allows us to offset and tile the texture in the inspector
                
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}