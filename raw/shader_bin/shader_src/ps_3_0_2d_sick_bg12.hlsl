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

float random(float2 co){
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float noise( in float2 p )
{
    p*=2.8;
    float2 i = floor( p );
    float2 f = fract( p );
	float2 u = f*f*(3.0-2.0*f);
    return mix( mix( random( i + float2(0.0,0.0) ), 
                     random( i + float2(1.0,0.0) ), u.x),
                mix( random( i + float2(0.0,1.0) ), 
                     random( i + float2(1.0,1.0) ), u.x), u.y);
}

float fbm( in float2 uv )
{	
	uv *= 5.0;
    float2x2 m = float2x2( 1.6,  1.2, -1.2,  1.6 );
    float f  = 0.5000*noise( uv );
	uv = mul(m,uv);
    f += 0.2500*noise( uv );
	uv = mul(m,uv);
    f += 0.1250*noise( uv );
	uv = mul(m,uv);
    f += 0.0625*noise( uv );
	uv = mul(m,uv);
    
	f = 0.5 + 0.5*f;
    return f;
}

float3 bg(float2 uv )
{
    float velocity = gameTime.w/1.6;
    float intensity = sin(uv.x*3.+velocity*2.)*1.1+1.5;
    uv.y -= 2.;
    float2 bp = uv+float2(-2., 0.);
    uv *= 0.6;

    //ripple
    float rb = fbm(float2(uv.x*.5-velocity*.03, uv.y))*.1;
    //rb = sqrt(rb); 
    uv += rb;

    //coloring
    float rz = fbm(uv*.9+float2(velocity*.35, 0.0));
    rz *= dot(bp*intensity,bp)+1.2;

    //bazooca line
    //rz *= sin(uv.x*.5+velocity*.8);


    float3 col = float3(0.01, 0.16, 0.42)/(.1-rz);
    return sqrt(abs(col));
}


float rectangle(float2 uv, float2 pos, float width, float height, float blur) {
    
    pos = (float2(width, height) + .01)/2. - abs(uv - pos);
    pos = smoothstep(0., blur , pos);
    return pos.x * pos.y; 
   
}

float2x2 rotate2d(float _angle){
    return float2x2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;
	
	float total = 60.;
	float minSize = 0.03;
	float maxSize = 0.08-minSize;
	
	float3 rectColor = float3(0.01, 0.26, 0.57);

	float2 uv = 1.0 - pixel.texcoord.xy * 2.0;

    uv.x *= 1.77;
    
    //bg
    float3 color = bg(uv)*(2.-abs(uv.y*2.));
    
    //rectangles
    float velX = -gameTime.w/8.;
    float velY = gameTime.w/10.;
    for(float i=0.; i<total; i++){
        float index = i/total;
        float rnd = random(float2(index,index));
        float3 pos = float3(0, 0., 0.);
        pos.x = fract(velX*rnd+index)*4.-2.0;
        pos.y = sin(index*rnd*1000.+velY) * 0.5;
        pos.z = maxSize*rnd+minSize;
        float2 uvRot = uv - pos.xy + pos.z/2.;
    	uvRot = mul(rotate2d( i+gameTime.w/2. ), uvRot);
        uvRot += pos.xy+pos.z/2.;
        float rect = rectangle(uvRot, pos.xy, pos.z, pos.z, (maxSize+minSize-pos.z)/2.);
	    color += rectColor * rect * pos.z/maxSize;
    }
    
	fragment.color = float4(color, 1.0);

	return fragment;
}
