Shader "shader lab/week 2/shaping" {
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
                float2 uv = i.uv;

                float x = uv.x;
                float y = uv.y;

                float c = x;

                //c = sin(x);       //repeating gradients
                //c = cos(x);
                //c = abs(x);       //creates thin black band w soft edges in ccenter
                //c = ceil(x);      //creates half black half white w transition at 0 point
                //c = floor(x);     //creates half black half white w transition at 1 point
                //c = frac(x);      //creates repeating gradients since intger is truncated
                //c = min(x, y);    //separates into 4 quadrants w 3 black, 1 white
                //c = sign(x);      //same as ceil
                //c = step(x, y);   //diagnoal
                //c = smoothstep(0, 0.1, x)     //good way to define where gradient starts and ends
            
                c = frac(max(x,y)*min(x,y));
                //c = frac(max(x,y)*min(x,y)) / (frac(max(y,x))* frac(max(y,x));
                //c = frac(max(y,x)*frac(x,y));

                //c = frac(max(x,y)) * frac(min(x,y));
                //c = frac(max(y,x)) * frac(max(y,x));

                //c.rrr is taking the r channel three times bc r is the only channel for a float (not a float3)
                //same as c.xxx
                //treated as colors and vectors interchangeably

                return float4(c.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}