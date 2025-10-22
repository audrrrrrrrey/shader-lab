Shader "shader lab/week 6/poppy leaves" {
    Properties {
        _displacement ("displacement", Range(0, 0.1)) = 0.0001
        _timeScale ("time scale", Float) = 5
        _waveDisp ("wave displacement", Range(0, 0.3)) = 0.05
        _waveFreq ("wave frequency", Range(2, 100)) = 15.5
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
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
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

                //wave leaves
                // v.vertex.y += wave(v.uv) * _waveDisp * v.color.xyz;
                v.vertex.xz += sin(_Time.z * _waveTimeScale) * sqrt(v.uv.x) * sin(v.uv.x) * _waveDisp * v.color.xyz;

                //give a jitter
                v.vertex.xyz += normalize(rand_vec(v.vertex.xyz + round(_Time.y * _timeScale))) * _displacement;  

                o.vertex = TransformObjectToHClip(v.vertex);
                o.color = v.color;
                o.uv = v.uv;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                return float4(i.color.rgb, 1.0);
            }

            ENDHLSL
        }
    }
}