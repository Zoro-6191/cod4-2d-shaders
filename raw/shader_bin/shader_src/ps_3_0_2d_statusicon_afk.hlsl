#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>
#include "lib/utility.hlsl"

struct PixelInput
{
    float4 position     : POSITION;
	float3 worldPos     : TEXCOORD0;
};

struct PixelOutput
{
	float4 color        : COLOR;
};

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;
	
	float4 myTex = tex2D(colorMapSampler, pixel.worldPos.xy);
	fragment.color = myTex;
	
    return fragment;
}