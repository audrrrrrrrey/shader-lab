Shader "shader lab/week 3/homework template" {
    Properties {
        _hour   ("hour",   Float) = 0
        _minute ("minute", Float) = 0
        _second ("second", Float) = 0
    }

    SubShader {
        Tags { "RenderPipelien" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define TAU 6.283185307

            CBUFFER_START(UnityPerMaterial)
            float _hour;
            float _minute;
            float _second;
            CBUFFER_END

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
                //scaling and translation
                float2 uv = i.uv * 2 - 1;

                float time = _Time.z;
                float3 output = 0;

                //concentric circles, each circle represents an hour
                float hours = 12.;
                for (int h=1; h<=hours; h++) {

                    //warping circle uv (multiple spaces)
                    float2 circleUV = uv;
                    float warpStrength = 0.01;
                    circleUV += sin(circleUV.yy + float2(time*0.5, 1) + h/hours) * warpStrength;
                    circleUV += cos(circleUV.xx + float2(1, time*0.5) + h/hours) * warpStrength;

                    //circle
                    float radius = h/hours;
                    float distance = length(circleUV);
                    float thickness = 0.002;

                    float3 circleCol = float3(h/hours, 0.5, 0.5);
                    float circle = abs(distance - radius);
                    circle = 1 - circle/thickness;
                    // output = max((circle / thickness), output);
                    output = max(output, circle*circleCol);
                }

                //main circle, scale represents hour
                //warping main circle uv
                float2 mainCircleUV = uv;
                float warpStrength = 0.01;
                mainCircleUV += sin(mainCircleUV.yy + float2(time*0.5, 1) + _hour/hours) * warpStrength;
                mainCircleUV += cos(mainCircleUV.xx + float2(1, time*0.5) + _hour/hours) * warpStrength;

                //drawing the main circle
                float radius = frac(_hour / 12);
                float distance = length(mainCircleUV);

                float3 circleBW = sqrt(frac(_second));    //beats every second
                float3 circleCol = float3(frac(_hour/hours), 0.5, 0.5);
                float aa = 0.001;
                float circle = smoothstep(distance,distance+aa,radius);
                output += circle * circleBW * circleCol;
                

                //adding bg of pink to green gradient
                //warping bg uv, this part has nothing to do with real time
                float2 bgUV = uv;
                float bgwarpStrength = 0.5;
                bgUV *= sin(bgUV.xx + float2(time*0.5, 1) + _hour/hours) * bgwarpStrength;
                bgUV *= cos(bgUV.yy + float2(1, time*0.5) + _hour/hours) * bgwarpStrength;

                float3 waterCol = float3(bgUV.y, 0, bgUV.y) * 0.3 + 0.5;
                output += waterCol;

                return float4(output, 1.0);
            }
            ENDHLSL
        }
    }
}