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

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 0.7 - pixel.texcoord.xy * 1.4;

	uv.x = uv.x*1.77;

	float time = gameTime.w*2.0;
    
    float3 color = float3(0,0,0);

	float fRadius = 0.05;
	int bubles = 64;

    // bubbles
    for (int i=0; i < bubles; i++ ) {
            // bubble seeds
        float pha = tan(float(i)*6.+1.0)*0.5 + 0.5;
        float siz = pow( cos(float(i)*2.4+5.0)*0.5 + 0.5, 4.0 );
        float pox = cos(float(i)*3.55+4.1);
        
            // buble size, position and color
        float rad = fRadius + sin(float(i))*0.12+0.08;
        float2  pos = float2( pox+sin(time/15.+pha+siz), -1.0-rad + (2.0+2.0*rad)
                         *mod(pha+0.1*(time/5.)*(0.2+0.8*siz),1.0)) * float2(1.0, 1.0);
        float dis = length( uv - pos );
        float3  col = mix( float3(0.1, 0.2, 0.8), float3(0.2,0.8,0.6), 0.5+0.5*sin(float(i)*sin(time*pox*0.03)+1.9));
        
            // render
        color += col.xyz *(1.- smoothstep( rad*(0.65+0.20*sin(pox*time)), rad, dis )) * (1.0 - cos(pox*time));
    }

    fragment.color = float4(color * 0.3,1.0);

	return fragment;
}
