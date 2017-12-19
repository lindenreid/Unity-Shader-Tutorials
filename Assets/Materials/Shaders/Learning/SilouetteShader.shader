Shader "Custom/SilouetteShader"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 0.5)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_Thickness("Silouette Size", float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			// cull & zwrite optional based on look ur going 4
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha // alpha blending

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _Color;
			uniform float4 _EdgeColor;
			uniform float _Thickness;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD;
				float3 viewDir : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// transform input into world space
				// (must use vec4s to multiply w 4x4 matrix)
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);
				output.pos = UnityObjectToClipPos(input.vertex);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// apply silouette equation
				// based on how close normal is to being orthogonal to view vector
				// (dot product is smaller the smaller the angle bw the vectors is)
				// close to edge = closer to 0
				// far from edge = closer to 1
				float edgeFactor = abs(dot(input.viewDir, input.normal));

				float oneMinusEdge = 1.0 - edgeFactor;
				float3 rgb = (_Color.rgb * edgeFactor) + (_EdgeColor * oneMinusEdge);
				rgb = min(float3(1, 1, 1), rgb); // clamp to real color vals

				float opacity = min(1.0, _Color.a / edgeFactor);
				opacity = pow(opacity, _Thickness);

				return float4 (rgb, opacity);
			}

			ENDCG
		}
	}
}
