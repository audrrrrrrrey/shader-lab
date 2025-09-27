Shader "shader lab/week 2/shapes" {
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
                float2 uv = i.uv * 2 - 1;
                float shape = 0;
                
                //circle
                float radius = 0.5;                 
                float distance = length(uv);        //treating uv as vector from origin
                distance -= radius;                 //*can also get rid of this and directly compare dist and radius in step
                shape = distance;                   //this creates a signed distance field (SDF)

                float cutoff = step(0, distance);
                //cutoff = step(distance, radius);      //*like here

                float aa = 0.01;        //anti aliasing
                cutoff = smoothstep(0, aa, distance);

                shape = cutoff;

                

                //rectangle
                float2 hSize = float2(0.5, 0.25);       //half size
                float leftSide = step(-hSize.x, uv.x);
                float rightSide = 1-step(hSize.x, uv.x);
                float bottomSide = step(-hSize.y, uv.y);
                float topSide = 1-step(hSize.y, uv.y);

                shape = topSide * bottomSide * rightSide * leftSide;


                //right triangle
                float s = 0.5;
                float hypotenuse = step(uv.y, ux.x);
                float bottom = step(-s, uv.y);
                float right = 1-step(s, uv.x);

                shape = hypotenuse * bottom * right;
                
                return float4(shape.rrr, 1.0);
            }
            ENDHLSL
        }
    }
}
