#define PC                      // Needed for linker
#define IS_VERTEX_SHADER 1      // Needed for the shader compiler
#define IS_PIXEL_SHADER 0       // Needed for the shader compiler
#include <shader_vars.h>        // This includes our global constants needed in every shader ( included within the download below )
                                // In there are things like: gameTime, sunPosition, samplers, transformation matrices like worldMatrix mapped to constant registers defined by the engine

struct VertexShaderInput			// This struct contains our vertex data input defined in our technique >> root\raw\techniques
{									// This uses something called SEMANTICS, which is like a pipeline into the shader 
									// >> https://docs.microsoft.com/en-us/windows/desktop/direct3dhlsl/dx-graphics-hlsl-semantics

    float4 position : POSITION;		// float4 defines the size, in this case x,y,z,w; we define the semanctic POSITION as position
	float2 texCoord : TEXCOORD0;	// float2 because we only need x y on a 2d element; this is our UV in range 0.0 - 1.0
};

struct PixelShaderInput				// This struct contains the output from the vertex shader that the pixel shader will be using
{
    float4 position : POSITION;
	float2 texCoord : TEXCOORD0;
};

PixelShaderInput vs_main(VertexShaderInput input)
{
    PixelShaderInput output;

    float2 uvAsModelSpace = input.texCoord - 0.5;
    float scaleX = 20.0;
    float scaleY = 0.0;
    float posX;
    float posY;

	posX = 250.0; // + RIGHT
	posY = 0.0; // + DOWN

    if( uvAsModelSpace.x < 0.0 )
        scaleX += -scaleX;
    if( uvAsModelSpace.y < 0.0 )
        scaleY += -scaleY;

    float tempX = input.position.x + scaleX; 
    float tempY = input.position.y + scaleY; 

    output.position = mul(float4( tempX + posX, tempY + posY, 0.0, 1.0f), worldViewProjectionMatrix);
    output.texCoord = input.texCoord;
    
    return output;
}