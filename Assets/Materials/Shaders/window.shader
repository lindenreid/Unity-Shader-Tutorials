Shader "Custom/Window"
{
	Properties
	{
		_ClearColor ("Clear Color", Color) = (1,1,1,1)
		_FogColor ("Fog Color", Color) = (1,1,1,1)
		_BlurRadius ("Blur Radius", float) = 3
		_MaxAge("Max Age", float) = 3
	}

	SubShader
	{
		Tags
        {
            "Queue" = "Transparent"
        }

        // Grab the screen behind the object into _BGTex
        GrabPass
        {
            "_BGTex"
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			// Properties
			// set in material
			uniform float4 _ClearColor;
			uniform float4 _FogColor;
			uniform float _BlurRadius;
			uniform float _MaxAge;
			// grab pass
			uniform sampler2D _BGTex;
			uniform float4 _BGTex_TexelSize;
			// set by script
			uniform sampler2D _MouseMap;
			uniform float _MaxSeconds;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 texCoord : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
			};

			// https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
			float4 gaussianBlur(float2 dir, float4 grabPos, float res, sampler2D tex, float radius)
            {
                //this will be our RGBA sum
                float4 sum = float4(0, 0, 0, 0);
                
                //the amount to blur, i.e. how far off center to sample from 
                //1.0 -> blur by one pixel
                //2.0 -> blur by two pixels, etc.
                float blur = radius / res; 
                
                //the direction of our blur
                //(1.0, 0.0) -> x-axis blur
                //(0.0, 1.0) -> y-axis blur
                float hstep = dir.x;
                float vstep = dir.y;
                
                //apply blurring, using a 9-tap filter with predefined gaussian weights
                
                sum += tex2Dproj(tex, float4(grabPos.x - 4*blur*hstep, grabPos.y - 4.0*blur*vstep, grabPos.zw)) * 0.0162162162;
                sum += tex2Dproj(tex, float4(grabPos.x - 3.0*blur*hstep, grabPos.y - 3.0*blur*vstep, grabPos.zw)) * 0.0540540541;
                sum += tex2Dproj(tex, float4(grabPos.x - 2.0*blur*hstep, grabPos.y - 2.0*blur*vstep, grabPos.zw)) * 0.1216216216;
                sum += tex2Dproj(tex, float4(grabPos.x - 1.0*blur*hstep, grabPos.y - 1.0*blur*vstep, grabPos.zw)) * 0.1945945946;
                
                sum += tex2Dproj(tex, float4(grabPos.x, grabPos.y, grabPos.zw)) * 0.2270270270;
                
                sum += tex2Dproj(tex, float4(grabPos.x + 1.0*blur*hstep, grabPos.y + 1.0*blur*vstep, grabPos.zw)) * 0.1945945946;
                sum += tex2Dproj(tex, float4(grabPos.x + 2.0*blur*hstep, grabPos.y + 2.0*blur*vstep, grabPos.zw)) * 0.1216216216;
                sum += tex2Dproj(tex, float4(grabPos.x + 3.0*blur*hstep, grabPos.y + 3.0*blur*vstep, grabPos.zw)) * 0.0540540541;
                sum += tex2Dproj(tex, float4(grabPos.x + 4.0*blur*hstep, grabPos.y + 4.0*blur*vstep, grabPos.zw)) * 0.0162162162;

                return float4(sum.rgb, 1.0);
            }

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				output.grabPos = ComputeGrabScreenPos(output.pos);
				output.texCoord = input.texCoord;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float4 bg = tex2Dproj(_BGTex, input.grabPos);
				// younger = redder
				float4 mouseSample = tex2D(_MouseMap, input.texCoord.xy);
				//return mouseSample; 
				float timeDrawn = mouseSample.r * _MaxSeconds; 
				float age = clamp(_Time.y - timeDrawn, 0.0001, _Time.y);
				float percentMaxAge = saturate(age / _MaxAge); 
				//return float4(percentMaxAge, 0, 0, 1); 
				
				// older = higher percentMaxAge = more blur
				float blurRadius = _BlurRadius * percentMaxAge;
				float4 color = (1-percentMaxAge)*_ClearColor + percentMaxAge*_FogColor;

				float4 blurX = gaussianBlur(float2(1,0), input.grabPos, _BGTex_TexelSize.z, _BGTex, blurRadius);
				float4 blurY = gaussianBlur(float2(0,1), input.grabPos, _BGTex_TexelSize.w, _BGTex, blurRadius);
				return (blurX + blurY) * color;

				// TEST
				//float blurRadius = floor(_BlurRadius * mouseSample.r);
				//return mouseSample.r // test mouse map
				//float noSmudge = mouseSample.r != 0; // test erasing blur
			}

			ENDCG
		}
	}
}
