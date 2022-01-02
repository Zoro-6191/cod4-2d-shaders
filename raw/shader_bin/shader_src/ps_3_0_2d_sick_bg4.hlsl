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

#define NOMBRE_PARTICULES 80.
#define NOMBRE_POINTS_ARBRE 100.
#define pi 3.1415926535

// fireworks

// direction giving 
float2 RandomDirectionPolar(float x) // polar coordinates
{
    float angle = fract(sin(x * 312.4) * 342.52) * 2. * pi; // pseudorandomizer
    float dist = fract(sin(x * 512.2) * 524.24);
    return float2(sin(angle), cos(angle)) * dist;
}

// explosion effect
float FireworkExplosion(float2 uv, float t, float2 position, float2 scale)
{
    uv -= position;
    uv *= scale;
    float sparks = 0.;
    for(float i = 0.; i < NOMBRE_PARTICULES; i++)
    {
        float2 direction = RandomDirectionPolar(i);
        float time = fract(gameTime.w);
        float pp = length(uv - direction * time);
    
        float brightness = mix(.0008, .002, smoothstep(.1, 0., time));
        brightness *= sin(time * 20. + i) * .5 + .5;
        sparks += brightness/pp;
    }
    return sparks;
}

// rectangle base code
float Band(float t, float start, float end, float blur)
{
    float step1 = smoothstep(start-blur, start+blur, t);
    float step2 = smoothstep(end+blur, end-blur, t);
    return step1*step2;
}

float Rectangle(float2 uv, float left, float right, float bottom, float top, float blur)
{
    float band1 = Band(uv.x, left, right, blur);
    float band2 = Band(uv.y, bottom, top, blur);
    return band1 * band2;
}

// circle base code
float Circle(float2 uv, float2 position, float radius, float blur)
{
    float dist = length(uv - position);
    float c = smoothstep(radius, radius-blur, dist);
    return c;
}

// stars
float3 Star(float2 uv, float2 position, float intensity)
{
    uv -= position;
    float3 star = float3(0,0,0);
    float p = length(uv);
    star += intensity/p;
    return star;
}

// HSV to RGB code
float3 hsv2rgb (float3 hsv) { 
	hsv.yz = clamp (hsv.yz, 0., 1.);
	return hsv.z * (1. + .63 * hsv.y * (cos (2. * 3.14159 * (hsv.x + float3 (0., 2. / 3., 1. / 3.))) - 1.));
}

