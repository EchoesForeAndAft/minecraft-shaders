#version 330

/* UNIFORMS */
uniform sampler2D lightmap;
uniform sampler2D texture;

/* INPUTS */
in vec2 io_TextureCoord;
in vec2 io_LightmapCoord;
in vec4 io_VertexColor;

/* RENDERTARGETS: 0 */
layout (location = 0) out vec4 rt_Shadow;

void main()
{
	vec4 color = texture2D(texture, io_TextureCoord) * io_VertexColor;
	rt_Shadow = color;
}
