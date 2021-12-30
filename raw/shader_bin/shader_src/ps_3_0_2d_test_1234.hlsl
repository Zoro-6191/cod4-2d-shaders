// * COD4-SHADERGEN - xoxor4d.github.io
// * Template used : [ps_3_0_shadergen_2d_no_image.hlsl]
// * Mat. Template : [shadergen_2d_no_image.template]

#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

// our input struct ( same as in vs obv. )
struct PixelInput
{
    float4 position     : POSITION;
	float2 texcoord 	: TEXCOORD0;
};

// output struct
struct PixelOutput
{
	float4 color        : COLOR;
};

float dseg(float2 p0, float2 p1, float2 uv, float2 ch_pos)
{
    float2 dir = normalize(p1 - p0);
    float2 cp = mul(float2x2(dir.x, dir.y, -dir.y, dir.x), (uv - ch_pos - p0));
    return distance(cp, clamp(cp, float2(0.0f, 0.0f), float2(distance(p0, p1), 0)));   
}

bool bit(int n, int b)
{
    return fmod(floor(float(n) / exp2(floor(float(b)))), 2.0f) != 0.0f;
}

float ddigit(int n, const float d, const float2 uv, inout float2 ch_pos, const float2 ch_space)
{
    float  v = 1e6;    
    float2 cp = uv - ch_pos;

    if (n == 0)     v = min(v, dseg(float2(-0.405, -1.000), float2(-0.500, -1.000), uv, ch_pos));
    if (bit(n,  0)) v = min(v, dseg(float2( 0.500,  0.063), float2( 0.500,  0.937), uv, ch_pos));
    if (bit(n,  1)) v = min(v, dseg(float2( 0.438,  1.000), float2( 0.063,  1.000), uv, ch_pos));
    if (bit(n,  2)) v = min(v, dseg(float2(-0.063,  1.000), float2(-0.438,  1.000), uv, ch_pos));
    if (bit(n,  3)) v = min(v, dseg(float2(-0.500,  0.937), float2(-0.500,  0.062), uv, ch_pos));
    if (bit(n,  4)) v = min(v, dseg(float2(-0.500, -0.063), float2(-0.500, -0.938), uv, ch_pos));
    if (bit(n,  5)) v = min(v, dseg(float2(-0.438, -1.000), float2(-0.063, -1.000), uv, ch_pos));
    if (bit(n,  6)) v = min(v, dseg(float2( 0.063, -1.000), float2( 0.438, -1.000), uv, ch_pos));
    if (bit(n,  7)) v = min(v, dseg(float2( 0.500, -0.938), float2( 0.500, -0.063), uv, ch_pos));
    if (bit(n,  8)) v = min(v, dseg(float2( 0.063,  0.000), float2( 0.438, -0.000), uv, ch_pos));
    if (bit(n,  9)) v = min(v, dseg(float2( 0.063,  0.063), float2( 0.438,  0.938), uv, ch_pos));
    if (bit(n, 10)) v = min(v, dseg(float2( 0.000,  0.063), float2( 0.000,  0.937), uv, ch_pos));
    if (bit(n, 11)) v = min(v, dseg(float2(-0.063,  0.063), float2(-0.438,  0.938), uv, ch_pos));
    if (bit(n, 12)) v = min(v, dseg(float2(-0.438,  0.000), float2(-0.063, -0.000), uv, ch_pos));
    if (bit(n, 13)) v = min(v, dseg(float2(-0.063, -0.063), float2(-0.438, -0.938), uv, ch_pos));
    if (bit(n, 14)) v = min(v, dseg(float2( 0.000, -0.938), float2( 0.000, -0.063), uv, ch_pos));
    if (bit(n, 15)) v = min(v, dseg(float2( 0.063, -0.063), float2( 0.438, -0.938), uv, ch_pos));
    
	ch_pos.x += ch_space.x;
    return min(d, v);
}

float3 hsv2rgb_smooth( float3 c )
{
    float3 rgb = clamp( abs( mod(c.x * 6.0f + float3(0.0f, 4.0f, 2.0f), 6.0f) - 3.0f) - 1.0f, 0.0f, 1.0f);

    rgb = rgb * rgb * ( 3.0f - 2.0f * rgb); // cubic smoothing    

    return c.z * mix( float3(1.0f, 1.0f, 1.0f), rgb, c.y);
}

// main ps entry, has to return the full output struct ( 1 float4 :: color r g b a )
PixelOutput ps_main( const PixelInput pixel )
{
    // define our output struct as "fragment"
    PixelOutput fragment;

 	float d = 1e6;

	float2 uv = pixel.texcoord;
	uv.y = 1.0f - uv.y;

	uv *= 18.0f;
    uv += float2(2.0f, -10.0f);

	float3 ch_color = hsv2rgb_smooth(float3(gameTime.w * 0.4f + uv.y * 0.1f, 0.5f, 1.0f));

	uv.x += 0.5f + sin(gameTime.w + uv.y * 0.7f) * 0.5f;
    uv.x += 3.0f;

	float2 ch_size  = float2(1.0f, 2.0f) * 0.6f;
	float2 ch_space = ch_size + float2(1.0f, 1.0f);
	float2 ch_start = float2(ch_space.x * 5.0f, 1.0f);
    float2 ch_pos = ch_start;

	d = ddigit(32894, d, uv, ch_pos, ch_space); 
    d = ddigit(17510, d, uv, ch_pos, ch_space); 
    d = ddigit(17414, d, uv, ch_pos, ch_space); 
    d = ddigit(4505, d, uv, ch_pos, ch_space); 
    d = ddigit(249, d, uv, ch_pos, ch_space); 
    d = ddigit(37502, d, uv, ch_pos, ch_space); 

    ch_pos = ch_start;  
	ch_pos.y -= 3.0; 

    d = ddigit(8806, d, uv, ch_pos, ch_space);
    d = ddigit(255, d, uv, ch_pos, ch_space); 
    d = ddigit(37151, d, uv, ch_pos, ch_space);
    d = ddigit(255, d, uv, ch_pos, ch_space); 
    d = ddigit(4352, d, uv, ch_pos, ch_space);
    d = ddigit(4606, d, uv, ch_pos, ch_space);
    d = ddigit(641, d, uv, ch_pos, ch_space); 
    d = ddigit(4591, d, uv, ch_pos, ch_space); 
    d = ddigit(641, d, uv, ch_pos, ch_space);
    

    float3 color = lerp(ch_color, float3(0.0f, 0.0f, 0.0f), 1.0f - (0.03f / d * 2.0f));
	fragment.color = float4(color, 1.0f);
	return fragment;
}
