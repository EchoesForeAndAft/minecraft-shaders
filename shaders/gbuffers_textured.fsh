#version 330

/* UNIFORMS */
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D normals;

/* INPUTS */
in vec2 io_TextureCoord;
in vec2 io_LightmapCoord;
in vec4 io_VertexColor;
in mat3 io_TbnMatrix;

/* RENDERTARGETS: 0, 1 */
layout (location = 0) out vec4 rt_Color;
layout (location = 1) out vec3 rt_Normal;

void main()
{
	vec4 color = texture2D(texture, io_TextureCoord) * io_VertexColor;
	color *= texture2D(lightmap, io_LightmapCoord);
	vec3 normal = texture2D(normals, io_TextureCoord).rgb;
	normal = io_TbnMatrix * normal;

	rt_Color = color;
	rt_Normal = normal * 0.5 + 0.5;
}
