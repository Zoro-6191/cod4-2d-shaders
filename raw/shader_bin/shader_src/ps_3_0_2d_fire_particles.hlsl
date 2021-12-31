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

float hash1_2(in float2 x)
{
 	return fract(sin(dot(x, float2(52.127, 61.2871))) * 521.582);   
}

float2 hash2_2(in float2 x)
{
    return fract(sin(mul(float2x2(20.52, 24.1994, 70.291, 80.171),x)) * 492.194);
}

//Simple interpolated noise
float2 noise2_2(float2 uv)
{
    //float2 f = fract(uv);
    float2 f = smoothstep(0.0, 1.0, fract(uv));
    
 	float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0,1);
    float2 uv10 = uv00 + float2(1,0);
    float2 uv11 = uv00 + 1.0;
    float2 v00 = hash2_2(uv00);
    float2 v01 = hash2_2(uv01);
    float2 v10 = hash2_2(uv10);
    float2 v11 = hash2_2(uv11);
    
    float2 v0 = mix(v00, v01, f.y);
    float2 v1 = mix(v10, v11, f.y);
    float2 v = mix(v0, v1, f.x);
    
    return v;
}

//Simple interpolated noise
float noise1_2(in float2 uv)
{
    float2 f = fract(uv);
    //float2 f = smoothstep(0.0, 1.0, fract(uv));
    
 	float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0,1);
    float2 uv10 = uv00 + float2(1,0);
    float2 uv11 = uv00 + 1.0;
    
    float v00 = hash1_2(uv00);
    float v01 = hash1_2(uv01);
    float v10 = hash1_2(uv10);
    float v11 = hash1_2(uv11);
    
    float v0 = mix(v00, v01, f.y);
    float v1 = mix(v10, v11, f.y);
    float v = mix(v0, v1, f.x);
    
    return v;
}

#define PI 3.1415927
#define TWO_PI 6.283185

#define ANIMATION_SPEED 1.5
#define MOVEMENT_SPEED 1.0
#define MOVEMENT_DIRECTION float2(0.7, -1.0)

#define PARTICLE_SIZE 0.009

#define PARTICLE_SCALE (float2(0.5, 1.6))
#define PARTICLE_SCALE_VAR (float2(0.25, 0.2))

#define PARTICLE_BLOOM_SCALE (float2(0.5, 0.8))
#define PARTICLE_BLOOM_SCALE_VAR (float2(0.3, 0.1))

#define SPARK_COLOR float3(1.0, 0.4, 0.05) * 1.5
#define BLOOM_COLOR float3(1.0, 0.4, 0.05) * 0.8
#define SMOKE_COLOR float3(1.0, 0.43, 0.1) * 0.8

#define SIZE_MOD 1.05
#define ALPHA_MOD 0.9
#define LAYERS_COUNT 15

float layeredNoise1_2(float2 uv, float sizeMod, float alphaMod, int layers, float animation)
{
 	float noise = 0.0;
    float alpha = 1.0;
    float size = 1.0;
    float2 offset = float2(0.,0.);
    for (int i = 0; i < 10; i++)
    {
        if (i >= layers)
			break;
        offset += hash2_2(float2(alpha, size)) * 10.0;
        
        //Adding noise with movement
     	noise += noise1_2(uv * size + gameTime.w * animation * 8.0 * MOVEMENT_DIRECTION * MOVEMENT_SPEED + offset) * alpha;
        alpha *= alphaMod;
        size *= sizeMod;
    }
    
    noise *= (1.0 - alphaMod)/(1.0 - pow(alphaMod, float(layers)));
    return noise;
}

//Rotates point around 0,0
float2 rotate( float2 po, float deg)
{
 	float s = sin(deg);
    float c = cos(deg);
    return mul(float2x2(s, c, -c, s), po);
}

//Cell center from point on the grid
float2 voronoiPointFromRoot(float2 root, float deg)
{
  	float2 po = hash2_2(root) - 0.5;
    float s = sin(deg);
    float c = cos(deg);
    po = mul(float2x2(s, c, -c, s), po) * 0.66;
    po += root + 0.5;
    return po;
}

//Voronoi cell point rotation degrees
float degFromRootUV(float2 uv)
{
 	return gameTime.w * ANIMATION_SPEED * (hash1_2(uv) - 0.5) * 2.0;   
}

