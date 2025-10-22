Shader "shader lab/week 5/shape shifter" {
    Properties {
        _rotX ("x rotation", Range(-2,2)) = 0
        _rotY ("y rotation", Range(-2,2)) = 0
        _rotZ ("z rotation", Range(-2,2)) = 0
        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.75)) = 0.33
        _radius ("radius", Float) = 0.00001
        _morph ("morph", Range(0,2)) = 0
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define TAU 6.28318530718

            CBUFFER_START(UnityPerMaterial)
            float _rotX;
            float _rotY;
            float _rotZ;
            float _scale;
            float _displacement;
            float _radius;
            float _morph;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;

            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD0;
                float2 uv : TEXCOORD1;
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

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise (float2 uv) {       //value noise
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                float t = _Time.y;

                //half dome
                float3 p = v.vertex.xyz;

                //detecting base, cone lying on its side
                float baseZ = _radius;
                float baseThreshold = 0.01;

                if (p.z <= baseZ + baseThreshold)
                {
                    //dist from axis in xy plane
                    float r = length(p.xy);

                    //hemisphere height
                    float domeHeight = sqrt(saturate(_radius*_radius - r*r));

                    //smoothing
                    float baseBlend = saturate(1.0 - r/_radius);
                    baseBlend = baseBlend * baseBlend * (3 - 2 * baseBlend);

                    //pushing along z axis
                    _morph = sin(t) + 1;
                    p.z = domeHeight * _morph * baseBlend;
                }

                v.vertex.xyz = p;
                                

                //slight displacement for style
                v.vertex.xyz += v.normal * noise(v.uv * _scale) * _displacement;        //doing it this way ensures we stay in float3


                //rotation
                _rotY = sin(t) * 2;

                float4x4 xRot = rotation_matrix(float3(1,0,0), _rotX * TAU);
                float4x4 yRot = rotation_matrix(float3(0,1,0), _rotY * TAU);
                float4x4 zRot = rotation_matrix(float3(0,0,1), _rotZ * TAU);
                float4x4 rotation = mul(mul(xRot, yRot), zRot);
                v.vertex = mul(rotation, v.vertex);

                // //waves
                // o.worldUV = mul(unity_ObjectToWorld, v.vertex).xz * 0.02;
                // v.vertex.y += wave(o.worldUV) * _displacement;

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;      
                o.normal = v.normal;

                return o;
            }
            
            float4 frag(Interpolators i) : SV_Target
            {
                float n = noise(i.uv * _scale);
                n *= n;
                n *= n;
                float3 color = float3(220, 250, 190)/255;
                float noise_scale = 0.1;
                return float4(color + n*noise_scale, 1.0);
            }

            ENDHLSL
        }
    }
}
