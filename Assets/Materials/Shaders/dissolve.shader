Shader "Custom/Dissolve"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_DissolveSpeed("Dissolve Speed", float) = 1.0
		_DissolveColor1("Dissolve Color 1", Color) = (1, 1, 1, 1)
		_DissolveColor2("Dissolve Color 2", Color) = (1, 1, 1, 1)
		_ColorThreshold1("Color Threshold 1", float) = 1.0
		_ColorThreshold2("Color Threshold 2", float) = 1.0
		_StartTime("Start Time", float) = 1.0
	}

	SubShader
	{
        Tags
		{ 
			"Queue" = "Transparent"
		}

		Pass
		{
            Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			float4 _Color;
			float4 _DissolveColor1;
			float4 _DissolveColor2;
			sampler2D _NoiseTex;
			float _DissolveSpeed;
			float _ColorThreshold1;
			float _ColorThreshold2;
			float _StartTime;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texCoord : TEXCOORD1;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert to world space
				output.pos = UnityObjectToClipPos(input.vertex);

				// texture coordinates 
				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// base color
				float4 color = _Color;

				// sample noise texture
				float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));

				// dissolve colors
                float thresh2 = _Time * _ColorThreshold2 - _StartTime;
				float useDissolve2 = noiseSample - thresh2 < 0;
				color = (1-useDissolve2)*color + useDissolve2*_DissolveColor2;

                float thresh1 = _Time * _ColorThreshold1 - _StartTime;
				float useDissolve1 = noiseSample - thresh1 < 0;
				color = (1-useDissolve1)*color + useDissolve1*_DissolveColor1;

				float threshold = _Time * _DissolveSpeed - _StartTime;
				clip(noiseSample - threshold);

                return color;
			}

			ENDCG
		}
	}
}
