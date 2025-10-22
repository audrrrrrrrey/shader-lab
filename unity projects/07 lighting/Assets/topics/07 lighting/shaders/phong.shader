Shader "shader lab/week 7/phong" {
    Properties {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss ("gloss", Range (0, 1)) = 1 //smoothness of surface
    }
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #define MAX_SPECULAR_POWER 256      //changing this changes size of the reflective highlights
            
            CBUFFER_START(UnityPerMaterial)
            float3 _surfaceColor;
            float _gloss;
            CBUFFER_END
    
            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.normal = TransformObjectToWorldNormal(v.normal);

                // two ways to write the same thing
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float3 color = 0;

                float3 normal = normalize(i.normal);
                Light light = GetMainLight();
                
                float diffuseFalloff = max(0, dot(normal, light.direction));

                float3 viewDirection = normalize(GetCameraPositionWS() - i.worldPos);               //WS is world space
                float3 lightReflectionDirection = normalize(reflect(-light.direction, normal));     //first parameter is light direction TOWARDS object (so negative), second parameter is normal of surface you're reflecting off of
                    //this should already be normalized but just to be explicitt...
                float specularFalloff = max(0, dot(lightReflectionDirection, viewDirection));       //clamping the range to (0, 1) again, like we did in lambert, since negative means nothing
                specularFalloff = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 1) * _gloss;   //we add 1 inside here so we never get an exponent of 0

                float3 diffuse = diffuseFalloff * _surfaceColor * light.color;
                float3 specular = specularFalloff * light.color;
                color = diffuse + specular;

                return float4(color, 1);
            }
            ENDHLSL
        }
    }
}