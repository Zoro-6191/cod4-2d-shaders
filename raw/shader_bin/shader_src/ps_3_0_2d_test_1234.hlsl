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


float2 uv;

float d;
float2 ch_size;
float2 ch_space;
float2 ch_start;
float2 ch_pos;

float dseg(float2 p0, float2 p1)
{
	float2 dir = normalize(p1 - p0);
	float2 cp = mul((uv - ch_pos - p0), mat2(dir.x, dir.y,-dir.y, dir.x));
	return distance(cp, clamp(cp, float2(0,0), float2(distance(p0, p1), 0)));   
}

bool bit(int n, int b)
{
	return mod(floor(float(n) / exp2(floor(float(b)))), 2.0) != 0.0;
}

void ddigit(int n)
{
	float v = 1e6;	
	float2 cp = uv - ch_pos;
	if (n == 0)     v = min(v, dseg(float2(-0.405, -1.000), float2(-0.500, -1.000)));
	if (bit(n,  0)) v = min(v, dseg(float2( 0.500,  0.063), float2( 0.500,  0.937)));
	if (bit(n,  1)) v = min(v, dseg(float2( 0.438,  1.000), float2( 0.063,  1.000)));
	if (bit(n,  2)) v = min(v, dseg(float2(-0.063,  1.000), float2(-0.438,  1.000)));
	if (bit(n,  3)) v = min(v, dseg(float2(-0.500,  0.937), float2(-0.500,  0.062)));
	if (bit(n,  4)) v = min(v, dseg(float2(-0.500, -0.063), float2(-0.500, -0.938)));
	if (bit(n,  5)) v = min(v, dseg(float2(-0.438, -1.000), float2(-0.063, -1.000)));
	if (bit(n,  6)) v = min(v, dseg(float2( 0.063, -1.000), float2( 0.438, -1.000)));
	if (bit(n,  7)) v = min(v, dseg(float2( 0.500, -0.938), float2( 0.500, -0.063)));
	if (bit(n,  8)) v = min(v, dseg(float2( 0.063,  0.000), float2( 0.438, -0.000)));
	if (bit(n,  9)) v = min(v, dseg(float2( 0.063,  0.063), float2( 0.438,  0.938)));
	if (bit(n, 10)) v = min(v, dseg(float2( 0.000,  0.063), float2( 0.000,  0.937)));
	if (bit(n, 11)) v = min(v, dseg(float2(-0.063,  0.063), float2(-0.438,  0.938)));
	if (bit(n, 12)) v = min(v, dseg(float2(-0.438,  0.000), float2(-0.063, -0.000)));
	if (bit(n, 13)) v = min(v, dseg(float2(-0.063, -0.063), float2(-0.438, -0.938)));
	if (bit(n, 14)) v = min(v, dseg(float2( 0.000, -0.938), float2( 0.000, -0.063)));
	if (bit(n, 15)) v = min(v, dseg(float2( 0.063, -0.063), float2( 0.438, -0.938)));
	ch_pos.x += ch_space.x;
	d = min(d, v);
}

float3 hsv2rgb_smooth( in float3 c )
{
    float3 rgb = clamp( abs(mod(c.x*6.0+float3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing	

	return c.z * mix( float3(1.0,1.0,1.0), rgb, c.y);
}



PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	d = 1e6;
	
	ch_size = float2(1.0, 2.0) * 0.6;
	ch_space = ch_size + float2(1.0, 1.0);
	ch_start = float2 (ch_space.x * -5., 1.);
	ch_pos = float2 (0.0, 0.0);
	
	uv = pixel.worldPos.xy;
	//uv.x -= 0.75;
	uv.y -= 0.5;
	uv.y *= -1.0;
	uv.x *= -1.0;

	float _d =  1.0-length(uv);
	uv *= 18.0 ;
	uv -= float2(-3., 1.);
	float time = gameTime.w;

	float3 ch_color = hsv2rgb_smooth(float3(time*0.4+uv.y*0.1,0.5,1.0));

	uv.x += 0.5+sin(time+uv.y*0.7)*0.5;
	uv.x+=3.;
	ch_pos = ch_start;

	
	ddigit(32894); 
	ddigit(17510); 
	ddigit(17414); 
	ddigit(4505); 
	ddigit(249); 
	ddigit(37502); 
	ch_pos = ch_start;  ch_pos.y -= 3.0; 
	ddigit(8806); 
	ddigit(255); 
	ddigit(37151); 
	ddigit(255); 
	ddigit(4352); 
	ddigit(4606); 
	ddigit(641); 
	ddigit(4591); 
	ddigit(641);
	

	float3 color = mix(ch_color, float3(0., 0., .0), 1.0- (0.03 / d*2.0));
	
	fragment.color = float4(color, 1.0);

    return fragment;
}