Shader "Custom/glass"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_EdgeThickness("Silouette Dropoff Rate", float) = 1.0
	}
	
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			sampler2D		_MainTex;
			uniform float4	_Color;
			uniform float4	_EdgeColor;
			uniform float   _EdgeThickness;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);

				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR 
			{
				// sample texture for color
				float4 texColor = tex2D(_MainTex, input.texCoord.xy);

				// apply silouette equation
				// based on how close normal is to being orthogonal to view vector
				// dot product is smaller the smaller the angle bw the vectors is
				// close to edge = closer to 0
				// far from edge = closer to 1
				float edgeFactor = abs(dot(input.viewDir, input.normal));

				// apply edgeFactor to Albedo color & EdgeColor
				float oneMinusEdge = 1.0 - edgeFactor;
				float3 rgb = (_Color.rgb * edgeFactor) + (_EdgeColor * oneMinusEdge);
				rgb = min(float3(1, 1, 1), rgb); // clamp to real color vals
				rgb = rgb * texColor.rgb;

				// apply edgeFactor to Albedo transparency & EdgeColor transparency
				// close to edge = more opaque EdgeColor & more transparent Albedo 
				float opacity = min(1.0, _Color.a / edgeFactor);

				// opacity^thickness means the edge color will be near 0 away from the edges
				// and escalate quickly in opacity towards the edges
				opacity = pow(opacity, _EdgeThickness);
				opacity = opacity * texColor.a;

				float4 output = float4(rgb, opacity);
				return output;
			}

			ENDCG
		}
	}

}
