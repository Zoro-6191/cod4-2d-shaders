#if defined( IS_PIXEL_SHADER ) && IS_PIXEL_SHADER
#define PIXEL_REGISTER( index ) : register( index )
#else
#define PIXEL_REGISTER( index )
#endif

#if defined( IS_VERTEX_SHADER ) && IS_VERTEX_SHADER
#define VERTEX_REGISTER( index ) : register( index )
#else
#define VERTEX_REGISTER( index )
#endif

#define SAMPLER_REGISTER( index ) : register( index )

#ifndef PS3
#define PS3_SAMPLER_REGISTER( index )
#else
#define PS3_SAMPLER_REGISTER( index ) : register( index )
#endif

#ifdef CG
#define UNROLL
#else
#define UNROLL	[unroll]
#endif

#define		LIGHT_NONE	0
#define		LIGHT_SUN	1
#define		LIGHT_SPOT	2
#define		LIGHT_OMNI	3

#define		VERTDECL_DEFAULT		0
#define		VERTDECL_SIMPLE			1

#define		FLOATZ_CLEAR_THRESHOLD	1.5e6
#define		FLOATZ_CLEAR_DEPTH		2.0e6


#define		SIZECONST_WIDTH			0
#define		SIZECONST_HEIGHT		1
#define		SIZECONST_INV_WIDTH		2
#define		SIZECONST_INV_HEIGHT	3

#define		SPOTLIGHT_DOT_SCALE		0
#define		SPOTLIGHT_DOT_BIAS		1
#define		SPOTLIGHT_EXPONENT		2
#define		SPOTLIGHT_SHADOW_FADE	3

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3
#define mix lerp
#define mod fmod
#define fract frac
//#define iGlobalTime gameTime.w
//#define iTime gameTime.w
//#define time gameTime.w

///////////////////////////////////////////////////
// MATRIX #########################################

// register matrix with a constant you dont use, cod4 will apply the correct matrix automaticly

float4x4	worldMatrix VERTEX_REGISTER( c4 ); // from object space to world space
//float4x4  inverseWorldMatrix; // not used
float4x4    inverseWorldMatrix VERTEX_REGISTER( c24 ); // camera pos in world space ( output.cameraPos = inverseWorldMatrix[3]; )
float4x4    transposeWorldMatrix; // not used           
float4x4    inverseTransposeWorldMatrix; // not used

float4x4	projectionMatrix VERTEX_REGISTER( c8 );
float4x4    inverseProjectionMatrix; // not used
float4x4    transposeProjectionMatrix; // not used
float4x4    inverseTransposeProjectionMatrix; // not used


float4x4	worldViewProjectionMatrix VERTEX_REGISTER( c0 );
float4x4    inverseWorldViewProjectionMatrix; // not used
float4x4    transposeWorldViewProjectionMatrix; // not used 
float4x4    inverseTransposeWorldViewProjectionMatrix; // not used


float4x4    viewMatrix; // not used
float4x4	inverseViewMatrix VERTEX_REGISTER( c28 );   // EYEPOS = _m30, _m31, _m32, (_m33)  || inverseViewMatrix[3] 
float4x4    transposeViewMatrix; // not used
float4x4    inverseTransposeViewMatrix; // not used


float4x4	viewProjectionMatrix VERTEX_REGISTER( c0 );
float4x4	inverseViewProjectionMatrix VERTEX_REGISTER( c4 );
float4x4    transposeViewProjectionMatrix;  // not used
float4x4    inverseTransposeViewProjectionMatrix;  // not used


float4x4	worldViewMatrix VERTEX_REGISTER( c4 );
            // float4 worldViewMatrix[3] = eyepos -> c7?
float4x4	inverseWorldViewMatrix VERTEX_REGISTER( c28 );
float4x4    transposeWorldViewMatrix; // not used
float4x4	inverseTransposeWorldViewMatrix VERTEX_REGISTER( c8 ); // used to transform the vertex normal from object space to world space


float4x4	shadowLookupMatrix VERTEX_REGISTER( c24 );
float4x4    inverseShadowLookupMatrix; // not used
float4x4    transposeShadowLookupMatrix; // not used
float4x4    inverseTransposeShadowLookupMatrix; // not used


float4x4 	worldOutdoorLookupMatrix VERTEX_REGISTER( c24 );
float4x4    inverseWorldOutdoorLookupMatrix; // not used
float4x4    transposeWorldOutdoorLookupMatrix; // not used
float4x4    inverseTransposeWorldOutdoorLookupMatrix; // not used



