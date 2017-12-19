Shader "Custom/CelWithSnow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
        _SnowLevel("Snow Level", Range(0.01, -0.01)) = 0
        _SnowColor("Snow Color", Color) = (1, 1, 1, 1)
        _SnowBump("Snow Bump Texture", 2D) = "white" {}
        _SnowRamp("Snow Ramp Texture", 2D) = "white" {}
        _SnowDirection("Snow Direction", vector) = (1, 1, 1, 1)
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
			{ 
				"LightMode" = "ForwardBase" // allows shadow rec/cast
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			// Properties
			sampler2D _MainTex;
			sampler2D _RampTex;
            sampler2D _SnowBump;
            sampler2D _SnowRamp;
            float4 _Color;
			float4 _SnowColor;
            float4 _SnowDirection;
            float _SnowLevel;
			float4 _LightColor0; // provided by Unity

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
                float4 snowDir : TEXCOORD1;
				LIGHTING_COORDS(2,3) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				output.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);
                output.snowDir = mul(_SnowDirection, unity_WorldToObject);

                // texture coordinates
				output.texCoord = input.texCoord;

                TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// normalize light direction
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // apply regular lighting
                float ramp = clamp(dot(input.normal, lightDir), 0, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;
				
				// sample texture & apply Color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);
                albedo *= _Color;

                // check if snow should be applied
                float applySnow = dot(input.normal, input.snowDir) >= _SnowLevel;

                // apply snow color
                albedo = (1-applySnow)*albedo + applySnow*_SnowColor;

                // get snow bump map lighting
                float3 snowBump = tex2D(_SnowBump, input.texCoord.xy).rgb + input.normal.xyz;
                float snowRamp = clamp(dot(snowBump, lightDir), 0.001, 1.0);
                float3 snowLighting = tex2D(_SnowRamp, float2(snowRamp, 0.5));
                snowLighting *= lighting;

                // use either snow lighting or regular lighting
                lighting = (1-applySnow)*lighting + applySnow*snowLighting;

                // shadows
				float attenuation = LIGHT_ATTENUATION(input); 

				float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * attenuation;
				return float4(rgb, 1.0);
			}

			ENDCG
		}

		// Shadow pass
		Pass
    	{
            Tags 
			{
				"LightMode" = "ShadowCaster"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
    	}
	}
}