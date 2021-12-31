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

#define SPEED 1.0
#define HUESPEED 0.02
#define SATURATION 0.5
#define DIVISIONS 27.
#define INNER 0.5
#define OUTER 0.8
#define SIZE 0.05
#define BOKEH 0.01

float sdSegment(half2 p,half2 a,half2 b)
{
	half2 pa=p-a,ba=b-a;
	float h=clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
	return length(pa-ba*h);
}

float2x2 rot(float a)
{
	float s=sin(a),c=cos(a);
	return float2x2(c,s,-s,c);
}

half3 hsv(float h,float s,float v)
{
	return ((clamp(abs(fract(h+half3(0.,.666,.333))*6.-3.)-1.,0.,1.)-1.)*s+1.)*v;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	half2 p = 1.0 - pixel.texcoord.yx*2.0;
	//p.x += 0.5;
	//p -= 1.0;
	half time = gameTime.w;
	//slice a pie
	float idiv=1./DIVISIONS;
	float a=floor(atan2(p.x,p.y)*DIVISIONS/6.283+.5);

	//segment sdf
	half2 vSeg= mul(rot(a*6.283*idiv),half2(0,1));
	float d=sdSegment(p,vSeg*INNER,vSeg*OUTER);

	//make a capsule from segment sdf
	float v=smoothstep(SIZE,SIZE-BOKEH,d);

	//color
	float t=floor(DIVISIONS-fract(time*SPEED)*DIVISIONS);
	v*=fract((t+a)*idiv);
	float h=fract(time*HUESPEED+a*idiv);
	fragment.color = half4(hsv(h,SATURATION,v),1);

	return fragment;
}
