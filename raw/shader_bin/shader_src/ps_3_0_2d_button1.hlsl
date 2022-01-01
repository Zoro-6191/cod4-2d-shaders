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

float Hash( float2 p)
{
     float3 p2 = float3(p.xy,1.0);
    return fract(sin(dot(p2,float3(37.1,61.7, 12.4)))*3758.5453123);
}

float noise(in float2 p)
{
    float2 i = floor(p);
     float2 f = fract(p);
     f *= f*(3.0-2.0*f);
    return mix(mix(Hash(i + float2(0.,0.)), Hash(i + float2(1.,0.)),f.x),
               mix(Hash(i + float2(0.,1.)), Hash(i + float2(1.,1.)),f.x),
               f.y);
}

float fbm(float2 p)
{
     float v = 0.0;
     v += noise(p*1.0) * .75;
     v += noise(p*3.)  * .50;
     v += noise(p*9.)  * .250;
     v += noise(p*27.)  * .125;
     return v;
}


PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 0.7 - pixel.texcoord.xy - 0.5;

	uv.y -= 0.35;

	float timeVal = gameTime.w * 0.1;

	float3 finalColor = float3( 0.0, 0, 0 );
	for( int i=0; i < 20; ++i )
	{
		float indexAsFloat = float(i);
		float amp = 10.0 + (indexAsFloat*500.0);
		float period = 2.0 + (indexAsFloat+2.0);
		float thickness = mix( 0.9, 1.0, noise(uv*indexAsFloat) );
		float t = abs( 1.0 / (sin(uv.y + fbm( uv + timeVal * period )) * amp) * thickness );
		
		
		finalColor +=  t * float3( .3, 0.95, 1.5 );
	}
	
	fragment.color = float4( finalColor, pixel.texcoord.x );

	return fragment;
}
