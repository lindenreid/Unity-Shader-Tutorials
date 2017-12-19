Shader "Custom/billboardUI"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleX ("Scale X", Float) = 1.0
      	_ScaleY ("Scale Y", Float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"DisableBatching" = "True"
		}

		Pass
		{   
			CGPROGRAM
 
			#pragma vertex vert  
			#pragma fragment frag

			// Properties
			uniform sampler2D _MainTex;   
			uniform float _ScaleX;
			uniform float _ScaleY;  

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 tex : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};
 
			vertexOutput vert(vertexInput input) 
			{
				vertexOutput output;

				float4 mv = mul(UNITY_MATRIX_MV, float4(0,0,0,1)) + float4(input.vertex.x, input.vertex.y, 0, 0);
				output.pos = mul(UNITY_MATRIX_P, mv * float4(_ScaleX, _ScaleY, 1, 1));
 
				output.tex = input.tex;

				return output;
         	}
 
			float4 frag(vertexOutput input) : COLOR
			{
				return tex2D(_MainTex, float2(input.tex.xy));   
			}
 
         ENDCG
		}
	}
}
