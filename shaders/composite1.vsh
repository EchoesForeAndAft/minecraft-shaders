#version 130

/* OUTPUTS */
out vec2 io_TexCoord;

void main()
{
	gl_Position = ftransform();
	io_TexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
