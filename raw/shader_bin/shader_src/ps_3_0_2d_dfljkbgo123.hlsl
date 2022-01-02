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

float4 hexagon( float2 p ) 
{
	float2 q = float2( p.x*2.0*0.5773503, p.y + p.x*0.5773503 );
	float2 pi = floor(q);
	float2 pf = fract(q);
	float v = mod(pi.x + pi.y, 3.0);
	float ca = step(1.0,v);
	float cb = step(2.0,v);
	float2  ma = step(pf.xy,pf.yx);
	float e = dot( ma, 5.0-pf.yx + ca*(pf.x+pf.y-1.0) + cb*(pf.yx-2.0*pf.xy) );

	float f = length( float2(1.0,0.85) );		
	
	return float4( pi + ca - cb*ma, e, f );
}

float hash1( float2  p )
{
	float n = dot(p,float2(127.1,311.7) );
	return fract(sin(n)*43758.5453);
}

float hash(float n)
{
	return fract(sin(n) * 1e4);
}

float hash(float2 p)
{
	return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

float noise(float x)
{
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), u);
}

float noise(float2 x)
{
	float2 i = floor(x);
	float2 f = fract(x);

	float a = hash(i);
	float b = hash(i + float2(1.0, 0.0));
	float c = hash(i + float2(0.0, 1.0));
	float d = hash(i + float2(1.0, 1.0));

	float2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float noise(float3 x)
{
	const float3 step = float3(110, 241, 171);

	float3 i = floor(x);
	float3 f = fract(x);

    float n = dot(i, step);

	float3 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix( hash(n + dot(step, float3(0, 0, 0))), hash(n + dot(step, float3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, float3(0, 1, 0))), hash(n + dot(step, float3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, float3(0, 0, 1))), hash(n + dot(step, float3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, float3(0, 1, 1))), hash(n + dot(step, float3(1, 1, 1))), u.x), u.y), u.z);
}

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	float2 uv = pixel.worldPos.xy;
    uv.x *= 1.77;
	float2 pos = 5.0*pixel.worldPos.xy ;
    pos.x *= 1.77;

	float3 col = (0,0,0);

	// red
	float4 h = hexagon( 6.0 * pos );
	float n = noise( float3(1.3*h.xy+gameTime.w*0.1,gameTime.w) );
	float colur = 0.3 + 0.8*sin( hash1(h.xy)*1.5 + 2.0);
	
	float3 colb =  float3(0,colur/2.0,colur);
	colb *= 1.0 + 1.15*sin(40.0*h.z);
	colb *= 1.0 / h.z*n;

	h = hexagon(6.0*(pos+0.1*float2(-1.3,1.0)) + 0.6*gameTime.w);
    col *= 1.0-0.2*smoothstep(0.005,1.451,noise( float3(0.3*h.xy+gameTime.w*0.1,gameTime.w) ));

	col = mix( col, colb, smoothstep(0.25,0.451,n) );
	col *= pow( 16.0*uv.x*(1.0-uv.x)*uv.y*(1.0-uv.y), 0.1 );
	
	fragment.color = float4( col, 1.0 );
	
    return fragment;
}