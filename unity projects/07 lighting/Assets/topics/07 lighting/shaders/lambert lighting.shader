Shader "shader lab/week 7/lambert" {
    Properties {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
    }
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"    //this is new

            CBUFFER_START(UnityPerMaterial)
            float3 _surfaceColor;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.normal = TransformObjectToWorldNormal(v.normal);  //normals should be in world space so light spot doesn't rotate with object
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float3 color = 0;

                // with lighting library, don't need this
                // float3 lightDirection = normalize(-1);      //same as normalize(float3(-1, -1, -1))
                // color = dot(i.normal, lightDirection);

                // can instead do this
                Light light = GetMainLight();
                float falloff = dot(normalize(i.normal), light.direction);      //we normalize the normals so all of them are the same length
                falloff = max(0, falloff);      //just a way of moving the range from (-1, 1) to (0, 1) because negatives don't matter
                    //we do this instead of saturate (falloff) because sometimes we want a light intensity greater than 1, for bloom

                color = light.color * _surfaceColor * falloff;

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}