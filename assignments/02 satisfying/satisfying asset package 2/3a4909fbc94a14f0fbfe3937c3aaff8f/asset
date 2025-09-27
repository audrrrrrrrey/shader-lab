Shader "shader lab/week 2/time" {
    SubShader {
        Tags {"RenderPipeline" = "UniversalPipeline"}
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                float3 colorA = float3(0.72, 0.04, 0.30);
                float3 colorB = float3(0.00, 0.57, 0.68);

                float2 uv = i.uv;

                uv = uv * 2 - 1;
                uv *= 20;

                float x = uv.x;
                float y = uv.y;
                float c = x;

                //the x, y, z, a components of time (t/20,t,t*2, t*3)
                //constantly going up
                //just good use cases for making things fast or slow
                float t = _Time.y;
                float l = 0.5;

                //sin(t)
                //abs(sin(t))                       creates a pulse like a sin wave w neg bits flipped up
                //sin(t)*0.5+0.5                    for smooth transition btwn 0 and 1
                
                //frac(t)                           creates a sawtooth wave
                //smoothstep(0,1,sin(t)*0.5+0.5)    kinda like sin but w flattened/lingering peaks and valleys

                //min(frac(t), 1-frac(t))           creates linear oscillating

                y = lerp(colorA, colorB, min(frac(t), 1-frac(t)));
                c = frac(max(x,y) * min(x,y))
                return float4(c.rrr, 1);
            }
            ENDHLSL
        }
    }
}