///////////////////////////////////////////////////

#define     eyePos inverseViewMatrix[3] 
//#define     eyeDir (inverseViewMatrix[3] - vertex.position)

float4 		lightingLookupScale PIXEL_REGISTER( c5 );
float4 		baseLightingCoords  VERTEX_REGISTER( c8 ); 
sampler 	modelLightingSampler;                       // SAMPLER_REGISTER( s4 );

float4		sunPosition         PIXEL_REGISTER( c17 );  // r_lighttweaksunposition
                                                        // sunPosition is light direction
float4		sunDiffuse          PIXEL_REGISTER( c18 );  // r_lighttweaksunlight
float4		sunSpecular         PIXEL_REGISTER( c19 );  // r_specularcolorscale


float4      pixelCostDecode;                            // not constant = no register
float4      pixelCostFracs;                             // not constant = no register
float4      debugBumpmap;                               // not constant = no register
float4      dofEquationScene;                           // not constant = no register
float4      dofEquationViewModelAndFarBlur;             // not constant = no register
float4      dofLerpBias;                                // not constant = no register
float4      dofLerpScale;                               // not constant = no register

float4		lightPosition;                              // not constant = no register
float4		lightDiffuse;                               // not constant = no register
float4		lightSpecular;                              // not constant = no register
float4		lightSpotDir;                               // not constant = no register
float4		lightSpotFactors;                           // not constant = no register
float4		lightFalloffPlacement;                      // not constant = no register

float4		spotShadowmapPixelAdjust;                   // not constant = no register


float4      distortionScale             VERTEX_REGISTER( c12 );
float4		nearPlaneOrg                VERTEX_REGISTER( c13 );
float4		nearPlaneDx                 VERTEX_REGISTER( c14 );
float4		nearPlaneDy                 VERTEX_REGISTER( c15 );

float4		glowSetup;                                  // not constant = no register
#define		GLOW_SETUP_CUTOFF				0
#define		GLOW_SETUP_CUTOFF_RESCALE		1
#define		GLOW_SETUP_DESATURATION			3
float4		glowApply;                                  // not constant = no register

// Ingame Shader Manipulation with:

// glowApply        :: Manditory -> r_glowUseTweaks 1 ( !without! r_glowTweakEnable )
// glowApply.w      :: r_glowTweakBloomIntensity0 = 0.0 - 20.0

// glowSetup        :: Manditory -> r_glowUseTweaks 1 ( !without! r_glowTweakEnable )
// glowSetup.w      :: r_glowTweakBloomDesaturation = 0.0 - 1.0          
// glowSetup.x      :: r_glowTweakBloomCutoff = 0.0 - 1.0;      

// sunSpecular.x    :: r_specularColorScale = 0.0 - 100.0; ( influenced by r_lightTweakSunLight ... default sunlight set in radiant, even when dvar > 1.0 counts as 1 )


#define		GLOW_APPLY_SKY_BLEED_INTENSITY	0
#define		GLOW_APPLY_BLOOM_INTENSITY		3

float4		fogConsts                   VERTEX_REGISTER( c21 );
float4		fogColor                    PIXEL_REGISTER( c0 ) VERTEX_REGISTER( c22 );
float4		materialColor               PIXEL_REGISTER( c1 );

float4		gameTime                    VERTEX_REGISTER( c22 );
// Notes on gameTime variable
// gameTime.w increases linearly forever, and appears to be measured in seconds.
// gameTime.x is a sin wave, amplitude approx 1, period 1.
// gameTime.y is similar, maybe a cos wave?
// gameTime.z goes from 0 to 1 linearly then pops back to 0 once per second

float4		renderTargetSize            VERTEX_REGISTER( c16 ); // USEABLE IN PIXEL (( not constant = no register ))
float4		clipSpaceLookupScale        VERTEX_REGISTER( c17 );
float4		clipSpaceLookupOffset       VERTEX_REGISTER( c18 );

float4		shadowmapSwitchPartition    PIXEL_REGISTER( c2 );
float4		shadowmapScale              PIXEL_REGISTER( c4 );
float4		shadowmapPolygonOffset      PIXEL_REGISTER( c2 );
float4		shadowParms;                // not constant = no register
float4		specularStrength;           // not used

float4		zNear                       PIXEL_REGISTER( c4 ); // ?

float4 		colorMatrixR;               // not constant = no register
float4 		colorMatrixG;               // not constant = no register
float4 		colorMatrixB;               // not constant = no register

