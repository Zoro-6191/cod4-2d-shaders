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

float easeOutQuart(float t)
{
  return 1.0 - (--t) * t * t * t;
}

float crystal(float a)
{
  return abs(cos(a*12.)*sin(a*3.))*.8+.1;
}

float gear(float a)
{
  return smoothstep(-.5,1., cos(a*10.))*0.2+0.5;
}

float sakura(float a)
{
  return abs(cos(a*2.5))*.5+.3;
}

float plot(float r, float pct){
  return  smoothstep( pct-0.05, pct, r) -
          smoothstep( pct, pct+0.05, r);
}


PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

    float duration = 3.0;

    float2 st = 1.0 - pixel.texcoord.xy * 2.0;

    float time = gameTime.w;

    float r = length(st);
    float a = atan2(st.y,st.x) + time * 0.2;

    float t = mod(time, duration);
    float f;
    if(t < 1.0)
    {
        f = crystal(a) * t + gear(a) * (1.0 - t);
    }
    else if(t >= 1.0 && t < 2.0)
    {
        f = sakura(a) * (t - 1.0) + crystal(a) * (2.0 - t);
    }
    else if(t >= 2.0)
    {
        f = gear(a) * (t - 2.0) + sakura(a) * (3.0 - t);
    }

    float pct = plot(r, f);
    float4 color_ = float4((st.x + 1.0)/2.0, (st.y + 1.0)/2.0, abs(sin(time)), 1.0);
    float4 col = pct * color_;

    fragment.color = col;

	return fragment;
}
