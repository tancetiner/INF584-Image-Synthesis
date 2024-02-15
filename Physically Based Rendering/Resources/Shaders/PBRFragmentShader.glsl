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
};


#define MAX_LIGHTS 1
uniform DirectionalLightSource[MAX_LIGHTS] directionalLights;
uniform PointLightSource[MAX_LIGHTS] pointLights;
uniform Material material;

void main () {
	vec3 albedo = material.albedo;
	vec3 fragNormal = normalize(fNormal);
	vec3 fragPosition = normalize(fPosition);
	vec3 viewDir = normalize(-fragPosition);

	vec3 finalColor = vec3(0.0);
	for (int i=0 ; i < MAX_LIGHTS ; i++) {
		vec3 lightDirection = normalize(directionalLights[i].direction);
		vec3 lightColor = directionalLights[i].color * directionalLights[i].intensity;

		// Diffuse
		float diff = max(dot(fragNormal, lightDirection), 0.0);
		vec3 diffuse = diff * lightColor;	

		// Specular
		vec3 halfDir = normalize(viewDir + lightDirection);
		float shininess = 128.0;
		float spec = pow(max(dot(fragNormal, halfDir), 0.0), shininess);
		vec3 specular = lightColor * spec;	

		// Set the color response
		finalColor += (diffuse + specular) * albedo;
	}

	// Point light
	for (int i=0 ; i < MAX_LIGHTS ; i++) {
		vec3 lightDirection = normalize(pointLights[i].position - fragPosition);
		vec3 lightColor = pointLights[i].color * pointLights[i].intensity;

		// Diffuse
		float diff = max(dot(fragNormal, lightDirection), 0.0);
		vec3 diffuse = diff * lightColor;	

		// Specular
		vec3 halfDir = normalize(viewDir + lightDirection);
		float shininess = 128.0;
		float spec = pow(max(dot(fragNormal, halfDir), 0.0), shininess);
		vec3 specular = lightColor * spec;	

		// Attenuation
		float distance = length(pointLights[i].position - fragPosition);
		float attenuation = 1.0 / (pointLights[i].constantAttenuation + pointLights[i].linearAttenuation * distance + pointLights[i].quadraticAttenuation * distance * distance);

		// Set the color response
		finalColor += (diffuse + specular) * albedo * attenuation;
	}

	// Set the color response
	colorResponse = vec4 (finalColor, 1.0);
}