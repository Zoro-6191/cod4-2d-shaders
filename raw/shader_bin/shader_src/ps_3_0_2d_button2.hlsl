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

#define PI 3.141592653589793238462643383279502884197169399
#define time (gameTime.w*0.3+voronoi(half2(4.5,3.5))*2.5)

half2 randomhalf2( half2 p )
{
	half2 m = half2( 15.27, 47.63 );
	
	return frac( sin(m * p) * 4689.32 );
}

half voronoi( half2 p )
{
	
	half2 g = floor( p );
	half2 f = frac(p);
	
	half res = 8.0;
	
	half2 da = half2(0.5,0.5);
	
	for( half y = -1.0; y <= 1.0; y += da.y )
	{
		for( half x = -1.0; x <= 1.0; x += da.x )
		{
			half2 lattice = half2( x, y );
			half d = distance( lattice + randomhalf2(lattice + g), f);
			res = min( d, res );
		}
	}
	
	return 367.0-res;
}

half3 pixelAt(half2 uv)
{
	half3 result;
	half thickness = 0.09;
	half movementSpeed = -4.0;
	half wavesInFrame = 5.0;
	half waveHeight = 0.3;
	half pp = (sin(time * movementSpeed + uv.x * wavesInFrame * 2.0 * cos(sin(time))*PI) * waveHeight );
	half sharpness = 1.001;
	half dist = 1.0 - abs(clamp((pp - uv.y) / thickness, -1.0, 1.0));
	half brightness = 0.8;

	dist = pow(dist, sharpness);
	
	dist *= brightness;
		
	result = half3(dist, 0., 0.);
	
	return result;
}

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	half2 uv = pixel.worldPos.xy - 0.5;
	half3 pix;
	
	pix = pixelAt(uv);
	
	const half e = 21.0, s = 2.0 / e;
	for (half i = 0.0; i < e; ++i)
	{
		pix += pixelAt(uv + (uv * (i*s))) * (0.5-i*s*0.325);
	}
	pix /= 1.00;
	
	fragment.color = half4(pix,pixel.worldPos.x);
	
    return fragment;
}