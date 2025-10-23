Shader "shader lab/week 8/transparency" {
    Properties {
        _color ("color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"     //this changes the render queue from 2000 to 3000
            "IgnoreProjector" = "True"  //not as critical, ignores textures projected onto objects
        }

        ZWrite Off      //turning off depth (Z) buffer aka overriding things occluded bc they're farther away

        // alpha blending - the most common blend mode we'll be using
        // source = this shader's color output
        // destination = the color in the frame buffer (frame buffer means what's already been rendered)
        // final color = (source color * source factor) + (destination color * destination factor)
        // final color = (this shader's color * this shader's alpha output) + (frame buffer color * (1 - this shader's alpha output))
        Blend SrcAlpha OneMinusSrcAlpha
            //^source factor  //^destination factor
        
        // additive blending would look like this
        // Blend One One
        
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _color;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                return _color;
            }
            ENDHLSL
        }
    }
}