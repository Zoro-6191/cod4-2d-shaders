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


PixelShaderInput vs_main(VertexShaderInput input)		// Writing into the struct PixelShaderInput, using struct VertexShaderInput as input
{														// Note that the function has to be called "vs_main"
	PixelShaderInput output;							

	output.position = mul(float4( input.position.xyz, 1.0f), worldViewProjectionMatrix);
		// This transforms our vertex positions from localSpace to projection / cameraSpace by multipling our local vertices with a transformation Matrix
		// Because we defined position as a float4, we also have to return a float4
		// The "w" component is more or less the depth (distance from the camera), we don´t use that on a 2d element -> so we use the default scale 1

		// output.position = mul(float4( input.position.x, input.position.y, input.position.z, 1.0f), worldViewProjectionMatrix);
		// This does exactly the same as the above one, just a different way or writing it

	output.texCoord = input.texCoord;
		// We don´t need to transform our UV´s, so output = input

    return output;
    	// After we fully initialised our PixelShaderInput struct we then return it
}