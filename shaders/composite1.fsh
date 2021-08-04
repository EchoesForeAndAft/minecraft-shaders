#version 330 compatibility
#extension GL_ARB_shader_image_load_store : enable

/* INPUTS */
in vec2 io_TexCoord;

/* UNIFORMS */
#include "lib/uniforms/deferred.glsl"
#include "lib/fx/shadows.glsl"
#include "lib/coords.glsl"
#include "lib/fx/atmosphere.glsl"

layout (r32ui) uniform uimage2D colorimg2; // Luminance histogram

/* RENDERTARGETS: 0, 1 */
layout (location = 0) out vec4 rt_Color;

void main()
{
    vec3 color = texture(colortex0, io_TexCoord, 0).rgb;
	float depth = texture(depthtex0, io_TexCoord, 0).r;

	if (depth != 1.0)
	{
		float fog = Fog(io_TexCoord, depth);
		color = mix(color, fogColor, fog);
	}

	// Auto-exposure
	#if 0
	uint luma = uint(round(255 * (max(0, dot(color, vec3(0.21, 0.71, 0.07))))));

	uint lumaFrequency = imageLoad(colorimg2, ivec2(luma, 0)).r;
	float lumaMin = float(imageLoad(colorimg2, ivec2(255, 0)).r) / 255;
	float lumaMax = float(imageLoad(colorimg2, ivec2(256, 0)).r) / 255;

	float range = lumaMax - lumaMin;
	color = pow(color, vec3(2.2)); // sRGB -> linear
	color = color * lumaMin + color * lumaMax;
	color = pow(color, -vec3(2.2)); // linear -> sRGB
	#endif

	rt_Color = vec4(color, 1.0);
}
