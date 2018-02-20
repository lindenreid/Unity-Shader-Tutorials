Shader "Custom/SimpleDiffuseShadow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_BrightColor("Light Color", Color) = (1, 1, 1, 1)
        _DarkColor("Dark Color", Color) = (1, 1, 1, 1)
        _K("Shadow Intensity", float) = 1.0
        _P("Shadow Falloff",  float) = 1.0
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
			{ 
				"LightMode" = "ForwardBase" // allows shadow rec/cast, lighting
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			
			// Properties
			sampler2D _MainTex;
			float4 _Color;
			float4 _LightColor0; // provided by Unity
			float4 _BrightColor;
            float4 _DarkColor;
            float _K;
            float _P;

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
				LIGHTING_COORDS(1,2) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.pos = UnityObjectToClipPos(input.vertex);
				output.normal = UnityObjectToWorldNormal(input.normal);

				output.texCoord = input.texCoord;

				TRANSFER_SHADOW(output); // shadows
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// _WorldSpaceLightPos0 provided by Unity
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// get dot product between surface normal and light direction
				float lightDot = dot(input.normal, lightDir);
                // do some math to make lighting falloff smooth
                lightDot = exp(-pow(_K*(1 - lightDot), _P));

                // lerp lighting between light & dark value
                //float3 light = lerp(_DarkColor, _BrightColor, lightDot);

				// sample texture for color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

                // shadow value
                //float attenuation = LIGHT_ATTENUATION(input); 

                // composite all lighting together
                //float3 lighting = light;
                
                // multiply albedo and lighting
				float3 rgb = albedo.rgb * lightDot;
				//rgb += ShadeSH9(half4(input.normal,1));
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
    Fallback "Diffuse"
}