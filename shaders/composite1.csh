#version 460
#extension GL_ARB_shader_image_load_store : enable

#if COMPUTE_SHADER_AUTOEXPOSURE
layout (rgba8) uniform image2D colorimg0; // Color buffer
layout (r32ui) uniform uimage2D colorimg2; // Luminance histogram

// Compute shader config
layout (local_size_x = 16, local_size_y = 16) in;
const vec2 workGroupsRender = vec2(1.0, 1.0); // compute once per pixel

// Human eye chromaticies
const vec3 CHROMA = vec3(0.2125, 0.7154, 0.0721);

void main()
{
	// Get luma of current fragment
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	vec3 color = imageLoad(colorimg0, coord).rgb;

	uint bin_index = uint(round(255 * (max(0, dot(color, CHROMA)))));

	// Count frequency of luma for current fragment
	uint lumaCount = imageLoad(colorimg2, ivec2(bin_index, 0)).r;
	lumaCount++;
	imageStore(colorimg2, ivec2(bin_index, 0), uvec4(lumaCount));
}
#endif

// Lmax = 9.6 * Lavg
