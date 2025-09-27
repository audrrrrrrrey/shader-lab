Shader "shader lab/week 3/rotate" {
    SubShader {
        Tags { "RenderPipeline" = "UnivesalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define TAU 6.283185307

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }

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
                float2 uv = i.uv * 2 - 1;
                float time = _Time.x * 8;
                
                float3 color = 0;

                //rotation
                float angle = frac(time) * TAU;       //range [0,1) --> range [0, 2pi)
                float s = sin(angle);
                float c = cos(angle);

                //matrix
                //represent a change of coordinate systems
                //they are what they are? literally a mathematical concept
                float2x2 rotate2D = float2x2(
                    c,  -s,
                    s,  c
                );

                //multiplying it all together
                uv = mul(rotate2D, uv);     //can't just say uv *= rotate2D for this kind of multiplication
                    //convention is to put matrix first, vector second

                    
                //just to visualize the coord system
                color = rectangle(uv, float2(0.25, 0.5));
                color += float3(uv.x, 0, uv.y);
                
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
