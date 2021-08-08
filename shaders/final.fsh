#version 330

/* INPUTS */
in vec2 io_TexCoord;

/* UNIFORMS */
uniform sampler2D colortex0;
uniform float     viewWidth;
uniform float	  viewHeight;

/* RENDERTARGETS: 0 */
layout (location = 0) out vec4 rt_Color;

/* ACES Filmic tonemapping curve */
vec3 ACESFilmic(vec3 x)
{
    return clamp(( x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void main()
{
	// sRGB input
	vec3 color = texture(colortex0, io_TexCoord, 0).rgb;

	// Tonemapping
	color = ACESFilmic(color);

	// sRGB output
	rt_Color = vec4(color, 1.0);
}
