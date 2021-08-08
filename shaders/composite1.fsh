#version 330 compatibility
#extension GL_ARB_shader_image_load_store : enable

/* INPUTS */
in vec2 io_TexCoord;

/* UNIFORMS */
#include "lib/common.glsl"
#include "lib/uniforms/deferred.glsl"
#include "lib/fx/shadows.glsl"
#include "lib/coords.glsl"
#include "lib/fx/atmosphere.glsl"

layout (r32ui) uniform uimage2D colorimg2; // Luminance histogram

/* RENDERTARGETS: 0, 1 */
layout (location = 0) out vec4 rt_Color;

vec3 srgb_to_linear(vec3 srgb)
{
	return pow(srgb, vec3(2.2));
}

vec3 linear_to_srgb(vec3 linear)
{
	return pow(linear, vec3(1.0 / 2.2));
}

// Returns 'luminance' (brightness) of a colour
float GetLuma(vec3 color)
{
	// Chromaticies of the human eye
	const vec3 CHROMA = vec3(0.2125, 0.7154, 0.0721);
	// Weigh the colours against the chromaticies
	return max(0, dot(color, CHROMA));
}

// Likely small loss of floating-point precision
uint f32_to_ui8(float x)
{
	return uint(round(x * 255));
}

float ui8_to_f32(uint x)
{
	return float(x) / 255;
}

#define COMPUTE_SHADER_AUTOEXPOSURE false

float GetExposure(vec2 texCoord)
{
#if COMPUTE_SHADER_AUTOEXPOSURE
	const float EXPOSURE_ADJUST_SPEED = 0.2;

    vec3 color = texture(colortex0, io_TexCoord, 0).rgb;

	uint luma = f32_to_ui8(GetLuma(color));
	uint lumaFrequency = imageLoad(colorimg2, ivec2(luma, 0)).r;

	// Read last-stored exposure value
	float prevExposure = ui8_to_f32(imageLoad(colorimg2, ivec2(257, 0)).r);

	float average = (luma / lumaFrequency);
	float exposure = 0.5 / average;

	// Adjust to new exposure
	exposure += mix(prevExposure, exposure, EXPOSURE_ADJUST_SPEED * frameTime);

	// Store new exposure value
	imageStore(colorimg2, ivec2(257, 0), uvec4(f32_to_ui8(exposure)));

#else
	// Mip-mapped auto-exposure
    vec3 average_color = textureLod(colortex0, io_TexCoord, 5).rgb;
	float average_luma = GetLuma(srgb_to_linear(average_color));
	float exposure = 0.5 / average_luma;
	exposure = clamp(exposure, 0.0, 1.0);
#endif

	return exposure;
}

void main()
{
    vec3 color = textureLod(colortex0, io_TexCoord, 0).rgb;
	float depth = textureLod(depthtex0, io_TexCoord, 0).r;

	if (depth != 1.0)
	{
		//float fog = Fog(io_TexCoord, depth);
		color += VolumetricFog(io_TexCoord, depth);
	}

	//vec3 noise = texture2D(noisetex, io_TexCoord).rgb;
	//color = vec3(noise);

	//color *= GetExposure(io_TexCoord);
	//color = linear_to_srgb(color);

	// ensure srgb
	// bloom = mipped color * luma

	rt_Color = vec4(color, 1.0);
}
