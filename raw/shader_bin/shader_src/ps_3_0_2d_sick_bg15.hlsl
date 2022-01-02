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
  

float4 permute(float4 x){return mod(((x*34.0)+1.0)*x, 289.0);}

float4 taylorInvSqrt(float4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(float3 v){ 
const float2  C = float2(1.0/6.0, 1.0/3.0) ;
const float4  D = float4(0.0, 0.5, 1.0, 2.0);

  // First corner
float3 i  = floor(v + dot(v, C.yyy) );
float3 x0 =   v - i + dot(i, C.xxx) ;

  // Other corners
float3 g = step(x0.yzx, x0.xyz);
float3 l = 1.0 - g;
float3 i1 = min( g.xyz, l.zxy );
float3 i2 = max( g.xyz, l.zxy );

    //  x0 = x0 - 0. + 0.0 * C 
float3 x1 = x0 - i1 + 1.0 * C.xxx;
float3 x2 = x0 - i2 + 2.0 * C.xxx;
float3 x3 = x0 - 1. + 3.0 * C.xxx;

  // Permutations
i = mod(i, 289.0 ); 
float4 p = permute( permute( permute( 
               i.z + float4(0.0, i1.z, i2.z, 1.0 ))
             + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
             + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

  // Gradients
  // ( N*N points uniformly over a square, mapped onto an octahedron.)
    float n_ = 1.0/7.0; // N=7
    float3  ns = n_ * D.wyz - D.xzx;

    float4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    float4 x = x_ *ns.x + ns.yyyy;
    float4 y = y_ *ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4( x.xy, y.xy );
    float4 b1 = float4( x.zw, y.zw );

    float4 s0 = floor(b0)*2.0 + 1.0;
    float4 s1 = floor(b1)*2.0 + 1.0;
    float4 sh = -step(h, float4(0,0,0,0));

    float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    float3 p0 = float3(a0.xy,h.x);
    float3 p1 = float3(a0.zw,h.y);
    float3 p2 = float3(a1.xy,h.z);
    float3 p3 = float3(a1.zw,h.w);

  //Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

  // Mix final noise value
    float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
                                  dot(p2,x2), dot(p3,x3) ) );
  }

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 0.7 - pixel.texcoord.xy * 1.4;
	uv.x = uv.x*1.77;

	uv.y += 0.7;

	float scale = 0.5;
	float rate = 10.0;

	float t = gameTime.w/rate;

	float result = 0.0;

	//octaves
	for (float i = 0.0; i < 5.0; i++){
	result += snoise(float3((uv.x*2.0)/scale, (uv.y - t)/scale, t*5.0))/pow(2.0, i);
		scale /= 2.0;
	}
	result = (result + 2.0)/4.0;

	//powers for steeper curves
	float p1 = pow(abs(uv.y), 1.7);
	float p2 = 8.0*(1.0 - p1);
	result = pow(abs(result), 8.0 - p2);

	//power for coloring
	float g = pow(result, 6.0);
	fragment.color = float4(result*(1.0-uv.x), g, result*uv.x*0.5, 1.0);

	return fragment;
}
