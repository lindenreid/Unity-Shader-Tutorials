Shader "Custom/PaintCircular"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Radius("Radius", float) = 3.0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
            #include "UnityCG.cginc"
			
			// Properties
			sampler2D _MainTex;
			// (1/pixelHidth, 1/pixelHeight, width, height)
			float4 _MainTex_TexelSize;
			float _Radius;
			float _RandAmt;

			float3 mean[4] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
			float3 variance[4] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}};

			float4 frag(v2f_img input) : COLOR
			{
				float2 uv = input.uv;

				// pixel location values for top-left pixel of each box A,B,C,D
				float2 center[4] = 
				{
					{-_Radius, -_Radius},
					{0, -_Radius},
					{-_Radius, 0},
					{0, 0} 
				};

				float2 pos;
				float3 color;
				for(int i = 0; i < 4; i++)
				{
					for(int x = 0; x <= _Radius; x++)
					{
						for(int y = 0; y <= _Radius; y++)
						{
							// get relative pixel location in ABCD box
							// based on centering position + loop position
							pos = center[i] + float2(x,y);
							// convert relative pixel location
							// to image pixel location
							// based on image dimensions
							pos = (pos * _MainTex_TexelSize.xy) + uv;
							// sample color
							color = tex2D(_MainTex, pos).rgb;
							// add to mean & variance matricies for later calculation
							mean[i] += color;
							variance[i] += color * color;
						}
					}
				}

				// to calculate the mean for each ABCD box,
				// we need the number of pixels per box
				float n = pow(_Radius + 1, 2);
				// we're looking for the smallest variance, so set min to something large
				float min = 1;
				// default color
				float3 outColor = tex2D(_MainTex, uv).rgb;
				// variance for each box
				float sigma = 0;

				for(int box = 0; box < 4; box++)
				{
					// calculate mean value for each box
					mean[box] = mean[box] / n;
					// calculate variance value for each box
					variance[box] = abs(variance[box]/n - mean[box]*mean[box]);
					sigma = variance[box].r + variance[box].g + variance[box].b;

					// if this is the smallest variance, 
					// set min = sigma
					// and output color = current color
					float smallest = sigma < min;
					min = (1-smallest)*min + smallest*sigma;
					outColor = (1-smallest)*outColor + smallest*mean[box].rgb;
				}

				return float4(outColor, 1.0);
			}

			ENDCG
		}
	}
}