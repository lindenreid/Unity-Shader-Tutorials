Shader "Custom/Grass"
{
	Properties
	{
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
        _WaveSpeed("Wave Speed", float) = 1.0
        _WaveAmp("Wave Amp", float) = 1.0
        _HeightFactor("Height Factor", float) = 1.0
		_HeightCutoff("Height Cutoff", float) = 1.2
        _WindTex("Wind Texture", 2D) = "white" {}
        _WorldSize("World Size", vector) = (1, 1, 1, 1)
        _WindSpeed("Wind Speed", vector) = (1, 1, 1, 1)
	}

	SubShader
	{
		Pass
		{
            Tags
            {
                "DisableBatching" = "True"
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
            #include "UnityCG.cginc"
			
			// Properties
			sampler2D _RampTex;
            sampler2D _WindTex;
            float4 _WindTex_ST;
			float4 _Color;
			float4 _LightColor0; // provided by Unity
            float4 _WorldSize;
            float _WaveSpeed;
            float _WaveAmp;
            float _HeightFactor;
			float _HeightCutoff;
            float4 _WindSpeed;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
                //float2 sp : TEXCOORD0; // test sample position
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to clip & world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

                // get vertex world position
                float4 worldPos = mul(input.vertex, unity_ObjectToWorld);
                // normalize position based on world size
                float2 samplePos = worldPos.xz/_WorldSize.xz;
                // scroll sample position based on time
                samplePos += _Time.x * _WindSpeed.xy;
                // sample wind texture
                float windSample = tex2Dlod(_WindTex, float4(samplePos, 0, 0));
                
				//output.sp = samplePos; // test sample position

                // 0 animation below _HeightCutoff
                float heightFactor = input.vertex.y > _HeightCutoff;
				// make animation stronger with height
				heightFactor = heightFactor * pow(input.vertex.y, _HeightFactor);

                // apply wave animation
                output.pos.z += sin(_WaveSpeed*windSample)*_WaveAmp * heightFactor;
                output.pos.x += cos(_WaveSpeed*windSample)*_WaveAmp * heightFactor;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// normalize light dir
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// apply lighting
				float ramp = clamp(dot(input.normal, lightDir), 0.001, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;

                //return float4(frac(input.sp.x), 0, 0, 1); // test sample position

				float3 rgb = _LightColor0.rgb * lighting * _Color.rgb;
				return float4(rgb, 1.0);
			}

			ENDCG
		}

	}
}