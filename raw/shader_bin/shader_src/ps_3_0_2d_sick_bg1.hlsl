#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>
#include "lib/utility.hlsl"

struct PixelInput
{
    float4 position     : POSITION;
    //float2 texcoord     : TEXCOORD0;
	float3 worldPos     : TEXCOORD0;
};

struct PixelOutput
{
	float4 color        : COLOR;
};
float field(in float3 p)
{
	float strength = 6. + .005 * log(1.e-10 + frac(sin(gameTime.w) * 4533.11));
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < 64; ++i)
	{
		float mag = dot(p, p);
		p = abs(p) / mag + float3(-.5, -.4, -1.5);
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
		tw += w;  prev = mag;
	}
	return max(0.1, 3.5 * accum / tw - .7);
}

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	float2 uv = 0.7 - pixel.worldPos.xy * 1.4;
	uv.x = uv.x*1.77;
	// uv.y += 0.7;

	//float2 uvs = uv * pixel.worldPos.xy / max(pixel.worldPos.x, pixel.worldPos.y);
	float3 p = float3(uv / 4., 0) + float3(1., -1.3, 0.);
	p += .1 * float3(sin(gameTime.w / 40.), sin(gameTime.w / 40.), sin(gameTime.w / 32.));
	float t = field(p);
	float v = (1. - exp((abs(uv.x) - 1.) * 6.)) * (1. - exp((abs(uv.y) - 1.) * 6.));
	fragment.color = mix(.6, 1.5, v) * float4(5.7 * t * t * t, 1.2 * t * t, t, 1.0);
	
    return fragment;
}