// christmas tree code
float3 ChristmasTree(float2 uv, float2 position, float size, PixelInput pixel )
{
    uv -= position; // translation
    uv *= size;     // scale
    
    float lightintensity = 1. / 1500.;
    float mx = max(pixel.worldPos.x, pixel.worldPos.y);
	float2 scrs = pixel.worldPos.xy/mx;
    float2 dotpos  = float2(0,0);
    float3 col = float3(0,0,0);
    float time = gameTime.w;
    
    // tree
    float angle = NOMBRE_POINTS_ARBRE * 1.8; // angle for the conus
    for(float i = 0. ; i < NOMBRE_POINTS_ARBRE ; i++)
    {
		dotpos = float2(scrs.x / 2. + sin(i / 2. - time * .2)/(3. / (i + 1.0) * angle), scrs.y * ( (i) / NOMBRE_POINTS_ARBRE + .22) * .9);
		col += hsv2rgb(float3(1.5 * i / NOMBRE_POINTS_ARBRE + fract(time / 4.), distance(uv, dotpos) * (1. / lightintensity), lightintensity / distance(uv,dotpos)));
	}
    
    return col;
}
PixelOutput ps_main( const PixelInput pixel )
{
	PixelOutput fragment;

	float2 uv = 1.0 - pixel.worldPos.xy*1.5;
    uv.x *= 1.77;

    float3 mask = float3(0,0,0);

	float iTime = gameTime.w;
    
    // silhouettes
    mask += Rectangle(uv, -.1, 0., -.26, -.18, .02) * float3(0.196, 0.207, 0.192);
    mask += Rectangle(uv, .1, .24, -.1, -.02, .02) * float3(0.196, 0.207, 0.192);
    mask += Rectangle(uv, .42, .48, -.1, -.02, .02) * float3(0.196, 0.207, 0.192);
    mask += Rectangle(uv, .5, .6, -.1, -.06, .02) * float3(0.196, 0.207, 0.192);
    mask += Rectangle(uv, .6, .7, -.5, -.06, .02) * float3(0.196, 0.207, 0.192);

    // city buildings
    mask += Rectangle(uv, 0., .24, -.4, -.1, .002) * float3(0.623, 0.627, 0.513);
    mask += Rectangle(uv, .24, .4, -.3, .05, .002) * float3(0.420, 0.388, 0.352);
    mask += Rectangle(uv, .4, .6, -.3, -.1, .002) * float3(0.360, 0.388, 0.352);
    
    // windows
    float heightIncrement = .02;
    
    // building 1
    float3 windowColor = float3(0.960, 0.968, 0.372) * cos(iTime+uv.xyx+float3(0,2,4));
    mask += Rectangle(uv, .01, .09, -.22, -.21, .002) * windowColor;
    for(float k = 0.; k < 5.; k++)
    {
        mask += Rectangle(uv, .01, .23, -.2 + k * heightIncrement, -.19 + k * heightIncrement, .002) * windowColor;
    }
    
    // building 2
    float3 windowColor2 = float3(0.960, 0.968, 0.372) * sin(iTime+uv.xyx+float3(0,2,4));
    mask += Rectangle(uv, .25, .39, -.18, -.17, .002) * windowColor2;
    for(float j = 0.; j < 11.; j++)
    {
        mask += Rectangle(uv, .25, .39, -.18 + j * heightIncrement, -.17 + j * heightIncrement, .002) * windowColor2;
    }
    
    // building 3
    float3 windowColor3 = float3(0.960, 0.968, 0.372) * tan(iTime+uv.xyx+float3(0,2,4));
    mask += Rectangle(uv, .41, .59, -.18, -.17, .002) * windowColor3;
    for(float l = 0.; l < 4.; l++)
    {
        mask += Rectangle(uv, .41, .59, -.18 + l * heightIncrement, -.17 + l * heightIncrement, .002) * windowColor3;
    }
    
    // snow hill (yes, I know it's pure govnokod, no time to think of some better solution)
    mask += Circle(uv, float2(0.5,-2), 1.8, 0.02) * float3(0.937, 0.937, 0.901);
    mask += Circle(uv, float2(0.,-.42), 0.2, 0.02) * float3(0.925, 0.925, 0.894);
    mask += Circle(uv, float2(-.3,-.58), 0.2, 0.02) * float3(0.925, 0.925, 0.874);
    mask += Circle(uv, float2(-.2,-.52), 0.2, 0.02) * float3(0.909, 0.909, 0.850);
    mask += Circle(uv, float2(-.1,-.45), 0.2, 0.02) * float3(1., 1., 1.);
    mask += Circle(uv, float2(.1,-.42), 0.2, 0.02) * float3(0.968, 0.960, 0.933);
    mask += Circle(uv, float2(.2,-.39), 0.2, 0.02) * float3(0.964, 0.956, 0.894);
    mask += Circle(uv, float2(.3,-.38), 0.2, 0.02) * float3(0.862, 0.858, 0.815);
    mask += Circle(uv, float2(.4,-.38), 0.2, 0.02) * float3(0.952, 0.952, 0.949);
    mask += Circle(uv, float2(.5,-.38), 0.2, 0.02) * float3(0.972, 0.960, 0.866);
    mask += Circle(uv, float2(.6,-.38), 0.2, 0.02) * float3(0.999, 0.999, 0.999);
    mask += Circle(uv, float2(.7,-.40), 0.2, 0.02) * float3(0.952, 0.952, 0.945);
    
    // christmas tree
    mask += ChristmasTree(-uv, float2(.1, -.2), .9, pixel );
    
    // fireworks
    mask += FireworkExplosion(uv, fract(iTime), float2(-.1, .1), float2(3.,3.)) * float3(0.176, 0.329, 0.901);
    mask += FireworkExplosion(uv, fract(iTime), float2(.3, .2), float2(3.,3.)) * float3(0.019, 1, 0.184);
    mask += FireworkExplosion(uv, fract(iTime), float2(.7, .1), float2(4.,4.)) * float3(1, 0.149, 0.019);
    
    // stars (govnokod)
    mask += Star(uv, float2(-.75, .32), .001);
    mask += Star(uv, float2(-.1, .2), .001);
    mask += Star(uv, float2(.8, .45), .002);
    mask += Star(uv, float2(.1, .45), .0005);
    mask += Star(uv, float2(.6, .2), .002);
    mask += Star(uv, float2(-.2, 0.), .002);
    mask += Star(uv, float2(-.1, .56), .002);
    mask += Star(uv, float2(-.4, .24), .001);
    mask += Star(uv, float2(.5, .53), .001);
    mask += Star(uv, float2(.4, .2), .002);
    
    // moon
    mask += Circle(uv, float2(-.6, .3), .05, .05) * 1./mask;

    fragment.color = float4(mask,1.);

    return fragment;
}