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

float rand(half2 n) 
{
    return fract(sin(cos(dot(n, half2(12.9898,12.1414)))) * 83758.5453);
}

float noise(half2 n) 
{
    half2 d = half2(0.0, 1.0);
    half2 b = floor(n), f = smoothstep(half2(0.0,0.0), half2(1.0,1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(half2 n) 
{
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i <5; i++) {
        total += noise(n) * amplitude;
        n += n*1.7;
        amplitude *= 0.47;
    }
    return total;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	half3 c1 = half3(0.5, 0.0, 0.1);
    half3 c2 = half3(0.9, 0.1, 0.0);
    half3 c3 = half3(0.2, 0.1, 0.7);
    half3 c4 = half3(1.0, 0.9, 0.1);
    half3 c5 = half3(0.1,0.1,0.1);
    half3 c6 = half3(0.9,0.9,0.9);

	half iTime = gameTime.w;

    half2 speed = half2(0.1, 0.9);
    float shift = 1.327+sin(iTime*2.0)/2.4;
    float alpha = 1.0;
    
	float dist = 3.5-sin(iTime*0.4)/1.89;
    
    half2 uv = pixel.texcoord.xy;
	uv.x *= 3.0;
	uv = 1.0 - uv;
    half2 p = uv * dist;

    p += sin(p.yx*4.0+half2(.2,-.3)*iTime)*0.04;
    p += sin(p.yx*8.0+half2(.6,+.1)*iTime)*0.01;
    
    //p.x -= iTime/1.1;
    float q = fbm(p - iTime * 0.3+1.0*sin(iTime+0.5)/2.0);
    float qb = fbm(p - iTime * 0.4+0.1*cos(iTime)/2.0);
    float q2 = fbm(p - iTime * 0.44 - 5.0*cos(iTime)/2.0) - 6.0;
    float q3 = fbm(p - iTime * 0.9 - 10.0*cos(iTime)/15.0)-4.0;
    float q4 = fbm(p - iTime * 1.4 - 20.0*sin(iTime)/14.0)+2.0;
    q = (q + qb - .4 * q2 -2.0*q3  + .6*q4)/3.8;
    half2 r = half2(fbm(p + q /2.0 + iTime * speed.x - p.x - p.y), fbm(p + q - iTime * speed.y));
    half3 c = mix(c1, c2, fbm(p + r)) + mix(c3, c4, r.x) - mix(c5, c6, r.y);
    half3 color = half3(1.0/(pow(c+1.61,half3(4.0,4.0,4.0))) * cos(shift * uv.y));
    
    color=half3(1.0,.2,.05)/(pow((r.y+r.y)* max(.0,p.y)+0.1, 4.0));;
    color += (half4(0.,0.,0.,0.).xyz*0.01*pow((r.y+r.y)*.65,5.0)+0.055)*mix( half3(.9,.4,.3),half3(.7,.5,.2), uv.y);
    color = color/(1.0+max(half3(0,0,0),color));
	
    fragment.color = half4(color.x, color.y, color.z, alpha);

	return fragment;
}
