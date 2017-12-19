// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Cuts away all fragments that have a positive Y coordinate in obj coords
Shader "Custom/Cutaway" {

	SubShader
	{
		Pass
		{
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			struct vertInput
			{
				float4 vertex : POSITION;
			};	

			struct vertOut
			{
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			vertOut vert(vertInput input)
			{
				vertOut output;
				output.pos = UnityObjectToClipPos(input.vertex);
				output.worldPos = mul(unity_ObjectToWorld, input.vertex);
				return output;
			}

			float4 frag(vertOut input) : COLOR
			{
				if (input.worldPos.y > 10.0)
					discard;
				return float4(0.0, 0.0, 1.0, 1.0);
			}

			ENDCG
		}
	}

}