float4 		colorTintBase;              // not constant = no register
float4 		colorTintDelta;             // not constant = no register
float4 		colorBias;                  // not constant = no register

float4		particleCloudColor          PIXEL_REGISTER( c3 );
float4		particleCloudMatrix         VERTEX_REGISTER( c16 );
float4		outdoorFeatherParms;        // not constant = no register

float4		depthFromClip               VERTEX_REGISTER( c20 ); // c20 = eyepos in cod2 
//float4		eyePosition;

#define		ENV_INTENSITY_MIN		0
#define		ENV_INTENSITY_MAX		1
#define		ENV_EXPONENT			2
#define		SUN_INTENSITY_SCALE		3

float4		envMapParms;                // not constant = no register
float4		envMapParms1;               // not constant = no register
float4		envMapParms2;               // not constant = no register
float4		envMapParms3;               // not constant = no register
float4		envMapParms4;               // not constant = no register

float4		waterMapParms;              // not used
float4      waterColor                  PIXEL_REGISTER( c6 );
float4 		featherParms                VERTEX_REGISTER( c12 ); // USEABLE IN PIXEL (( not constant = no register )) // dvar: r_outdoorFeather ???
float4		falloffParms                VERTEX_REGISTER( c13 ); // NO PIXEL
float4		falloffBeginColor           VERTEX_REGISTER( c14 ); // NO PIXEL
float4		falloffEndColor             VERTEX_REGISTER( c15 ); // NO PIXEL
float4		eyeOffsetParms              VERTEX_REGISTER( c16 ); // NO PIXEL

float4		filterTap[8]                : register( c12 );
float4 		codeMeshArg[2]              VERTEX_REGISTER( c8 );

//sampler		colorMapSampler             SAMPLER_REGISTER( s0 );
sampler		colorMapSampler;

sampler		colorMapSampler1            SAMPLER_REGISTER( s4 );
sampler		colorMapSampler2            SAMPLER_REGISTER( s5 );
sampler		colorMapSampler4;

sampler     colorMapPostSunSampler;

sampler		lightmapSamplerPrimary      SAMPLER_REGISTER( s2 );
sampler		lightmapSamplerSecondary    SAMPLER_REGISTER( s3 );

sampler		dynamicShadowSampler;       // not used
sampler		shadowCookieSampler;        // not constant = no register
sampler		shadowmapSamplerSun;        // not constant = no register
sampler		shadowmapSamplerSpot;       // not constant = no register
sampler		normalMapSampler;           // not constant = no register (( was s4 ))
sampler		normalMapSampler1;          // not used
sampler		normalMapSampler2;          // not used
sampler		normalMapSampler3;          // not used
sampler		normalMapSampler4;          // not used
sampler		specularMapSampler;         // not constant = no register
sampler		specularMapSampler1;        // not used
sampler		specularMapSampler2;        // not used
sampler		specularMapSampler3;        // not used
sampler		specularMapSampler4;        // not used
sampler		specularitySampler;         // not used
sampler		cinematicYSampler;          // not constant = no register
sampler		cinematicCrSampler;         // not constant = no register
sampler		cinematicCbSampler;         // not constant = no register
sampler		cinematicASampler;          // not constant = no register
sampler		attenuationSampler;         // not constant = no register

// stuff from linker
sampler     feedbackSampler;


samplerCUBE	skyMapSampler;              // not constant = no register
samplerCUBE	cubeMapSampler;             // not used ?
samplerCUBE	reflectionProbeSampler      SAMPLER_REGISTER( s1 );

sampler		floatZSampler;              // not constant = no register
sampler		processedFloatZSampler;     // not used
sampler		rawFloatZSampler;           // not constant = no register

sampler 	outdoorMapSampler;          // not constant = no register
sampler 	lookupMapSampler;           // not constant = no register   

sampler 	blurSampler;                // not used

sampler		detailMapSampler;           // not constant = no register  
sampler		detailMapSampler1;          // not used    
sampler		detailMapSampler2;          // not used
sampler		detailMapSampler3;          // not used
sampler		detailMapSampler4;          // not used
float4		detailScale                 VERTEX_REGISTER( c12 ); // USEABLE IN PIXEL (( not constant = no register ))
float4		detailScale1;               // not used    
float4		detailScale2;               // not used    
float4		detailScale3;               // not used    
float4		detailScale4;               // not used    

float4		colorTint;                  // not used    
float4		colorTint1;                 // not used    
float4		colorTint2;                 // not used    
float4		colorTint3;                 // not used    
float4		colorTint4;                 // not used    
