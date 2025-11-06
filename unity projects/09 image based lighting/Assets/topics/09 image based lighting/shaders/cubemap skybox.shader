Shader "shader lab/week 9/cubemap skybox" {
    Properties {
       [NoScaleOffset] _texCube("cube map", Cube) = "black" {}
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

            TEXTURECUBE(_texCube);
            SAMPLER(sampler_texCube);
            

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
                
                color = SAMPLE_TEXTURECUBE_LOD(_texCube, sampler_texCube, i.objPos, 0);     //here's how you get the color
                                            //texture, sampler, position, level of detail (0 is clear, higher ints get blurrier)

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}