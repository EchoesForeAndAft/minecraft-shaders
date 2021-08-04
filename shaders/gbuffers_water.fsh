#version 330

#include "lib/uniforms/gbuffer.glsl"
#include "lib/coords.glsl"

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
	color.rgb *= texture2D(lightmap, io_LightmapCoord).rgb;

	vec3 normal = texture2D(normals, io_TextureCoord, 0).rgb;
	normal = io_TbnMatrix * normal;

/*	vec2 screenCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
	float depth = texture2D(depthtex1, screenCoord).r;

    // Normalize and invert direction
	vec3 lightDirection = shadowLightPosition * -0.01;
	vec3 viewDirection = normalize(ScreenToViewSpace(screenCoord, depth).xyz);

	vec3 halfway = normalize(lightDirection + viewDirection);
	float specular = pow(max(0.0, dot(-halfway, normal)), 32);

	color.rgb = vec3(specular);
	color.a = 1.0;*/

	rt_Color = color;
	rt_Normal = normal * 0.5 + 0.5;
}
