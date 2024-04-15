Shader "Custom/SonarSkin"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_Outline("Outline", Color) = (1,1,1,1)
		_MainTex ("Albedo1 (RGB)", 2D) = "white" {}
		_MainTex2("Albedo2 (RGB)", 2D) = "white" {}
		_State("State", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Test("Test", Range(-1,1)) = 0.0
		_Alpha("Alpha", Range(0,1)) = 0.5
		_EdgeAlpha("Edge Alpha", Range(0,1)) = 0.5
    }
    SubShader
    {
		//Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest+100" "IgnoreProjector"="True" "DisableBatching"="True" }
        LOD 200
			
		Pass
		{
			Name "Fill"
			ZTest Off
			ZWrite Off
			Cull Back
			Blend One One, One One
			BlendOp Add, Min
			ColorMask RGBA
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"


				struct v2f {
					float4 pos          : POSITION;
					float4 uv    : TEXCOORD0;
				};

				float _Alpha;
				float _Test;
				float4 _Outline;
				sampler2D _MainTex2;
				sampler2D _State;

				v2f vert(appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					return half4(0,0,0,0);
				}
			ENDCG
		}

		Pass
		{
			Name "Outline"
			ZTest Greater
			ZWrite Off
			//Cull Front
			Blend DstAlpha One
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"


				struct v2f {
					float4 pos          : POSITION;
					// float4 screenPos    : TEXCOORD0;
				};

			float _EdgeAlpha;
			float _Test;
			float4 _Outline;
			sampler2D _MainTex2;
			sampler2D _State;
			sampler2D_float _CameraDepthTexture;
			float4 _CameraDepthTexture_TexelSize;

			v2f vert(appdata_full v)
			{
				v2f o;

				float3 view = ObjSpaceViewDir(v.vertex) * 0.01;
				float4 pos1 = UnityObjectToClipPos(v.vertex - view);
				float4 pos2 = UnityObjectToClipPos(v.vertex + v.normal * 0.001 - view);

				if (pos1.w <= 0 || pos2.w <= 0)
				{
					o.pos = pos1;
				}
				else
				{
					pos1.xy /= pos1.w;
					pos2.xy /= pos2.w;
					float2 xy = (pos1.xy - pos2.xy) * _ScreenParams.xy * 0.5;
					float d = length(xy);

					xy = lerp(pos1.xy, pos2.xy, (rcp(d)) * 2);
					o.pos.xy = xy * pos2.w;
					o.pos.zw = pos1.zw;
					//o.pos.z -= 0.001;

					//_WorldSpaceCameraPos
				}
					//o.pos = UnityObjectToClipPos(v.vertex + v.normal * 0.001);
					//o.screenPos = ComputeScreenPos(o.pos);
					return o;
				}

				half4 frag(UNITY_VPOS_TYPE screenPos : VPOS) : COLOR
				{
					fixed4 s = tex2D(_State, float2(0,0));
					float blend = saturate(_Test + s.r);

					float rawZ = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos.xy * _CameraDepthTexture_TexelSize);
					float sceneZ = LinearEyeDepth(rawZ);
					blend *= saturate(sceneZ-0.25);
					return (half4)_Outline * blend * _EdgeAlpha;
				}
			ENDCG
		}
			
		Pass
		{
			Name "Fill"
			ZTest Off
			ZWrite Off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"


				struct v2f {
					float4 pos          : POSITION;
					float4 uv    : TEXCOORD0;
				};

				float _Alpha;
				float _Test;
				float4 _Outline;
				sampler2D _MainTex2;
				sampler2D _State;
				sampler2D_float _CameraDepthTexture;
				float4 _CameraDepthTexture_TexelSize;

				v2f vert(appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					fixed4 s = tex2D(_State, float2(0,0));
					float blend = saturate(_Test + s.r);

					float rawZ = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.pos.xy * _CameraDepthTexture_TexelSize);
					float sceneZ = LinearEyeDepth(rawZ);
					blend *= saturate(sceneZ-0.25);
					return half4(lerp(_Outline, tex2D(_MainTex2, i.uv), 0.5).xyz, blend * _Alpha);
				}
			ENDCG
		}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows keepalpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MainTex2;
		sampler2D _State;

        struct Input
        {
            float2 uv_MainTex;
			float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
		fixed4 _Color;
		float _Test;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		//	fixed4 c2 = tex2D(_MainTex2, IN.uv_MainTex);
		//	fixed4 s = tex2D(_State, float2(0,0));

		//	float blend = saturate(_Test + s.r);
		//	c = lerp(c, c2, blend);
            o.Albedo = c.rgb * _Color;
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            o.Alpha = c.a;

			// float nv = dot(o.Normal, IN.viewDir);
			// 
			// float ambient = ShadeSH9(fixed4(o.Normal, 1.0));
			// float a = ambient;
			// 
			// a += saturate(nv * 0.35 * a);
			// 
			// a = sqrt(a);
			// a = round(a * 10) / 10;
			// a *= a;
			// 
			// [flatten]
			// if (nv < 0.5)
			// 	a *= 0.25;
			// 
			// o.Emission = (a - ambient) * o.Albedo;

			//clip(o.Alpha - 0.5);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
