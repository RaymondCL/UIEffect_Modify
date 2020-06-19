#ifndef UI_EFFECT_INCLUDED
#define UI_EFFECT_INCLUDED

#if FASTBLUR | MEDIUMBLUR | DETAILBLUR
#define UI_BLUR
#endif

// Sample texture with blurring.
// * Fast: Sample texture with 3x3 kernel.
// * Medium: Sample texture with 5x5 kernel.
// * Detail: Sample texture with 7x7 kernel.
fixed4 Tex2DBlurring (sampler2D tex, half2 texcood, half2 blur, half4 mask)
{
	#if FASTBLUR && EX
	const int KERNEL_SIZE = 5;
	const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
	#elif MEDIUMBLUR && EX
	const int KERNEL_SIZE = 9;
	const float KERNEL_[9] = { 0.0438, 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719, 0.0438};
	#elif DETAILBLUR && EX
	const int KERNEL_SIZE = 13;
	const float KERNEL_[13] = { 0.0438, 0.1138, 0.2486, 0.4566, 0.7046, 0.9141, 1.0, 0.9141, 0.7046, 0.4566, 0.2486, 0.1138, 0.0438};
	#elif FASTBLUR
	const int KERNEL_SIZE = 3;
	const float KERNEL_[3] = { 0.4566, 1.0, 0.4566};
	#elif MEDIUMBLUR
	const int KERNEL_SIZE = 5;
	const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
	#elif DETAILBLUR
	const int KERNEL_SIZE = 7;
	const float KERNEL_[7] = { 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719};
	#else
	const int KERNEL_SIZE = 1;
	const float KERNEL_[1] = { 1.0 };
	#endif
	float4 o = 0;
	float sum = 0;
	float2 shift = 0;
	for(int x = 0; x < KERNEL_SIZE; x++)
	{
		shift.x = blur.x * (float(x) - KERNEL_SIZE/2);
		for(int y = 0; y < KERNEL_SIZE; y++)
		{
			shift.y = blur.y * (float(y) - KERNEL_SIZE/2);
			float2 uv = texcood + shift;
			float weight = KERNEL_[x] * KERNEL_[y];
			sum += weight;
			#if EX
			fixed masked = min(mask.x <= uv.x, uv.x <= mask.z) * min(mask.y <= uv.y, uv.y <= mask.w);
			o += lerp(fixed4(0.5, 0.5, 0.5, 0), tex2D(tex, uv), masked) * weight;
			#else
			o += tex2D(tex, uv) * weight;
			#endif
		}
	}
	return o / sum;
}

// Sample texture with blurring.
// * Fast: Sample texture with 3x3 kernel.
// * Medium: Sample texture with 5x5 kernel.
// * Detail: Sample texture with 7x7 kernel.
fixed4 Tex2DBlurring (sampler2D tex, half2 texcood, half2 blur)
{
	return Tex2DBlurring(tex, texcood, blur, half4(0,0,1,1));
}


// Sample texture with blurring.
// * Fast: Sample texture with 3x1 kernel.
// * Medium: Sample texture with 5x1 kernel.
// * Detail: Sample texture with 7x1 kernel.
fixed4 Tex2DBlurring1D (sampler2D tex, half2 uv, half2 blur)
{
	#if FASTBLUR
	const int KERNEL_SIZE = 3;
	#elif MEDIUMBLUR
	const int KERNEL_SIZE = 5;
	#elif DETAILBLUR
	const int KERNEL_SIZE = 7;
	#else
	const int KERNEL_SIZE = 1;
	#endif
	float4 o = 0;
	float sum = 0;
	float weight;
	half2 texcood;
	for(int i = -KERNEL_SIZE/2; i <= KERNEL_SIZE/2; i++)
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

#endif // UI_EFFECT_INCLUDED
