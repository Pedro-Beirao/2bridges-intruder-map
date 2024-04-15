// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/HUD_Countdown"
{
	Properties
	{
		_MainTex ("Digit Atlas", 2D) = "white" {}
		_LabelTex1 ("Label 1", 2D) = "white" {}
		_LabelTex2 ("Label 2", 2D) = "white" {}
		_State ("State", 2D) = "white" {}
		_Duration ("Duration (seconds)", Range(0,5999)) = 30.0
	}
	SubShader
	{
		Blend One OneMinusSrcAlpha
		ZWrite Off
		Cull Back
		ZTest Always
		Tags { "Queue"="Overlay+1" "RenderType"="Overlay" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" "DisableBatching"="True" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#pragma glsl
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 digits : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _LabelTex1;
			sampler2D _LabelTex2;
			sampler2D _State;

			float _Duration;
			
			v2f vert (appdata v)
			{
				v2f o;
				float2 p = v.vertex.xy;
				p = p+0.5;
				p.x = p.x*0.1 + 0.9/2;
				p.y = p.y*0.1;
				p = p*2-1;
			//	p *= 2;
				o.vertex = float4(p, v.vertex.zw);//mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				float3 up = normalize(transpose(unity_ObjectToWorld)[1]);
				float age = acos(up.y)/3.1415926535897932384626433832795;

				//const float _Duration = 300;

				float display = _Duration * (1-age);

				float minutes = 0;
				float seconds = floor(modf(display/60.0, minutes)*60);

				float seconds10;
				float seconds01 = modf(seconds/10.0, seconds10)*10;

				float minutes10;
				float minutes01 = modf(minutes/10.0, minutes10)*10;
				
				o.digits.x = minutes10;
				o.digits.y = minutes01;
				o.digits.z = seconds10;
				o.digits.w = seconds01;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float digit;
				float x = 1-i.uv.x;
				float y = 1-i.uv.y;
			//	[flatten]
				if(x<0.2)
					digit = i.digits.x;
				else if(x<0.4)
					digit = i.digits.y;
				else if(x<0.6)
					digit = 10;
				else if(x<0.8)
					digit = i.digits.z;
				else
					digit = i.digits.w;
				float t = (digit+1)/12.0;
				float2 uv = i.uv;
				uv.x = frac(x*5);
				uv.y = y*2/12.0 + 1-t;
				
				fixed4 numbers = tex2D(_MainTex, uv);
			//This allows mipmaps to be used without seams at tile edges... but Unity doesn't like it under OpenGL mode
			//	float2 g = i.uv * float2(5,2/12.0); 
			//	fixed4 numbers = tex2Dgrad(_MainTex, uv, ddx(g), ddy(g));

				float2 luv = float2(x,y);
				luv.y = luv.y*2-1;
				fixed4 label1 = tex2D(_LabelTex1, luv);
				fixed4 label2 = tex2D(_LabelTex2, luv);
				fixed state = tex2D(_State, float2(.5,.5)).r;
				fixed4 label = lerp(label1, label2, state);
				return lerp(numbers, label, y>0.5);
			}
			ENDCG
		}
	}
}
