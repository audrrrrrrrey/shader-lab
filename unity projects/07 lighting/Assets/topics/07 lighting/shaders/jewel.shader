Shader "shader lab/week 7/jewel" {
    Properties {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss ("gloss", Range(0,1000)) = 1
        _bloomColor ("bloom color", Color) = (0.4, 0.1, 0.9)
        _bloom ("bloom", Range(0,100)) = 1.5
        _bloomThickness ("bloom thickness", Range(-0.5,0.5)) = -0.1
        _bloomAA ("bloom aa", Range(0,0.5)) = 0.1
        _noiseSteps ("noise steps", Int) = 4
        _specularPower ("specular power", Range(0, 1000)) = 256
        _ambientColor ("ambient color", Color) = (0.7, 0.05, 0.15)
        _noiseScale ("noise scale", Range(2, 50)) = 15.5
        _noiseDisp ("displacement", Range(-0.75, 0.75)) = 0.33
    }
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #define TAU 6.28318530718

            CBUFFER_START(UnityPerMaterial)
            float3 _surfaceColor;
            float _gloss;
            float3 _bloomColor;
            float _bloom;
            float _bloomThickness;
            float _bloomAA;
            int _noiseSteps;
            float _specularPower;
            float3 _ambientColor;
            float _noiseScale;
            float _noiseDisp;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 color : COLOR;
            };

            float4x4 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                    0.0,                                0.0,                                0.0,                                1.0);
            }

            float random (float value) {
                return frac(sin(value) * 437587.5453);
            }

            float white_noise (float2 value) {
                return frac(sin(dot(value, float2(128.239, -78.381))) * 437587.5453);
            }

            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = white_noise(ipos);
                float x  = white_noise(ipos + float2(1, 0));
                float y  = white_noise(ipos + float2(0, 1));
                float xy = white_noise(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                n += (1 / 32.0) * value_noise( uv * 16);
                
                return n;
            }

            Interpolators vert (MeshData v) {
                Interpolators o;

                // set vertex color
                o.color = v.color;
                
                // vertex displacement with noise
                v.vertex.xyz += v.normal * fractal_noise(v.uv * _noiseScale) * _noiseDisp;        //doing it this way ensures we stay in float3

                // when i tried rotating the object the lighting tracks onto it :(
                // // time
                // float t = _Time.x;

                // // create rotation matrices for each axis
                // float4x4 x = rotation_matrix(float3(1, 0, 0), sin(t) * TAU * o.color.r);
                // float4x4 y = rotation_matrix(float3(0, 1, 0), sin(t) * TAU * o.color.r);
                // float4x4 z = rotation_matrix(float3(0, 0, 1), sin(t) * TAU * o.color.r);

                // // multiply rotation matrices together to get the combined matrix
                // float4x4 rotation = mul(mul(x, y), z);

                // // multiply the object space vertex position by the rotation matrix
                // v.vertex = mul(rotation, v.vertex);

                o.vertex = TransformObjectToHClip(v.vertex);
                // o.vertexObjectSpace = v.vertex;

                o.uv = v.uv;
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float3 color = 0;
                float3 normal = normalize(i.normal);
                Light light = GetMainLight();

                //noise stuff
                float fn = fractal_noise(i.uv * _noiseScale);
                fn = frac(fn * _noiseSteps);
                fn = fn * 0.2 - 0.2;

                // blinn-phong
                // calculates "half direction" and compares it to normal 
                float3 viewDirection = normalize(GetCameraPositionWS() - i.worldPos);
                float3 halfDirection = normalize(viewDirection + light.direction);

                float diffuseFalloff = max(0, dot(normal, light.direction));
                float specularFalloff = max(0, dot(normal, halfDirection));

                specularFalloff = pow(specularFalloff, _gloss * _specularPower + 1) * _gloss * fn;
                                //this part makes the highlight tighter as it's glossier    //this makes the highlight brighter as it's glossier

                // //rounding to create bands
                // diffuseFalloff = sqrt(frac(diffuseFalloff * _diffuseLightSteps));
                // specularFalloff = sqrt(frac(specularFalloff * _specularLightSteps));

                float3 bloom = smoothstep(_bloomThickness+_bloomAA, _bloomThickness, dot(normal, viewDirection)) * _bloom * _bloomColor;
                float3 diffuse = diffuseFalloff * _surfaceColor * light.color;
                float3 specular = specularFalloff * light.color * fn;
                color = diffuse + specular + bloom + _ambientColor + fn;

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}