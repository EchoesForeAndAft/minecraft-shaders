#version 130
#include "lib/fx/shadows.glsl"

/* INPUTS */
in vec4 mc_Entity;

/* OUTPUTS */
out vec2 io_TextureCoord;
out vec2 io_LightmapCoord;
out vec4 io_VertexColor;

void main()
{
	io_TextureCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	io_LightmapCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	io_VertexColor = gl_Color;

	gl_Position = ftransform();
	gl_Position.xyz = DistortShadowCoord(gl_Position.xyz);
	gl_Position.z += SHADOW_MAP_BIAS;
}
