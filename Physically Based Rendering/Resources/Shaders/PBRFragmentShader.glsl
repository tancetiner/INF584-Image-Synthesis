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
uniform Material material;

void main () {
	vec3 albedo = material.albedo;
	vec3 fragNormal = normalize(fNormal);
	vec3 fragPosition = normalize(fPosition);
	vec3 viewDir = normalize(-fragPosition);
	vec3 lightDirection = normalize(directionalLights[0].direction);
	vec3 lightColor = directionalLights[0].color * directionalLights[0].intensity;

	// Diffuse
	float diff = max(dot(fragNormal, lightDirection), 0.0);
	vec3 diffuse = diff * lightColor;	

	// Specular
	vec3 halfDir = normalize(viewDir + lightDirection);
	float shininess = 128.0;
	float spec = pow(max(dot(fragNormal, halfDir), 0.0), shininess);
	vec3 specular = lightColor * spec;	

	// Set the color response
	vec3 finalColor = (diffuse + specular) * albedo;
	colorResponse = vec4 (finalColor, 1.0);
}