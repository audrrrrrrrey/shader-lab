Shader "shader lab/week 6/poppy" {
    Properties {
        _displacement ("displacement", Range(0, 0.1)) = 0.0001
        _timeScale ("time scale", Float) = 5
        _waveDisp ("wave displacement", Range(0, 0.3)) = 0.0001
        _waveFreq ("wave frequency", Range(2, 100)) = 5
        _waveTimeScale ("wave time scale", Float) = 5
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _displacement;
            float _timeScale;
            float _waveDisp;
            float _waveFreq;
            float _waveTimeScale;
            CBUFFER_END

            struct MeshData {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float3 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float3 rand_vec (float3 pos) {
                return float3(rand(pos.xz), rand(pos.yx), rand(pos.zy)) * 2 - 1;        //getting random vector
            }

            //tweaked from 05 arbitrary data shader
            float wave (float2 uv) {
                // simple sin wave 0-1 with scale adjustment and time animation
                float wave1 = sin(((uv.x + uv.y) * _waveFreq) + _Time.z) * 0.5 + 0.5;

                // using cos and sin with different uv relationships and time and scale modifiers. 0-2 range
                float wave2 = (cos(((uv.x - uv.y) * _waveFreq/2.568) + _Time.z) + 1) * sin(_Time.x * 5.2321 + (uv.x * uv.y)) * 0.5 + 0.5;
                
                // dividing by 3 to make 0-1 range
                return (wave1 + wave2) / 3;
            }

            Interpolators vert (MeshData v) {
                Interpolators o;

                //get world pos
                o.worldPos = mul(unity_ObjectToWorld, v.vertex) * 0.02;

                float3 disp = o.worldPos;

                //wave back and forth
                v.vertex.x += sin(_Time.z * _waveTimeScale) * sqrt(disp.y) * _waveDisp * v.color.xyz;
                v.vertex.y += sin(_Time.z * _waveTimeScale) * sqrt(disp.y) * _waveDisp * v.color.xyz;
                v.vertex.z += cos(_Time.z * _waveTimeScale) * sqrt(disp.y) * _waveDisp * v.color.xyz;


                //give a jitter
                v.vertex.xyz += normalize(rand_vec(v.vertex.xyz + round(_Time.y * _timeScale))) * _displacement;   

                o.vertex = TransformObjectToHClip(v.vertex);
                o.color = v.color;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                return float4(i.color.rgb, 1.0);
            }

            ENDHLSL
        }
    }
}