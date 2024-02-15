#version 410 core // Minimal GL version support expected from the GPU

in vec3 fNormal; // Shader input, linearly interpolated by default from the previous stage (here the vertex shader)
in vec3 fPosition; // Shader input, linearly interpolated by default from the previous stage (here the vertex shader)
out vec4 colorResponse; // Shader output: the color response attached to this fragment

struct LightSource {
	vec3 direction;
	vec3 color;
	float intensity;
}; 

struct Material {
	vec3 albedo;
	float roughness;
};

uniform LightSource light;
uniform Material material;

void main () {
	// vec3 N = normalize(fNormal);
	// vec3 L = normalize(-light.direction);
	// vec3 H = normalize(L + vec3(0, 0, 1));
	// float NdotL = max(dot(N, L), 0.0);
	// float NdotH = max(dot(N, H), 0.0);
	// float VdotH = max(dot(normalize(-gl_FragCoord.xyz), H), 0.0);
	// float NdotV = max(dot(N, normalize(-gl_FragCoord.xyz)), 0.0);
	// float G = min(1.0, min(2.0 * NdotH * NdotV / VdotH, 2.0 * NdotH * NdotL / VdotH));
	// float D = 1.0 / (material.roughness * material.roughness * pow(NdotH, 4.0));
	// float F = 0.5 + 0.5 * pow(1.0 - VdotH, 5.0);
	// vec3 specular = (D * F * G) / (4.0 * NdotL * NdotV);
	// colorResponse = vec4 (material.albedo * NdotL + specular, 1.0);
	colorResponse = vec4 (fNormal, 1.0);
}