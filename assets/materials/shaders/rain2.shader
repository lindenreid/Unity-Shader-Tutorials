// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Rain2"
{
	Properties
	{
		_BgColor("Color", Color) = (1, 1, 1, 1)
        _DropColor("Drop Color", Color) = (0, 0, 0, 1)
        _Radius("Radius", float) = 1
		_RadVar("Radius Variation", float) = 0.001
        _Speed("Speed", float) = 1
		_Center1("Center 1", vector) = (0.1, 0.5, 0, 0)
		_Center2("Center 2", vector) = (0.2, 0.2, 0, 0)
		_Center3("Center 3", vector) = (0.3, 0.5, 0, 0)
		_Center4("Center 4", vector) = (0.4, 0.2, 0, 0)
		_Center5("Center 5", vector) = (0.5, 0.5, 0, 0)
		_Center6("Center 6", vector) = (0.6, 0.2, 0, 0)
		_Center7("Center 7", vector) = (0.7, 0.5, 0, 0)
		_Center8("Center 8", vector) = (0.8, 0.2, 0, 0)
		_Center9("Center 9", vector) = (0.9, 0.5, 0, 0)
		_Center10("Center 10", vector) = (0.22, 0.2, 0, 0)
		_Center11("Center 11", vector) = (0.33, 0.5, 0, 0)
		_Center12("Center 12", vector) = (0.44, 0.2, 0, 0)
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
			}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			float4 _BgColor;
			float4 _DropColor;
            float _Radius;
			float _RadVar;
            float _Speed;
			float4 _Center1;
			float4 _Center2;
			float4 _Center3;
			float4 _Center4;
			float4 _Center5;
			float4 _Center6;
			float4 _Center7;
			float4 _Center8;
			float4 _Center9;
			float4 _Center10;
			float4 _Center11;
			float4 _Center12;

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

            float circle(float2 texCoord, float2 center)
            {
				// vary radius per pixel
				float rad = _Radius; //+ rand(texCoord)*_RadVar;

                // get distance from pixel to center of circle
                float2 dist = texCoord - center;
				// check if distance is within Radius
	            float show = 1.0 - smoothstep(rad - (rad * 0.01),
                                              rad + (rad * 0.01),
                                              dot(dist,dist) * 4.0);
                return show;
            }

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				output.texCoord = input.texCoord;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float2 fxy = input.texCoord.xy;

				// animate center of circle
				_Center1.y = frac(_Center1.y + _Time.w * _Speed * rand(_Center1.xy));
				_Center2.y = frac(_Center2.y + _Time.w * _Speed * rand(_Center2.xy));
				_Center3.y = frac(_Center3.y + _Time.w * _Speed * rand(_Center3.xy));
				_Center4.y = frac(_Center4.y + _Time.w * _Speed * rand(_Center4.xy));
				_Center5.y = frac(_Center5.y + _Time.w * _Speed * rand(_Center5.xy));
				_Center6.y = frac(_Center6.y + _Time.w * _Speed * rand(_Center6.xy));
				_Center7.y = frac(_Center7.y + _Time.w * _Speed * rand(_Center7.xy));
				_Center8.y = frac(_Center8.y + _Time.w * _Speed * rand(_Center8.xy));
				_Center9.y = frac(_Center9.y + _Time.w * _Speed * rand(_Center9.xy));
				_Center10.y = frac(_Center10.y + _Time.w * _Speed * rand(_Center10.xy));
				_Center11.y = frac(_Center11.y + _Time.w * _Speed * rand(_Center11.xy));
				_Center12.y = frac(_Center12.y + _Time.w * _Speed * rand(_Center12.xy));

				// make x-path a little random?
				// TODO: base on noise texture?
				//_Center1.x = _Center1.x + sin(_Time.w)*0.01 + rand(_Center1.xy)*0.01;

				float show1 = circle(fxy, _Center1.xy); 
				float show2 = circle(fxy, _Center2.xy);
				float show3 = circle(fxy, _Center3.xy); 
				float show4 = circle(fxy, _Center4.xy);
				float show5 = circle(fxy, _Center5.xy); 
				float show6 = circle(fxy, _Center6.xy);
				float show7 = circle(fxy, _Center7.xy); 
				float show8 = circle(fxy, _Center8.xy);
				float show9 = circle(fxy, _Center9.xy); 
				float show10 = circle(fxy, _Center10.xy);
				float show11 = circle(fxy, _Center11.xy); 
				float show12 = circle(fxy, _Center12.xy);

				float show = show1 || show2 || show3 || show4 || show5
				             || show6 || show7 || show8 || show9 || show10
							 || show11 || show12;

				float4 color = (1-show)*_BgColor + (show)*_DropColor;
				return color;
			}

			ENDCG
		}
	}
}