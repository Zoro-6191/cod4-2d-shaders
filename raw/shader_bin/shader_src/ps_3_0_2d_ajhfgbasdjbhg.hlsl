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

float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
   float xx=x+sin(t*fx*0.1)*sx;
   float yy=y+cos(t*fy*0.4)*sy;
   return 0.4/sqrt(abs(xx*yy+yy*xx));
}

PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	float2 p=(pixel.worldPos.xy)*5.0;
	p.x-= 0.4;

	float x=p.x;
	float y=p.y;
	float t=gameTime.w*4.0;

	float a=
	makePoint(x,y,3.4,2.5,0.1,4.1,t);
	a=a+makePoint(x,y,1.9,2.0,0.4,0.4,t);
	a=a+makePoint(x,y,0.8,0.7,0.4,0.5,t);
	a=a+makePoint(x,y,2.3,0.3,0.6,0.3,t);
	a=a+makePoint(x,y,0.8,1.7,0.5,0.4,t);
	a=a+makePoint(x,y,0.3,1.0,0.4,0.4,t);
	a=a+makePoint(x,y,1.4,1.3,0.4,0.5,t);
	a=a+makePoint(x,y,1.3,2.1,0.5,0.3,t);
	a=a+makePoint(x,y,1.4,1.7,0.5,0.4,t);   

	float b=
	makePoint(x,y,1.2,1.9,0.1,0.2,t);
	b=b+makePoint(x,y,0.7,2.7,0.4,0.4,t);
	b=b+makePoint(x,y,1.4,0.6,0.4,0.5,t);
	b=b+makePoint(x,y,2.6,0.4,0.6,0.3,t);
	b=b+makePoint(x,y,0.7,1.4,0.5,0.4,t);
	b=b+makePoint(x,y,0.7,1.7,0.4,0.4,t);
	b=b+makePoint(x,y,0.8,0.5,0.4,0.5,t);
	b=b+makePoint(x,y,1.4,0.9,0.6,0.3,t);
	b=b+makePoint(x,y,0.7,1.3,0.5,0.4,t);

	float c=
	makePoint(x,y,3.7,0.3,0.3,0.3,t);
	c=c+makePoint(x,y,1.9,1.3,0.4,0.4,t);
	c=c+makePoint(x,y,0.8,0.9,0.4,0.5,t);
	c=c+makePoint(x,y,1.2,1.7,0.6,0.3,t);
	c=c+makePoint(x,y,0.3,0.6,0.5,0.4,t);
	c=c+makePoint(x,y,0.3,0.3,0.4,0.4,t);
	c=c+makePoint(x,y,1.4,0.8,0.4,0.5,t);
	c=c+makePoint(x,y,0.2,0.6,0.6,0.3,t);
	c=c+makePoint(x,y,1.3,0.5,0.5,0.4,t);

	float3 d=float3(a,b,c)/32.0;

	fragment.color = float4(d.x,d.y,d.z,1.0);
	
    return fragment;
}