Shader "shader lab/week 9/custom skybox" {
    Properties {
       [NoScaleOffset] _tex2D("2D map", 2D) = "black" {}
    }

    SubShader {
        // these tags tell unity to render the skybox in the right queue order
        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Background"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
        }
        
        Cull Off
        ZWrite Off

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_tex2D);
            SAMPLER(sampler_tex2D);
            

            struct MeshData {
                float4 vertex : POSITION;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float3 objPos : TEXCOORD0;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.objPos = v.vertex.xyz;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float3 color = 0;
                
                color = SAMPLE_TEXTURE2D_LOD(_tex2D, sampler_tex2D, i.objPos, 0);     //here's how you get the color
                                            //texture, sampler, position, level of detail (0 is clear, higher ints get blurrier)

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}