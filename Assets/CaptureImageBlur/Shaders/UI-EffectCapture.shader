Shader "UI/Hidden/UI-EffectCapture"
{
	Properties
	{
		[PerRendererData] _MainTex("Main Texture", 2D) = "white" {}
	}

	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite Off
		Fog{ Mode off }

		Pass
		{
			Name "Effect-Base"

		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "UI-Effect.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			v2f_img vert(appdata_img v)
			{
				v2f_img o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				#if UNITY_UV_STARTS_AT_TOP
				o.uv.y = 1 - o.uv.y;
				#endif
				return o;
			}

			fixed4 frag(v2f_img IN) : SV_Target
			{
				half4 color = tex2D(_MainTex, IN.uv);

				color.a = 1;
				return color;
			}
		ENDCG
		}


		Pass
		{
			Name "Effect-Blur"

		CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_blur
			#pragma target 2.0

			#pragma shader_feature __ FASTBLUR MEDIUMBLUR DETAILBLUR
			
			#include "UnityCG.cginc"
			#include "UI-Effect.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			half4 _EffectFactor;

			fixed4 frag_blur(v2f_img IN) : SV_Target
			{
				half2 blurFactor = _EffectFactor.xy;
				half4 color = Tex2DBlurring1D(_MainTex, IN.uv, blurFactor * _MainTex_TexelSize.xy * 2);
				color.a = 1;
				return color;
			}
		ENDCG
		}
	}
}
