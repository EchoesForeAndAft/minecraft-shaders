#if !defined(_INCLUDE_ATMOSPHERE_GLSL)
#define _INCLUDE_ATMOSPHERE_GLSL

#define VOLUMETRIC_LIGHT_SCATTERING

vec3 LightScattering(
	sampler2D skyMaskTexture,
	vec2	  texCoord,
	int		  samples	= 64,
	float	  density	= 1.0,
	float	  weight	= 0.4,
	float	  decay		= 0.95,
	float	  exposure	= 0.05
	)
{
	// View -> clip -> screen
	vec4 lightPos = gbufferProjection * vec4(shadowLightPosition, 1.0);
	lightPos.xy = lightPos.xy / lightPos.w;
	lightPos.xy = lightPos.xy * 0.5 + 0.5;

	// Scale tex coord for ray
	vec2 deltaTexCoord = (texCoord - lightPos.xy);
	deltaTexCoord *= 1.0 / samples * density;

	// Sample sky-mask with LOD 0 for faster access
	vec3 color = texture(colortex2, texCoord, 0).rgb;
	float illuminationDecay = 1.0;

	for (int i = 0; i < samples; i++)
	{
		// Next position along ray
		texCoord -= deltaTexCoord;

		// Accumulate this sample
		vec3 sample = texture(colortex2, texCoord, 0).rgb;
		sample *= illuminationDecay * weight;
		color += sample;

		// Exponential decay
		illuminationDecay *= decay;
	}

	return color * exposure;
}

vec3 VolumetricFog(in vec2 texCoord, in float depth)
{
	const int NUM_SAMPLES = 100;
	const float SAMPLE_DELTA = 1.0 / NUM_SAMPLES;
	const float DENSITY = 0.2;

	vec3 worldPos = ViewToWorldSpace(ScreenToViewSpace(texCoord, depth)).xyz;
	vec3 rayDir = normalize(worldPos - cameraPosition);
	float rayDist = length(worldPos - cameraPosition);
	vec3 rayDelta = rayDir * (rayDist / NUM_SAMPLES);

	vec3 fog = vec3(0.0);
	vec3 ray = cameraPosition;

	for (int i = 0; i < NUM_SAMPLES; i++)
	{
		vec3 shadowRay = WorldToShadowSpace(vec4(ray, 1.0)).xyz;
		shadowRay.xyz = shadowRay.xyz * 0.5 + 0.5;

		float factor = length(ray - cameraPosition);
		float weight = exp(factor / rayDist);

		float shadowDepth = texture2D(shadowtex0, shadowRay.xy, 0).r;
		float shadow = shadowRay.z < shadowDepth ? SAMPLE_DELTA : 0.0;

		fog += fogColor * shadow * weight;
		ray += rayDelta;
	}

	return fog * DENSITY;
}

float Fog(vec2 texCoord, float depth)
{
	float fogLength = gl_Fog.end - gl_Fog.start;
	float fogDepth = exp(length(ScreenToViewSpace(texCoord, depth).xyz) - gl_Fog.start);

	return min(fogDepth / fogLength, 1.0);
}

#endif
