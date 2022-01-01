#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>
#include "lib/utility.hlsl"

struct PixelInput
{
    half4 position     : POSITION;
	half3 worldPos     : TEXCOORD0;
};

struct PixelOutput
{
	half4 color        : COLOR;
};

float random( float2 p )
{	
	return fract( sin( fract( sin( p.x ) ) + p.y) * 42.17563);
}
 
float worley( float2 p, float timeSpeed )
{
	float d = 10.0;
	for( int xo = -1; xo <= 1; xo++ )
	{
		for( int yo = -1; yo <= 1; yo++ )
		{
			float2 test_cell = floor(p) + float2( xo, yo );
			
			float f1 = random( test_cell );
			float f2 = random( test_cell + float2(1.0,3.0) );
			
			float xp = mix( f1, f2, sin(gameTime.w*timeSpeed) );
			float yp = mix( f1, f2, cos(gameTime.w*timeSpeed) );
			
			float2 c = test_cell + float2(xp,yp);
			
			float2 cTop = p - c;
			d = min( d, dot(cTop,cTop) );
		}
	}
	return d;
}
 
float worley2( float2 p )
{
	float d = 1.0;
	for( int xo = -1; xo <= 1; xo++ )
	{
		for( int yo = -1; yo <= 1; yo++ )
		{
			float2 test_cell = floor(p) + float2( xo, yo );
			
			float2 c = test_cell;
			
			float2 cTop = p - c;
			d = min( d, dot(cTop,cTop) );
		}
	}
	return d;
}

float poop( float2 uv, float timeSpeed, PixelInput pixel )
{
	float t = worley( pixel.worldPos.xy / 15.0, timeSpeed );
	t = pow(t, 1.0 );
	
	return t;
}

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	half2 uv = pixel.worldPos.xy - 0.5;
	
	float t = worley2( pixel.worldPos.xy / 0.6);
	float3 finalColor = float3( t,0,t) * 1.1;
	
	t = poop( uv, 1.0, pixel  );
	finalColor += float3( t*t, t, sqrt(t * 3.0) );
 
	
	finalColor *= smoothstep(1.0, 0.0, length(uv.y) * 1.2 );
	
	fragment.color = half4(finalColor,pixel.worldPos.x);
	
    return fragment;
}