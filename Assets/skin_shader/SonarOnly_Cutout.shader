Shader "Custom/SonarOnly_Cutout"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo1 (RGB)", 2D) = "white" {}
		_State("State", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alphatest:_Cutoff

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
			fixed4 s = tex2D(_State, float2(0,0));

            // Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			float blend = saturate(_Test + s.r);

		//	c = lerp(c, c2, blend);
            o.Albedo = c.rgb * _Color;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a * blend;

		//	clip(o.Alpha - 0.5);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
