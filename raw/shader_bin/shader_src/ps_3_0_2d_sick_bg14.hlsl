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

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 0.7 - pixel.texcoord.xy * 1.4;

	uv.x = uv.x*1.77;

	float t = gameTime.w*2.0;

	float b = 0.0;
	float size = 0.1;
	float blur = 0.02;

	for(float i=5.0;i<30.0;i++){
		size += (i/10000.0);
		b +=  smoothstep(size, size-blur, length(uv - (vec2(sin(t/5./+i+5./sin(i)),cos(t/5./(4.-i))/2.))));
	}
	
	fragment.color = vec4( b/8.,b/9.,b/4., 1.0 );

	return fragment;
}
