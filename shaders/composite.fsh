#version 330

#include "lib/common.glsl"
#include "lib/uniforms/deferred.glsl"
#include "lib/fx/shadows.glsl"
#include "lib/coords.glsl"

/* INPUTS */
in vec2 io_TexCoord;

/* RENDERTARGETS: 0 */
layout (location = 0) out vec3 rt_Color;


// DO BILINEAR AND ROUND FOR BETTER PIXEL SHADOWS
float GetShadow(vec2 texCoord, float depth)
{
    vec4 shadowCoord = ViewToWorldSpace(ScreenToViewSpace(texCoord, depth));

#ifdef PIXEL_SHADOWS
	shadowCoord.xyz = round(shadowCoord.xyz * PIXEL_SHADOWS_RESOLUTION) / PIXEL_SHADOWS_RESOLUTION;
#endif

    shadowCoord.xyz -= cameraPosition;
    shadowCoord = shadowModelView * vec4(shadowCoord.xyz, 1.0);
    shadowCoord = shadowProjection * vec4(shadowCoord.xyz, 1.0);

	shadowCoord.xyz = DistortShadowCoord(shadowCoord.xyz);

    shadowCoord.xyz = shadowCoord.xyz * 0.5 + 0.5;

#ifdef PIXEL_SHADOWS
    float shadowDepth = texelFetch(shadowtex0, ivec2(shadowCoord.xy * shadowMapResolution), 0).r;
#else
	float shadowDepth = texture(shadowtex0, shadowCoord.xy, 0).r;
#endif

	return shadowCoord.z < shadowDepth ? 1.0 : 0.0;
}

void main()
{
    float depth = texture(depthtex0, io_TexCoord, 0).r;
    if (depth == 1.0)
		discard;

	vec3 color = texture(colortex0, io_TexCoord, 0).rgb;
	vec3 normal = texture(colortex1, io_TexCoord, 0).rgb * 2.0 - 1.0;

	const int specularSharpness = 8;
	const float specularStrength = 1.0;

    const float ambient = 0.4;
	float lighting = ambient;

	float shadow = GetShadow(io_TexCoord, depth);
	if (shadow > 0.0)
	{
		vec3 fragPosition = ScreenToViewSpace(io_TexCoord, depth).xyz;

		vec3 lightDirection = shadowLightPosition * -0.01;
		vec3 viewDirection = normalize(fragPosition);

		float diffuse = max(0.0, dot(-normal, lightDirection));

		vec3 halfway = normalize(-viewDirection + -lightDirection);
		float specular = pow(max(0.0, dot(halfway, normal)), specularSharpness) * specularStrength;

		lighting += (diffuse + specular) * shadow;
	}

	color *= lighting;

	rt_Color = color;
}
