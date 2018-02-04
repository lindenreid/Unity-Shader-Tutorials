// CREDIT TO https://github.com/mattdesl/lwjgl-basics/wiki/shaderlesson5 FOR WRITING THIS
// I basically just adapted it for Unity.

Shader "Custom/GaussianBlur"
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
			uniform float _Radius;

            float4 gaussianBlur(float2 dir, float2 uv, float res)
            {
                //this will be our RGBA sum
                float4 sum = float4(0, 0, 0, 0);
                
                //the amount to blur, i.e. how far off center to sample from 
                //1.0 -> blur by one pixel
                //2.0 -> blur by two pixels, etc.
                float blur = _Radius / res; 
                
                //the direction of our blur
                //(1.0, 0.0) -> x-axis blur
                //(0.0, 1.0) -> y-axis blur
                float hstep = dir.x;
                float vstep = dir.y;
                
                //apply blurring, using a 9-tap filter with predefined gaussian weights
                
                sum += tex2Dlod(_MainTex, float4(uv.x - 4*blur*hstep, uv.y - 4.0*blur*vstep, 0, 0)) * 0.0162162162;
                sum += tex2Dlod(_MainTex, float4(uv.x - 3.0*blur*hstep, uv.y - 3.0*blur*vstep, 0, 0)) * 0.0540540541;
                sum += tex2Dlod(_MainTex, float4(uv.x - 2.0*blur*hstep, uv.y - 2.0*blur*vstep, 0, 0)) * 0.1216216216;
                sum += tex2Dlod(_MainTex, float4(uv.x - 1.0*blur*hstep, uv.y - 1.0*blur*vstep, 0, 0)) * 0.1945945946;
                
                sum += tex2Dlod(_MainTex, float4(uv.x, uv.y, 0, 0)) * 0.2270270270;
                
                sum += tex2Dlod(_MainTex, float4(uv.x + 1.0*blur*hstep, uv.y + 1.0*blur*vstep, 0, 0)) * 0.1945945946;
                sum += tex2Dlod(_MainTex, float4(uv.x + 2.0*blur*hstep, uv.y + 2.0*blur*vstep, 0, 0)) * 0.1216216216;
                sum += tex2Dlod(_MainTex, float4(uv.x + 3.0*blur*hstep, uv.y + 3.0*blur*vstep, 0, 0)) * 0.0540540541;
                sum += tex2Dlod(_MainTex, float4(uv.x + 4.0*blur*hstep, uv.y + 4.0*blur*vstep, 0, 0)) * 0.0162162162;

                return float4(sum.rgb, 1.0);
            }

			float4 frag(v2f_img input) : COLOR
			{
                float resX = _MainTex_TexelSize.z;
				float resY = _MainTex_TexelSize.w;
                float4 blurX = gaussianBlur(float2(1,0), input.uv, resX);
                float4 blurY = gaussianBlur(float2(0,1), input.uv, resY);

				return blurX * blurY;
			}

			ENDCG
		}
	}
}