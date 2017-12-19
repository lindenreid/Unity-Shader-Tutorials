Shader "Custom/Snow"
{
	Properties
	{
		_RampTex("Ramp Texture", 2D) = "white" {}
		_BumpTex("Bump Texture", 2D) = "white" {}
		_BumpRamp("Bump Ramp Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_SnowLevel("Snow Level", float) = 1.0
	}

	SubShader
	{
		// Color, lighting, shape pass
		Pass
		{
            Tags
            {
                "LightMode" = "ForwardBase" // allows shadow rec/cast
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			// Properties
            sampler2D _RampTex;
            sampler2D _BumpTex;
            sampler2D _BumpRamp;
			float4	  _Color;
			float	  _SnowLevel;

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
				LIGHTING_COORDS(2,3) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				
                // texture coordinates
				output.texCoord = input.texCoord;

				TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
				return output;
			}

			float4 frag(vertexOutput input) : COLOR 
			{
				// normalize light dir
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// apply regular lighting
				float ramp = clamp(dot(input.normal, lightDir), 0, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;

                // apply bump map lighting
                float3 bump = tex2D(_BumpTex, input.texCoord.xy).rgb + input.normal.xyz;
                float bRamp = clamp(dot(bump, lightDir), 0.001, 1.0);
				float3 bLighting = tex2D(_BumpRamp, float2(bRamp, 0.5)).rgb;

				// shadows
				float attenuation = LIGHT_ATTENUATION(input); 

				return _Color * float4(lighting, 1.0) * float4(bLighting, 1.0) * attenuation;
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
