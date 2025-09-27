Shader "shader lab/week 4/value noise 2D" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
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
                float2 uv = i.uv;

                float vn = 0;

                uv *= 10;
                float2 ipos = floor(uv);
                float2 fpos = frac(uv);

                //visualize a square where the corners are
                //x     xy
                //
                //o     x
                //rand takes in a float2 and returns a float using dot product
                float o = rand(ipos);                   //this is equivalent to (ipos.x+0, ipos.y+0)
                float x = rand(ipos + float2(1,0));     //this is equivalent to (ipos.x+1, ipos.y)
                float y = rand(ipos + float2(0,1));
                float xy = rand(ipos + 1);     //same as rand(ipos + float2(1,1))

                //our gradient driver
                float2 smooth = smoothstep(0, 1, fpos);

                //now to blend the blends! (bilinear interpolation) 
                    //similar to how you'd get a 4-cornered gradient
                vn = lerp(lerp(o, x, smooth.x), lerp(y, xy, smooth.x), smooth.y);
                
                return float4(vn.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}