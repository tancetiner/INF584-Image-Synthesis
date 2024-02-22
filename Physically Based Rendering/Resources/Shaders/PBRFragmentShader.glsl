#version 410 core // Minimal GL version support expected from the GPU

in vec3 fNormal; // Shader input, linearly interpolated by default from the previous stage (here the vertex shader)
in vec3 fPosition; // Shader input, linearly interpolated by default from the previous stage (here the vertex shader)
out vec4 colorResponse; // Shader output: the color response attached to this fragment

struct DirectionalLightSource {
	vec3 direction;
	vec3 color;
	float intensity;
}; 

struct PointLightSource {
	vec3 position;
	vec3 color;
	float intensity;
    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;
};

struct Material {
	vec3 albedo;
	float roughness;
	float metallicness;
};


#define MAX_LIGHTS 3
#define M_PI 3.14159
uniform DirectionalLightSource[1] directionalLights;
uniform PointLightSource[MAX_LIGHTS] pointLights;
uniform Material material;
uniform mat4 modelViewMat;

float GGX_Distribution(vec3 N, vec3 H, float roughness) {
	float a = roughness * roughness;
	float NdotH = max(dot(N, H), 0.0);

	float denom = 1.0 + NdotH * NdotH * (a - 1.0);
	return a / (M_PI * denom * denom);
}

float GGX_Geometry(vec3 N, vec3 V, vec3 L, float roughness) {
	float k = roughness * roughness / 2.0;

	float NdotV = max(dot(N, V), 0.0);
	float NdotL = max(dot(N, L), 0.0);

	float G1 = 2.0 * NdotV / (NdotV + sqrt(roughness * roughness + (1.0 - roughness * roughness) * NdotV * NdotV));
	float G2 = 2.0 * NdotL / (NdotL + sqrt(roughness * roughness + (1.0 - roughness * roughness) * NdotL * NdotL));

	return G1 * G2;
}

vec3 PBRMicrofacetBRDF(vec3 N, vec3 V, vec3 L, vec3 albedo, float roughness, float metallicness) {
	vec3 H = normalize(V + L);
	float D = GGX_Distribution(N, H, roughness);
	float G = GGX_Geometry(N, V, L, roughness);

	// Fresnel equation with Schlick's approximation
	vec3 F0 = mix(vec3(0.04), albedo, metallicness);
	vec3 F = F0 + (1.0 - F0) * pow(1.0 - dot(L, H), 5.0);

	vec3 numerator = D * G * F;
	float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001;

	return numerator / denominator;
}

void main () {
	vec3 albedo = material.albedo / M_PI;
	vec3 fragNormal = normalize(fNormal);
	vec3 fragPosition = normalize(fPosition);
	vec3 viewDir = normalize(-fragPosition);
	
	vec3 Lo = vec3(0.0);
	vec3 finalColor = vec3(0.0);

	// Directional lights
	for (int i=0 ; i < 1 ; i++) {
		vec3 lightDirection = normalize(vec3(modelViewMat * vec4(directionalLights[i].direction, 1.0)));
		vec3 lightColor = directionalLights[i].color * directionalLights[i].intensity;

		// PBR Microfacet BRDF
		vec3 specular = PBRMicrofacetBRDF(fragNormal, viewDir, lightDirection, material.albedo, material.roughness, material.metallicness);

		vec3 F0 = mix(vec3(0.04), material.albedo, material.metallicness);
		vec3 F = F0 + (1.0 - F0) * pow(1.0 - dot(lightDirection, normalize(viewDir + lightDirection)), 5.0);

		vec3 kS = F;
		vec3 kD = vec3(1.0) - kS;
		kD *= 1.0 - material.metallicness;

		const float PI = 3.14159265359;
  
		float NdotL = max(dot(fragNormal, lightDirection), 0.0);        
		Lo += (kD * material.albedo / PI + specular) * directionalLights[i].color * NdotL;
	}

	// Point lights
	for (int i=0 ; i < MAX_LIGHTS ; i++) {
		vec3 pointLightPosition = vec3(modelViewMat * vec4(pointLights[i].position, 1.0));
		vec3 lightDirection = normalize(pointLightPosition - fragPosition);
		vec3 lightColor = pointLights[i].color * pointLights[i].intensity;

		// PBR Microfacet BRDF
		vec3 specular = PBRMicrofacetBRDF(fragNormal, viewDir, lightDirection, material.albedo, material.roughness, material.metallicness);

		// Attenuation
		float distance = length(pointLightPosition - fragPosition);
		float attenuation = 1.0 / (pointLights[i].constantAttenuation + pointLights[i].linearAttenuation * distance + pointLights[i].quadraticAttenuation * distance * distance);
		vec3 radiance     = pointLights[i].color * attenuation; 

		vec3 F0 = mix(vec3(0.04), material.albedo, material.metallicness);
		vec3 F = F0 + (1.0 - F0) * pow(1.0 - dot(lightDirection, normalize(viewDir + lightDirection)), 5.0);

		vec3 kS = F;
		vec3 kD = vec3(1.0) - kS;
		kD *= 1.0 - material.metallicness;

		const float PI = 3.14159265359;
  
		float NdotL = max(dot(fragNormal, lightDirection), 0.0);        
		Lo += (kD * material.albedo / PI + specular) * radiance * NdotL;
	}

	// Set the color response
	finalColor = vec3(0.03) * material.albedo + Lo;
	colorResponse = vec4(finalColor, 1.0);
}