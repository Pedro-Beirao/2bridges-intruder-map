Shader "Unlit/ScreenFx Night"
{
	Properties
	{
	//	_MainTex ("Texture", 2D) = "white" {}
		_Noise ("_Noise", 2D) = "white" {}
		_Dirt ("_Dirt", 2D) = "white" {}
		_Map ("_Map", 2D) = "white" {}

		_NvgOffPos ("NVG Off Center", Vector) = (14.52, 4.3, 0, 0)
		_NvgOffSize ("NVG Off Size", Vector) = (45, 45, 0, 0)
			
		_MapPos ("Map Zone Center", Vector) = (20, 0, 0, 0)
		_MapSize ("Map Zone Size", Vector) = (115, 115, 0, 0)
			
		_DotColor ("Map Marker Color", Color) = (1, 0, 0, 0)
			
		_MapUiSize ("Map UI Size", Vector) = (256,256,0,0)
		_MapUiPos ("Map UI Pos", Vector) = (0, 412, 0, 0)

		_TeamMark ("Team Filter", 2D) = "black" {}

		_Color ("NVG Color", Color) = (0, 1, 0, 0)
		_Lens("Lens Distortion", Range(0,1)) = 0.5
		_NoiseScale("Noise Scale", Range(0,1)) = 0.5
		_Vignette("Vignette", Range(0,4)) = 1.4
			
		[Toggle(OPT_MAP)] _1("Enable minimap", Float) = 0
		[Toggle(OPT_MAP_SOFT_EDGES)] _5("Minimap soft edges", Float) = 0
		[Toggle(OPT_NVG)] _2("Enable NVG", Float) = 0
		[Toggle(OPT_NO_NVG_ZONE)] _3("Disable NVG in NVG-Off zone", Float) = 0
		[Toggle(OPT_NO_NVG_ZOOMING)] _4("Disable NVG when zooming", Float) = 0
		[Toggle(OPT_MAP_WITH_NVG_ONLY)] _6("Disable map in NVG-Off zone", Float) = 0
		[Toggle(OPT_TEAM_SPECIFIC)] _7("Enable Team Filter", Float) = 0
	}
	SubShader
	{
		ZWrite Off
		Cull Back
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
		Tags { "Queue"="Overlay+1" "RenderType"="Overlay" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" "DisableBatching"="True" }
		
        GrabPass
        {
            "_BackgroundTexture2"
        }

		Pass
		{
			Tags { "LightMode"="Always" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma shader_feature OPT_MAP
			#pragma shader_feature OPT_MAP_SOFT_EDGES
			#pragma shader_feature OPT_NVG
			#pragma shader_feature OPT_NO_NVG_ZONE
			#pragma shader_feature OPT_NO_NVG_ZOOMING
			#pragma shader_feature OPT_MAP_WITH_NVG_ONLY
			#pragma shader_feature OPT_TEAM_SPECIFIC
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
			//	UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

//			sampler2D _MainTex;
//			float4 _MainTex_ST;
			sampler2D _BackgroundTexture2;
			sampler2D _Noise;
			sampler2D _Dirt;
			sampler2D _Map;
			sampler2D _TeamMark;
			
		//	sampler2D_float _CameraDepthTexture;
		//	float4 _CameraDepthTexture_TexelSize;
			float3 _Color;
			float _Lens;
			float _NoiseScale;
			float _Vignette;
			float2 _NvgOffPos;
			float2 _NvgOffSize;
			float2 _MapPos;
			float2 _MapSize;
			float3 _DotColor = float3(1,0,0);
			float2 _MapUiSize = float2(256,256);
			float2 _MapUiPos = float2(0,1080-1080/2-256/2);
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = v.vertex;//mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertex.xy *= 2;
				o.uv = v.uv;
			//	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			//	UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float2 lens(float2 tex, float k, float kcube)
			{
				// lens distortion coefficient (between
				//float k = -0.15;
				// cubic distortion value
				//float kcube = 0.5;
				float r2 = (tex.x-0.5) * (tex.x-0.5) + (tex.y-0.5) * (tex.y-0.5);       
				float f = 0;
				//only compute the cubic distortion if necessary
				if( kcube == 0.0){
						f = 1 + r2 * k;
				}else{
						f = 1 + r2 * (k + kcube * sqrt(r2));
				}
				// get the right pixel for the current position
				float x = f*(tex.x-0.5)+0.5;
				float y = f*(tex.y-0.5)+0.5;
				return float2(x,y);
			}


			fixed4 frag (v2f i) : SV_Target
			{ 
				// sample the texture
				i.uv = 1-i.uv;
			
				float4 col = float4(0,0,0,0);

#ifdef OPT_TEAM_SPECIFIC
				float4 team = tex2D(_TeamMark, float2(.5,.5));
				if( team.r < 0.5 )
					return col;
#endif
			
#ifdef OPT_MAP
				bool showMap = true;
#endif
		
#ifdef OPT_NVG
# ifdef OPT_NO_NVG_ZONE
				float2 inNvgZone2 = abs(_WorldSpaceCameraPos.xz - _NvgOffPos.xy);
				bool inNvgZone = any(inNvgZone2 > _NvgOffSize.xy*0.5);
# else
				bool inNvgZone = true;
# endif
				
# ifdef OPT_NO_NVG_ZOOMING
				//disable NVG when zooming
				{
					float t = unity_CameraProjection._m11;
					const float fovThreshold = 35;
					const float Rad2Deg = 180 / UNITY_PI;
					const float x = 1/tan( fovThreshold / (2.0 * Rad2Deg) );
					inNvgZone = inNvgZone && (x > t);
				}
# endif
				
# if defined(OPT_MAP) && defined(OPT_MAP_WITH_NVG_ONLY)
				showMap = inNvgZone;
# endif

				if( inNvgZone )
				{
					float2 ndc = i.uv *2-1;

					float2 wndc = (lens(i.uv, .2, -.1)*2-1)*0.87;
				//	float2 wndc = (lens(i.uv, -.45, .5)*2-1)*0.95;
				//	float2 wndc = (i.uv*2-1);
				//	wndc = ndc;

					wndc = lerp(ndc, wndc, _Lens);

				//	wndc.y -= (1-wndc.x*wndc.x)*0.3-0.2;
				//	wndc.x = lerp( wndc.x*max( 1-(wndc.y*wndc.y*wndc.y*0.5+0.5), 0.5)*2, wndc.x, 0.8);
					float2 wuv = wndc*0.5+0.5;

					col = tex2D(_BackgroundTexture2, wuv);
					float2 r = float2(1920/8,1080/8);
				//	float4 col = tex2D(_BackgroundTexture2, floor(wuv*r)/r);
				//	col += tex2D(_BackgroundTexture2, (floor(wuv*r)+float2( 1.5,0))/r);
				//	col += tex2D(_BackgroundTexture2, (floor(wuv*r)+float2(-1.5,0))/r);
				
					col *= smoothstep(0,0.1, wuv.y);
			
				//	col *= 0.3333333 * 2;
				//	col *= float4(0.15, 1, 0.15, 1); 
				
//					col.rb = lerp( saturate(col.g-float2(0.1,0.2)), col.rb, 0.5);
	//				col.g *= 0.5;
					col = abs(col);
			
				//	col.g *= saturate(frac(wuv.y*r.y+_Time.y)*1000-500);
					float y = floor(wuv.y*r.y*8)/(r.y*8);
					float banding = frac(y*r.y*0.5+_Time.y);
					float b = smoothstep(0,1,banding)*smoothstep(1,0,banding);
					col = col*saturate(b+0.5);// + saturate(b*0.1);

					float4 dirt = tex2D(_Dirt, i.uv);

					float4 noise = tex2D(_Noise, (1-i.uv)*_ScreenParams.xy/64.0 + frac(frac(_Time.xx) * 1337));
					//noise = tex2D(_Noise, i.uv*_ScreenParams.xy/64.0 + noise.zw*2.5 + _Time.xy*1000);
					noise = tex2D(_BackgroundTexture2, frac(i.uv+noise.xy));

					noise *= _NoiseScale;

				//	noise = min(noise, 1-noise);

					//col.rgb = lerp(col.rgb * dirt.rgb, col.rgb, saturate(dirt.a + _SinTime.x*0.5 + 0.75));

					float3 g = col * (noise.g+0.5) + noise.r * 0.1;
					g = pow(g*2, 0.5)*2;

			//		col.g = col.g * (noise.g+0.5) + noise.r * 0.1;
			//	//	col.g = pow(col.g, 0.3);
			//		col.g = pow(col.g*2, 0.5)*2;
			//		//col.a = 1;

					//col.g = noise.w;

					col.rgb = g * _Color;
				
				//	ndc = i.uv*2-1;
					ndc = wndc;
					float v = 2-dot(ndc,ndc)*_Vignette;
	
					col.rgb *= saturate(v);
					col.a = 1;
				
				}
				else
#endif
				{
				//	col = tex2D(_BackgroundTexture2, i.uv);
				}
				
#ifdef OPT_MAP
				if( showMap )
				{
					float2 mapUv = (i.uv * float2(1920,1080) - _MapUiPos)/_MapUiSize;
								
				//	mapUv = floor(mapUv*128)/128.0;
					float4 map = tex2D(_Map, mapUv);
					map.a = (mapUv.x > 0 ? 1.0 : 0.0) * (mapUv.y > 0 ? 1.0 : 0.0) * (mapUv.x < 1 ? 1.0 : 0.0) * (mapUv.y < 1 ? 1.0 : 0.0);
				//	map.rgb = (1-dot(map.rgb, (1/3.0).xxx).xxx) * float3(0.5,1,0.5);
					

					float2 mapPos = ((_WorldSpaceCameraPos.xz - _MapPos)/_MapSize)*0.5+0.5;
					mapPos = max((float2).03,mapPos);
					mapPos = min((float2).97, mapPos);
					float2 diff = (mapUv - mapPos);
					float dist = dot(diff,diff);
					map.rgb = lerp( map.rgb, _DotColor, (1-smoothstep(0, (1/64.4)*(1/64.4), dist))*abs(frac(_Time.z)*2-1));
				
				//	mapPos = ((float2(-26.5+25.16604,-90-2.821847) - float2(20,0))/115)*0.5+0.5;
				//	diff = (mapUv - mapPos);
				//	dist = dot(diff,diff);
				//	map.rgb = lerp( map.rgb, float3(.25,0,.5), (1-smoothstep(0, (1/32.4)*(1/32.4), dist))*0.75);
				//
				//	mapPos = ((float2(31.85+25.16604,115.34-2.821847) - float2(20,0))/115)*0.5+0.5;
				//	diff = (mapUv - mapPos);
				//	dist = dot(diff,diff);
				//	map.rgb = lerp( map.rgb, float3(.25,0,.5), (1-smoothstep(0, (1/32.4)*(1/32.4), dist))*0.75);

				//	map.r = -dist;
# ifdef OPT_MAP_SOFT_EDGES
					map.a *= smoothstep(0,0.02, mapUv.x);
					map.a *= smoothstep(1,1-0.02, mapUv.x);
					map.a *= smoothstep(0,0.02, mapUv.y);
					map.a *= smoothstep(1,1-0.02, mapUv.y);
# endif
					col.rgb = lerp( col.rgb, map.rgb, map.a );
					col.a = saturate( col.a + map.a );
				}
#endif
				
				return col;
			}
			ENDCG
		}
	}
}
