Shader "UI/UICaptureBlur"
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
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			half4 _EffectFactor;

			// Sample texture with blurring.
			// * Fast: Sample texture with 3x1 kernel.
			// * Medium: Sample texture with 5x1 kernel.
			// * Detail: Sample texture with 7x1 kernel.
			fixed4 Tex2DBlurring1D (sampler2D tex, half2 uv, half2 blur)
			{
				float4 o = 0;
				float sum = 0;
				float weight;
				half2 texcood;
				for(int i = -7/2; i <= 7/2; i++)
				{
					texcood = uv;
					texcood.x += blur.x * i;
					texcood.y += blur.y * i;
					weight = 1.0/(abs(i)+2);
					o += tex2D(tex, texcood)*weight;
					sum += weight;
				}
				return o / sum;
			}

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
