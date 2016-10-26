Shader "Custom/DisolveShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB) Alpha (A)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap("Bumpmap", 2D) = "bump" {}
		[Toggle] _Inverse("inversed", Float) = 0
		_CutOut("Alpha Cutout", Float) = 0.5
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }

		Tags{ "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" } //Rendertype to check material for alpha masking
		LOD 200

		//Use this to make the inner faces of your model visible trough transparent faces
		Cull Off

		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types

		//#pragma surface surf Standard vertex:vert alphatest:_Cutoff addshadow //Unity Cutout mehtod

		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "noiseSimplex.cginc"


		

		sampler2D _MainTex;

		struct vertexInput {
			float4 vertex : POSITION;
		};

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float4 pos : SV_POSITION;
			float3 srcPos : TEXCOORD0;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		sampler2D _BumpMap; 

		//The uniform values get controlled via the DisolveCOntroller Script via Shader.SetGlobalFloat
		uniform float _DisolveFreq;
		uniform float _IsoVal;
		uniform float3 _DisolvePoint;
		uniform float _MaxDist;
		uniform float _DistanceLimitFac;


		float _Inverse;
		float _CutOut;

		Input vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);


			//Inputs the position of the vertex and mutliplies it by the size of the noise. (_DisolveFreq)
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

			o.srcPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			
			o.srcPos *= _DisolveFreq;

			return o;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			//Samples the noise from noiseSimplex.cginc
			float ns = snoise(IN.srcPos) / 2 + 0.5f;

			//Calculate distance to the disolve point
			float dist = distance(IN.srcPos, _DisolvePoint);

			//The maximum value corresponds to the "if (disolveAmount < 2)" line in the controller. Change either one of these, so the maximum here is bigger than the value in the script,
			//to stop the effect forming a solid border around the radius.
			float q = clamp(dist / _MaxDist, 0, 2);

			//Compute the Iso Value
			float compareIso = _IsoVal-(q*_DistanceLimitFac);

			if (_Inverse == 1) {
				compareIso = 1.0 - compareIso;
			}

			//c.a gives you the ability to use the texture alpha channel as transparency
			if (c.a > _CutOut) {
				//if noise Value is bigger than iso: Normal Shading
				if (ns > compareIso) {
					o.Albedo = c.rgb;
					o.Emission = float3(0, 0, 0);

				}
				//if noise Value is slightly smaller than iso: Glowing Edge
				else if (ns + 0.05 > compareIso) {
					o.Albedo = float4(0.0, 0.8, 1.0, c.a);
					o.Emission = float3(0, 0.5, 0.9);
				}
				//else discard the values to make a transparent face.
				else {
					discard;

				}
			}
			else {
				discard;
			}

			// Metallic and smoothness come from slider variables
			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}
		ENDCG
	}
	Fallback "Transparent/Cutout/VertexLit"
}
