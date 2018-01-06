// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Raindrops"
{
	Properties
	{
		_BgColor("Color", Color) = (1, 1, 1, 1)
        _DropColor("Drop Color", Color) = (1, 1, 1, 1)
        _Radius("Radius", float) = 1
        _Speed("Speed", float) = 1
		_ScrollSpeed("Scroll Speed", float) = 0.05
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			float4 _BgColor;
			float4 _DropColor;
            float4 _Center;
            float _Radius;
            float _Speed;
			float _ScrollSpeed;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 texCoord : TEXCOORD0;
			};

			float rand(float2 vec)
			{
				// fract(sin()) creates pseudo-randomness
				// dot(xy, vec2) guaruntees value is between 0-1 
				return frac(sin(dot(vec,
                             float2(12.9898,78.233)))*
                             43758.5453123);
			}

            // TODO: draw multiple
            // TODO: fix stretching w object
            float circle(float2 texCoord, float randVal)
            {
                // animate center of circle
                // frac makes it loop back to 0 after 1
                _Center.y = frac(_Center.y + _Time.w * randVal) - _Radius;

                // get distance from pixel to center of circle
                // TODO: learn why this works????
                float2 dist = texCoord - _Center.xy;
	            float show = 1.0 - smoothstep(_Radius - (_Radius * 0.01),
                                              _Radius + (_Radius * 0.01),
                                              dot(dist,dist) * 4.0);
                return show;
            }

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);

                // texture coordinates
				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				input.texCoord.y -= _Time.x * _ScrollSpeed;

                // scale up space
                float2 xy = input.texCoord.xy * 10;
                float2 fxy = frac(xy);
				fxy.x -= 0.5;
				float2 ixy = floor(xy);

				// get random input value
				float2 randVal = rand(ixy) * _ScrollSpeed;

                float show = circle(fxy, randVal);
                float4 color = float4(show, show, show, 1);

				return color;
			}

			ENDCG
		}
	}
}