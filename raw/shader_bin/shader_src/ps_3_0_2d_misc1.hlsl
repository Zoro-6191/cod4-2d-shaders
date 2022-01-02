#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

struct PixelInput
{
    float4 position     : POSITION;
	float2 texcoord 	: TEXCOORD0;
};

struct PixelOutput
{
	float4 color        : COLOR;
};

float rand(float x)
{
    return fract(sin(x) * 358.5453123);
}

float rand(float2 co)
{
    return fract(sin(dot(co.xy ,float2(2.9898,78.233))) * 43758.5357);
}

float box(float2 p, float2 b, float r)
{
  return length(max(abs(p)-b,0.0))-r;
}

float sampleMusic()
{
	return 0.5;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	const float speed = 0.2;
	const float ySpread = 1.6;
	const int numBlocks = 70;

	float pulse = sampleMusic();
	
	float2 uv = 0.7 - pixel.texcoord.xy * 1.4;
	float3 baseColor = uv.x > 0.0 ? float3(0.0,0.3, 0.6) : float3(0.6, 0.0, 0.1);
	
	float3 color = pulse*baseColor*0.5*(0.9-cos(uv.x*8.0));
	
	for (int i = 0; i < numBlocks; i++)
	{
		float z = 1.0-0.7*rand(float(i)*1.4333); // 0=far, 1=near
		float tickTime = gameTime.w*z*speed + float(i)*1.23753;
		float tick = floor(tickTime);
		
		float2 pos = float2(0.6*(rand(tick)-0.5), sign(uv.x)*ySpread*(0.5-fract(tickTime)));
		pos.x += 0.24*sign(pos.x); // move aside
		if (abs(pos.x) < 0.1) pos.x++; // stupid fix; sign sometimes returns 0
		
		float2 size = 0.8*z*float2(0.04, 0.04 + 0.1*rand(tick+0.2));
		float b = box(uv-pos, size, 0.01);
		float dust = z*smoothstep(0.02, 0.0, b)*pulse*0.2;
		float block = 0.2*z*smoothstep(0.002, 0.0, b);
		float shine = 1.0*z*pulse*smoothstep(0.02, b, 0.007);
		color += dust*baseColor + block*z + shine;
	}
	
	//color -= rand(uv)*0.04;
	fragment.color = float4(color, 1.0);

	return fragment;
}
