Shader "Custom/PlaygroundShader"
{ 
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		// makes background transparent
		Pass
		{
			Cull Off
			ZWrite Off
			Blend Zero OneMinusSrcAlpha

			CGPROGRAM

			// Properties
			uniform float4 _Color;

			#pragma vertex vert
			#pragma fragment frag
			
			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}	

			float4 frag(void) : COLOR
			{
				return _Color;
			}

			ENDCG
		}

		// adds colors from our _Color back in
		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha One

			CGPROGRAM

			// Properties
			uniform float4 _Color;

			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}

				float4 frag(void) : COLOR
			{
				return _Color;
			}

			ENDCG
		}
	}
}