Shader "Custom/ColorCorrection"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_VignetteColor("Vignette Color", Color) = (1, 1, 1, 1)
		_V1("Vignette Falloff", float) = 1.0
		_V2("Vignette Size", float) = 1.0
		_FadeInSpeed("Fade in speed", float) = 1.0
		_GlitchColor("Glitch Color", Color) = (1, 1, 1, 1)
		_GlitchSpeed("Glitch Speed", float) = 0.1
		_GlitchSize1("Glitch Size 1", float) = 1.0
		_GlitchSize2("Glitch Size 2", float) = 0.0
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
			float4 _Color;
			float4 _GlitchColor;
			float4 _VignetteColor;
			float _V1;
			float _V2;
			float _FadeInSpeed;
			float _GlitchSpeed;
			float _GlitchSize1;
			float _GlitchSize2;

			float rand(float2 vec)
			{
				// fract(sin()) creates pseudo-randomness
				// dot(xy, vec2) guaruntees value is between 0-1 
				return frac(sin(dot(vec,
                             float2(12.9898,78.233)))*
                             43758.5453123);
			}

			float4 frag(v2f_img input) : COLOR
			{
                // sample texture for color
				float4 base = tex2D(_MainTex, input.uv);
				// average original color and new color
                //base = (base + _Color)/2.0;

				// add vignette
				float distFromCenter = distance(input.uv.xy, float2(0.5, 0.5));
				//float falloff = min(_FadeInSpeed * _Time.x, _V1); // animation
				distFromCenter = saturate(_V2 * distFromCenter);
				base = distFromCenter*_VignetteColor + (1-distFromCenter)*base;
				base = saturate(base);

				// add glitch lines
				float2 glitchSamplePos = input.uv + _Time.x*_GlitchSpeed;
				float doGlitch = sin(_GlitchSize1 * glitchSamplePos.y) + rand(float2(glitchSamplePos.xy));
				base *= (doGlitch * _GlitchColor);

				// add random blackout
				

				//base.r = distFromCenter; //test have correct distance value

				return base;
			}

			ENDCG
		}
	}
}