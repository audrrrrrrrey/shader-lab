Shader "shader lab/week 4/natural" {
    Properties {
        [NoScaleOffset] _tex ("texture", 2D) = "white"{}
        _scale ("noise scale", Range(2, 30)) = 15.5
        _wavesScale ("waves noise scale", Range(2, 100)) = 50  
        _intensity ("noise intensity", Range(0.001, 0.05)) = 0.006
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _scale;
            float _wavesScale;
            float _intensity;
            CBUFFER_END

            TEXTURE2D(_tex);
            SAMPLER(sampler_tex);
            
            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float value_noise (float2 uv) {
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

            float circle (float radius, float aa, float2 uv) {
                float distance = length(uv);
                distance -= radius;
                return 1-smoothstep(0, aa, distance);
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
                uv = uv * 2 - 1;
                float3 color = 0;
                
                //time
                float time = 0;
                time = _Time.x;

                /*
                 sample value noise at uv + time
                 scale coordinates to scale noise output
                 subtract 0.5 for a range between -0.5 and 0.5
                 multiply by _intensity
                */
                float n = (value_noise((uv + time) * _scale) - 0.5) * _intensity;

                // add our noise value to our uv coordinates
                uv += n;


                //color palette
                float3 aqua = float3(30, 250, 220)/255;
                float3 darkAqua = float3(0, 200, 170)/255;
                float3 sky = float3(10, 150, 240)/255;
                float3 darkSky = float3(0, 130, 220)/255;
                float3 maroon = float3(90, 30, 50)/255;
                float3 white = float3(255, 255, 255)/255;


                //fractal noise waves
                float2 wavesUV = uv * _wavesScale;
                float3x3 rotateMat = float3x3(1, -1, 0,
                                            1, -1, 0,
                                            0, 0, 1);

                float fn = 0;
                wavesUV += sin(wavesUV.yx) * 0.2;       //warping
                wavesUV.x *= 0.9;
                wavesUV.y *= 1.5;

                float f1 = (1 / 2.0) * value_noise(wavesUV * 1);
                float f2 = (1 / 4.0) * value_noise(wavesUV * 2);
                float f3 = (1 / 8.0) * value_noise(wavesUV * 4);
                float f4 = (1 / 16.0) * value_noise(wavesUV * 8);
                fn = f1 + f2;
                fn = fn * 0.5 + 0.1;        //changing the dynamic range

                float3 waterGradient = lerp(white, darkAqua, fn);

                wavesUV = mul(wavesUV, rotateMat);


                //tiles
                float gridSize = 20;
                float2 tilesUV = uv * gridSize;
                float2 tilesGridUV = frac(tilesUV) * 2 - 1;
                tilesGridUV *= tilesGridUV;                         //makes rounded square tiles
                float tiles = circle(0.4, 0.5, tilesGridUV);
                tiles = tiles * 0.3 + 0.3;      //shifting dynamic range


                //again for side wall tiles, but tilt them
                float2 tilesSideUV = tilesUV;

                float2x2 skewMat = float2x2(1.0, -2,   // x basis
                                            0.0, 1.0);  // y basis
                tilesSideUV = mul(tilesSideUV, skewMat);
                
                float2 tilesSideGridUV = frac(tilesSideUV) * 2 - 1;
                tilesSideGridUV *= tilesSideGridUV;

                float tilesSide = circle(0.4, 0.5, tilesSideGridUV);
                tilesSide = tilesSide * 0.3 + 0.3;  //shifting dynamic range


                //pool
                float poolAA = 0.01;
                float3 horizontal = smoothstep(-0.1-poolAA, -0.1+poolAA, uv.y);
                float3 vertical = smoothstep(0.45-poolAA, 0.45+poolAA, uv.x);
                float3 diagonal = smoothstep(uv.x*2-1-poolAA, uv.x*2-1+poolAA, uv.y);

                float3 horizontal2 = smoothstep(-0.05-poolAA, -0.05+poolAA, uv.y);        //these are for the ledge on the top of the pool
                float3 diagonal2 = smoothstep(uv.x*2-0.9-poolAA, uv.x*2-0.9+poolAA, uv.y);

                float3 poolTrapezoid = horizontal * diagonal;   //this is the section that includes the sky and ledge
                float3 poolSky = horizontal2 * diagonal2;       //just the sky
                float3 poolLedge = poolTrapezoid - poolSky;     //just the ledge

                float3 poolWallFront = (1-horizontal)*(1-vertical);
                float3 poolWallSide = vertical * (1-diagonal);

                float3 poolBase = (poolWallFront * darkAqua * tiles) + (poolWallSide * aqua * tilesSide) + (poolLedge * maroon);
                float3 poolWater = poolSky * sky;
                color = poolBase + poolWater;
                color += waterGradient - 1;


                //tinting sky a bit with gradient
                float skyGradientDriver = smoothstep(0.5, 1, uv.y);
                float3 skyGradient = lerp(white, darkSky, skyGradientDriver);
                skyGradient = skyGradient * 0.9 + 0.3;      //shifting dynamic range

                //sun
                float2 sunUV = uv;
                sunUV.x += 0.4;
                sunUV.y -= 0.55;
                float sun = circle(0.05, 0.05, sunUV);
                color += sun.rrr;
                color *= skyGradient;

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}