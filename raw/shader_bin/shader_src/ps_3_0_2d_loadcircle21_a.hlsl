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

// --------[ Original ShaderToy begins here ]---------- //
#define _Smooth(p,r,s) smoothstep(-s, s, p-(r))
#define PI 3.141592
#define TPI 6.2831
#define HPI 1.570796

float GetBias(float x,float bias)
{
	return (x / ((((1.0/bias) - 2.0)*(1.0 - x))+1.0));
}
float GetGain(float x,float gain)
{
	if(x < 0.5)
		return GetBias(x * 2.0,gain)/2.0;
	else return GetBias(x * 2.0 - 1.0,1.0 - gain)/2.0 + 0.5;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float smax(float a, float b, float k)
{
    return (-smin(-a,-b,k));
}

float sclamp(float f,float k)
{
    return smin(1.,smax(0.,f,k),k);
}

float hex(float2 pos)
{
    const float corner = .015;
    float2 q = abs(pos);
	return smax(
        smax((q.x * 0.866025 +pos.y*0.5),q.y,corner),
        smax((q.x * 0.866025 -pos.y*0.5),q.y,corner),corner);
}

float hexRadiusFactor(float time)
{
    time *= 2.;
    float s = sclamp(sin(time )+.65,.25);
	
    return s;
}

void hexFest(inout float3 col,in float2 uv, in float time)
{
    float3 hexColor = float3(1,1,1);
    
    float a =- PI / 3.;
    float sa = sin(a);
    float ca = cos(a);
    uv = mul(mat2(sa,ca,ca,-sa), uv);
    
     //hexagones
    float deltaTime = 1./8. * 1.2;
    float baseHexRadius = .1;
    float2 hexDelta = float2(.195,.21);
    
    float timeAccu = 1.;
    
    float rf,radius,f = 0.;

    //hex1
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv);
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
    
    //hex2
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(1.,.5));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
    
    //hex3
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(1.,-.5));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
    
    //hex4
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(.0,-1.));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
    
    //hex5
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(-1.,-.5));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
    
    //hex6
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(-1.,.5));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);

    //hex7
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * float2(0.,1.));
    f = _Smooth(radius,f,.0025);

    col = mix(col,hexColor,f * rf);
}


#define _Circle(l,r,ht,s) _Smooth(len,r-ht,s) - _Smooth(len,r+ht,s) 

void circleFest(inout float3 col,in float2 uv, in float time)
{
	float len = length(uv);
    float ang = atan2(uv.y,uv.x);
    
    float3 circleCol = float3(1.,1,1);
    
    float f = (_Circle(len,.45,.003,.013)) * .15;
    col = mix(col,circleCol,f);
    
    time = -1.485 + time*2.;// * 2. + 1.4;
    
    float a = (ang + time) / TPI;
    a = (a - floor(a));
    
    f = (_Circle(len,.45,.006,.013)) *.05;
    
    float startTime = max(mod(time + HPI,TPI),PI) + HPI;
    
    float start = sin(startTime) * .5 + .5;
    
    float endTime = min(mod(time + HPI,TPI),PI) + HPI;
    
    float end = sin(endTime)*.5+.5;
    
    f *= step(a,1.-start) - step(a,end);
    col = mix(col,circleCol,f*3.5);
    
    f = (_Circle(len,.45,.003,.013)) ;
    f *= step(a,.04 + sin(time) * .01) - step(a,0.);
   
    col = mix(col,circleCol,f);
   
    f = (_Circle(len,.62,.003,.013)) ;
    col = mix(col,circleCol,f*.25);
    
    f = (_Circle(len,.62,.003,.013)) ;
    
    time += 1.;
    time = GetGain(fract(time/TPI),.25) * TPI;
    a = (ang - time - 1.5) / TPI;
    a += sin(time) * .15;
    a = (a - floor(a)) ;
   	//a = GetBias(a,.65);
    f *= step(a,.03 ) - step(a,0.);
    col = mix(col,circleCol,f);
    
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 1.0 - pixel.texcoord.xy*2.0;

	float time = gameTime.w;

    uv *= 0.8;
    float3 col = float3(.0,.0,.0) ;
    
    time = time + 1.1;
    
    hexFest(col,uv,time);
    circleFest(col,uv,time);

	fragment.color = float4(col,1.0);

	return fragment;
}
