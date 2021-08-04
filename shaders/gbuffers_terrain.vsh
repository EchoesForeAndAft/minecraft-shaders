#version 130

/* INPUTS */
in vec4 at_tangent;

/* OUTPUTS */
out vec2 io_TextureCoord;
out vec2 io_LightmapCoord;
out vec4 io_VertexColor;
out mat3 io_TbnMatrix;

void main()
{
	gl_Position = ftransform();
	io_TextureCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	io_LightmapCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	io_VertexColor = gl_Color;
	
	vec3 tangent	= gl_NormalMatrix * (at_tangent.xyz / at_tangent.w);
	vec3 normal		= gl_NormalMatrix * gl_Normal;
	vec3 bitangent	= cross(tangent, normal);

	io_TbnMatrix = mat3(tangent, bitangent, normal);
}
