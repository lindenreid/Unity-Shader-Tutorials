Shader "Custom/Curtain"
{
	Properties
	{
        _NoiseTex("Noise Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
        _WaveSpeed("Wave Speed", float) = 1.0
		_WaveAmp("Wave Amp", float) = 0.2
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
            {
                "Queue" = "Transparent"
                "DisableBatching" = "True"
            }
            Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			sampler2D _NoiseTex;
			sampler2D _RampTex;
			float4 _Color;
			float4 _LightColor0; // provided by Unity
            float  _WaveSpeed;
			float  _WaveAmp;

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
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with 4x4 matrix
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

                // apply wave animation
				float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
				output.pos.z += sin(_Time*_WaveSpeed*noiseSample)*_WaveAmp;
				output.pos.x += cos(_Time*_WaveSpeed*noiseSample)*_WaveAmp;

				// texture coordinates 
				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// convert light direction to world space & normalize
				// _WorldSpaceLightPos0 provided by Unity
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// finds location on ramp texture that we should sample
				// based on angle between surface normal and light direction
				float ramp = clamp(dot(input.normal, lightDir), 0.001, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;

				// _LightColor0 provided by Unity
				float3 rgb = _Color.rgb * _LightColor0.rgb * lighting;
				return float4(rgb, _Color.a);
			}

			ENDCG
		}
	}
}