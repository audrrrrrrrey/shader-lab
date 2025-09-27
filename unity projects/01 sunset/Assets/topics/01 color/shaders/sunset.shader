Shader "shader lab/homework/assignment 1" {
    Properties {
        
    }
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
                // you only need to work inside of this function
                
                float2 uv = i.uv;
                float4 output = 0;

                // defining colors
                float3 skyColor1 = float3(250, 150, 150)/255;
                float3 skyColor2 = float3(100, 100, 250)/255;
                float3 seaColor = float3(230, 160, 110)/255;
                float3 sunColor = float3(220, 80, 12)/255;
                float3 sandColor = float3(245, 200, 150)/255;

                float4 sunGlowColor = float4(100, 50, 0, 0.2)/255;

                // making sky
                float skySeaMask = step(0.3, uv.y);
                float skyGradientBW = smoothstep(0.2, 0.6, uv.y);
                float3 skyGradientCol = 0;
                skyGradientCol = lerp(skyColor1, skyColor2, skyGradientBW);

                // making sea
                float3 seaGradient = 0;
                seaGradient = pow(seaColor, uv.y*4);
                
                // flattening sky and sea
                float3 skySea = skySeaMask * skyGradientCol + (1 - skySeaMask) * seaGradient;
                
                // making sand
                float sandMask = step(uv.y*10, pow(cos(uv.x),2));

                // sun
                float sunMaskBlur = (smoothstep(0.58, 0.62, uv.y) - smoothstep(0.68, 0.72, uv.y)) * (smoothstep(0.63, 0.67, uv.x) - smoothstep(0.73, 0.77, uv.x));
                float sunMask = (step(0.6, uv.y) - step(0.7, uv.y)) * (step(0.65, uv.x) - step(0.75, uv.x));

                float3 sun = sunMask * sunColor;
                float4 sunGlow = sunMaskBlur * sunGlowColor;

                // final output
                float3 bg = skySea * (1-sandMask) + sandColor * (sandMask);
                output = float4(bg + sun, 1.0) + sunGlow; 

                return output;
            }

            // TEMPLATE CODE FOR REFERENCE
            // float4 frag (Interpolators i) : SV_Target {
            //     // you only need to work inside of this function
                
            //     float2 uv = i.uv; // values between 0 - 1 that you can think of as a percent of the way across either dimension on our quad.

            //     // template code
            //     // here are some example colors defined to get started with. you should modify these and add more of your own.
            //     // the standard value range for colors is 0 - 1, below i've defined colors using values between 0-255, but then divide the whole color by 255, making them 0-1 range
            //     // i do this to more easily define colors that i can create and preview in applications like photoshop which displays color values 0 - 255 (because they are natively 8 bits per channel)
            //     float3 color1 = float3(219, 70, 70)/255;
            //     float3 color2 = float3(234, 211, 150)/255;

            //     // though not necessary, using the smoothstep function is an easy way to define the boundaries of your gradient.
            //     // this gradient driving value will be 0 below 32% of the quad height and will be 1 above 50% of the quad height.
            //     float gradient1Driver = smoothstep(0.32, 0.5, uv.y);

            //     // here i'm just declaring the color variable you'll use to collect color calculations and will be your final output;
            //     float3 output = 0;

            //     // this is just an example of how to use the smoothstep gradient driver calculation to blend between the two colors.
            //     // you will need to create many more blends of colors and will need to decide how you ultimately want to blend them all together using math.
            //     output = lerp(color1, color2, gradient1Driver);
                
            //     return float4(output, 1.0);
            // }
            ENDHLSL
        }
    }
}