float2 randomAround2_2(float2 po, float2 range, float2 uv)
{
 	return po + (hash2_2(uv) - 0.5) * range;
}

float3 fireParticles(float2 uv, float2 originalUV)
{
    float3 particles = float3(0.0,0,0);
    float2 rootUV = floor(uv);
    float deg = degFromRootUV(rootUV);
    float2 pointUV = voronoiPointFromRoot(rootUV, deg);
    float dist = 2.0;
    float distBloom = 0.0;
   
   	//UV manipulation for the faster particle movement
    float2 tempUV = uv + (noise2_2(uv * 2.0) - 0.5) * 0.1;
    tempUV += -(noise2_2(uv * 3.0 + gameTime.w) - 0.5) * 0.07;

    //Sparks sdf
    dist = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_SCALE, PARTICLE_SCALE_VAR, rootUV));
    
    //Bloom sdf
    distBloom = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_BLOOM_SCALE, PARTICLE_BLOOM_SCALE_VAR, rootUV));

    //Add sparks
    particles += (1.0 - smoothstep(PARTICLE_SIZE * 0.6, PARTICLE_SIZE * 3.0, dist)) * SPARK_COLOR;
    
    //Add bloom
    particles += pow((1.0 - smoothstep(0.0, PARTICLE_SIZE * 6.0, distBloom)) * 1.0, 3.0) * BLOOM_COLOR;

    //Upper disappear curve randomization
    float border = (hash1_2(rootUV) - 0.5) * 2.0;
 	float disappear = 1.0 - smoothstep(border, border + 0.5, originalUV.y);
	
    //Lower appear curve randomization
    border = (hash1_2(rootUV + 0.214) - 1.8) * 0.7;
    float appear = smoothstep(border, border + 0.4, originalUV.y);
    
    return particles * disappear * appear;
}


//Layering particles to imitate 3D view
float3 layeredParticles(in float2 uv, in float sizeMod, in float alphaMod, in int layers, in float smoke) 
{ 
    float3 particles = float3(0,0,0);
    float size = 1.0;
    float alpha = 1.0;
    float2 offset = float2(0.0,0);
    float2 noiseOffset;
    float2 bokehUV;
    
    for (int i = 0; i < LAYERS_COUNT; i++)
    {
        //Particle noise movement
        noiseOffset = (noise2_2(uv * size * 2.0 + 0.5) - 0.5) * 0.15;
        
        //UV with applied movement
        bokehUV = (uv * size + gameTime.w * MOVEMENT_DIRECTION * MOVEMENT_SPEED) + offset + noiseOffset; 
        
        //Adding particles								if there is more smoke, remove smaller particles
		particles += fireParticles(bokehUV, uv) * alpha * (1.0 - smoothstep(0.0, 1.0, smoke) * (float(i) / float(layers)));
        
        //Moving uv origin to avoid generating the same particles
        offset += hash2_2(float2(alpha, alpha)) * 10.0;
        
        alpha *= alphaMod;
        size *= sizeMod;
    }
    
    return particles;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

	float2 uv = 1.0 - pixel.texcoord.xy*2.0 ;
    
    float vignette = 1.0 - smoothstep(0.4, 1.4, length(uv + float2(0.0, 0.3)));
    
    uv *= 1.8;
    
    float smokeIntensity = layeredNoise1_2(uv * 10.0 + gameTime.w * 4.0 * MOVEMENT_DIRECTION * MOVEMENT_SPEED, 1.7, 0.7, 6, 0.2);
    smokeIntensity *= pow(1.0 - smoothstep(-1.0, 1.6, uv.y), 2.0); 
    float3 smoke = smokeIntensity * SMOKE_COLOR * 0.8 * vignette;
    
    //Cutting holes in smoke
    smoke *= pow(layeredNoise1_2(uv * 4.0 + gameTime.w * 0.5 * MOVEMENT_DIRECTION * MOVEMENT_SPEED, 1.8, 0.5, 3, 0.2), 2.0) * 1.5;
    
    float3 particles = layeredParticles(uv, SIZE_MOD, ALPHA_MOD, LAYERS_COUNT, smokeIntensity);
    
    float3 col = particles + smoke + SMOKE_COLOR * 0.02;
	col *= vignette;
    
    col = smoothstep(-0.08, 1.0, col);

    fragment.color = float4(col, 1.0);

	return fragment;
}
