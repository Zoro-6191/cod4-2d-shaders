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

float rand(float2 p){
	p+=.2127+p.x+.3713*p.y;
	float2 r=4.789*sin(789.123*(p));
	return fract(r.x*r.y);
}

float sn(float2 p){
	float2 i=floor(p-.5);
	float2 f=fract(p-.5);
	f = f*f*f*(f*(f*6.0-15.0)+10.0);
	float rt=mix(rand(i),rand(i+float2(1.,0.)),f.x);
	float rb=mix(rand(i+float2(0.,1.)),rand(i+float2(1.,1.)),f.x);
	return mix(rt,rb,f.y);
}

float2x2 rotate2d(float _angle){
    return float2x2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 1.0 - pixel.texcoord.xy * 2.0;
    	
	float time = uv.x*999.+cos(gameTime.w*5.5+uv.y*12.);

	float2 p=uv.xy*float2(3.,4.3);
	float f =
	.5*sn(p)
	+.25*sn(2.*p)
	+.125*sn(4.*p)
	+.0625*sn(8.*p)
	+.03125*sn(16.*p)+
	.015*sn(32.*p)
	;

	float newT = time*0.4 + sn(float2(time*1.,time*1.))*0.1;
	p.x-=time*0.2;

	p.y*=1.3;
	float f2=
	.5*sn(p)
	+.25*sn(2.04*p+newT*1.1)
	-.125*sn(4.03*p-time*0.3)
	+.0625*sn(8.02*p-time*0.4)
	+.03125*sn(16.01*p+time*0.5)+
	.018*sn(24.02*p);

	float f3=
	.5*sn(p)
	+.25*sn(2.04*p+newT*1.1)
	-.125*sn(4.03*p-time*0.3)
	+.0625*sn(8.02*p-time*0.5)
	+.03125*sn(16.01*p+time*0.6)+
	.019*sn(18.02*p);

	float f4 = f2*smoothstep(0.0,1.,uv.y);

	float3 clouds = mix(float3(-0.4,-0.3,-0.15),float3(1.4,1.4,1.3),f4*f);
	float lightning = sn((f3)+float2(pow(sn(float2(time*4.5,time*4.5)),6.),pow(sn(float2(time*4.5,time*4.5)),6.)));

	lightning *= smoothstep(0.0,1.,uv.y+0.5);

	lightning = smoothstep(0.76,1.,lightning);
	lightning=lightning*2.;



	clouds*=0.8;
	clouds += lightning +0.2;


	float2 newUV = uv;
	newUV.x-=time*0.3;
	newUV.y+=time*3.;
	float strength = sin(time*0.5+sn(newUV))*0.1+0.15;

	float3 painting = (clouds)+clamp((strength-0.1),0.,1.);

	fragment.color = float4(painting, 1.);

	return fragment;
}
