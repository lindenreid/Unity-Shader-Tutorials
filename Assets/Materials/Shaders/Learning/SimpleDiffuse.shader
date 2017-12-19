Shader "Custom/VertexDiffuse" {
	
	// diffuse reflected intensity eq:
	// I = diffuse intensity
	// L = intensity factor of incoming light
	// k = material constant 
	// N = surface normal vec
	// L = vec from surfact to light
	// I = L* k * max(0, N dot L)

	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
	}

		SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			uniform float4 _LightColor0; // color of light source, from Unity
			uniform float4 _Color;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert normal & light vectors to world space
				// then normalize them
				float4 normal4 = float4(input.normal, 0.0);
				float3 normalDir = normalize(mul(normal4, unity_WorldToObject).xyz);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// calculate diffuse intensity
				float3 diffuseReflection = _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));

				output.col = float4(diffuseReflection, 1.0);
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
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _LightColor0; // color of light source, from Unity
			uniform float4 _Color;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert normal vector to world space
				// then normalize them
				float4 normal4 = float4(input.normal, 0.0);
				float3 normalDir = normalize(mul(normal4, unity_WorldToObject).xyz);
				
				// convert light dir to world space
				// - differs slightly based on whether it's a point or directional light
				float3 vertexToLight = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, input.vertex * _WorldSpaceLightPos0.w).xyz;
				float oneOverDist = 1.0 / length(vertexToLight);
				float attenuation = lerp(1.0, oneOverDist, _WorldSpaceLightPos0.w);
				float3 lightDir = vertexToLight * oneOverDist;

				// calculate diffuse intensity
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));

				output.col = float4(diffuseReflection, 1.0);
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
	Fallback "Diffuse"
}
