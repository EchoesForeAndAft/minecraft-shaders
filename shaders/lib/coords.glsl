#if !defined(_INCLUDE_COORDS_GLSL)
#define _INCLUDE_COORDS_GLSL

#include "/lib/fx/shadows.glsl"

vec4 ScreenToViewSpace(vec2 screenCoord, float depth)
{
    vec4 viewCoord = vec4(vec3(screenCoord, depth) * 2.0 - 1.0, 1.0);
    viewCoord = gbufferProjectionInverse * viewCoord;
    viewCoord.xyz /= viewCoord.w;
    return viewCoord;
}

vec4 ViewToWorldSpace(vec4 viewCoord)
{
    vec4 worldCoord = gbufferModelViewInverse * viewCoord;
    worldCoord.xyz += cameraPosition;
    return worldCoord;
}

vec4 WorldToShadowSpace(vec4 worldCoord)
{
    vec4 shadowCoord = worldCoord;
	
    shadowCoord.xyz -= cameraPosition;
    shadowCoord = shadowModelView * vec4(shadowCoord.xyz, 1.0);
    shadowCoord = shadowProjection * vec4(shadowCoord.xyz, 1.0);

	shadowCoord.xyz = DistortShadowCoord(shadowCoord.xyz);
	
	return shadowCoord;
}

#endif
