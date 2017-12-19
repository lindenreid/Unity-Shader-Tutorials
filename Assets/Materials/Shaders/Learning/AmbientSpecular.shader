Shader "Custom/AmbientSpecular" {
	
	Properties
	{
		_Color ("Albedo Color", Color) = (1, 1, 1, 1)
		_SpecColor("Specular Color", Color ) = (1, 1, 1, 1)
		_Shininess ("Shininess", Float) = 10
	}

	SubShader
	{
		Pass
		{
			// pass for ambient light & first light source
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _LightColor0; // Unity-defined color of light source
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert normal, view, & light direction to world space & normalize
				// assumes directional light!
				float3 normalDir = normalize(mul(input.normal, unity_WorldToObject));
				float3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);
				
				float attenuation;
				float3 lightDir;
				if (0.0 == _WorldSpaceLightPos0.w) // directional light
				{
					attenuation = 1.0; // no attenuation
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
				}
				else // point or spot light
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, input.vertex).xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance; // linear attenuation 
					lightDir = normalize(vertexToLightSource);
				}

				// ambient lighting equation:
				// I = ambient color
				// L = ambient light
				// k = albedo color
				// I = L*k
				float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				// reflective vector equation:
				// R = reflected light vector
				// N = surface normal
				// L = light source
				// R = 2*N*(N dot L) - L
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));

				// specular highlights equation:
				// I = specular light
				// i = color of incoming light
				// k = color of material
				// R = reflected light vector
				// V = vector to viewer
				// n = shininess of material
				// I = i * k * max(0, R dot V)^n
				float reflectVector = reflect(-lightDir, normalDir); // reflect(I,N) assumes I is from lightSource->surface, but our lightDir is from surface->lightSource, so must negate
				float3 specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflectVector, viewDir)), _Shininess);
				specularReflection = max(float3(0.0, 0.0, 0.0), specularReflection); // make sure color is atleast 0, in case light source on wrong side (and therefore dot product < 0)

				output.col = float4(ambientColor + diffuseReflection + specularReflection, 1.0);
				output.pos = UnityObjectToClipPos(input.vertex); 

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				return input.col;
			}

			ENDCG
		}

		Pass
		{
			// pass for additional light sources
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One // additive blending

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _LightColor0; // Unity-defined color of light source
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float3 normalDir = normalize(mul(input.normal, unity_WorldToObject));
				float3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);

				float attenuation;
				float3 lightDir;
				if (0.0 == _WorldSpaceLightPos0.w) // directional light
				{
					attenuation = 1.0; // no attenuation
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
				}
				else // point or spot light
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, input.vertex).xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance; // linear attenuation 
					lightDir = normalize(vertexToLightSource);
				}

				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));

				float reflectVector = reflect(-lightDir, normalDir); // reflect(I,N) assumes I is from lightSource->surface, but our lightDir is from surface->lightSource, so must negate
				float3 specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflectVector, viewDir)), _Shininess);
				specularReflection = max(float3(0.0, 0.0, 0.0), specularReflection); // make sure color is atleast 0, in case light source on wrong side (and therefore dot product < 0)

				output.col = float4(diffuseReflection + specularReflection, 1.0);
				output.pos = UnityObjectToClipPos(input.vertex);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				return input.col;
			}

			ENDCG
		}
	}
	Fallback "Specular"

}
