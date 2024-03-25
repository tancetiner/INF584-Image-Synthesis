#version 410 core // Minimal GL version support expected from the GPU

const float PI = 3.14159265358979323846;
const float INV_PI = 0.31830988618379067153776752674503;

const float IOR = 1.31;

struct LightSource {
	vec3 direction;
	vec3 color;
	float intensity;
};

struct Material {
	vec3 albedo;
	float roughness;
	float metallicness;
};

const int MAX_NUM_OF_LIGHT_SOURCES = 8;

// Shader uniform variables, set from the CPU side code
uniform mat4 transInvViewMat;
uniform int numOfLightSources;
uniform LightSource lightSources[MAX_NUM_OF_LIGHT_SOURCES]; 
uniform Material material;
uniform sampler2D phasorNoiseTexture;
uniform vec2 viewportResolution;

// Shader inputs, linearly interpolated by default from the previous stage outputs (here the vertex shader)
in vec3 fPosition; 
in vec3 fNormal;
in vec2 fTexCoord;

out vec4 colorResponse; // Shader output: the color response attached to this fragment

float sqr (float x) { return x*x; }

float GGX (float NdotH, float roughness) {
	if (roughness >= 1.0) 
		return INV_PI;
	float alpha = sqr (roughness);
	float tmp = alpha / max(1e-8,(NdotH*NdotH*(sqr (alpha)-1.0)+1.0));
	return tmp * tmp * INV_PI;
}

vec3 SchlickSGFresnel (float VdotH, vec3 F0) {
	float sphg = exp2 ((-5.55473*VdotH - 6.98316) * VdotH);
	return F0 + (vec3(1.0) - F0) * sphg;
}

float smithG_GGX (float NdotV, float alphaG) {
    return 2.0/(1.0 + sqrt (1.0 + sqr (alphaG) * (1.0 - sqr (NdotV) / sqr(NdotV))));
}

float G1 (float D, float k) {
	return 1.0 / (D * (1.0-k) + k);
}

float geometry (float NdotL, float NdotV,	float roughness) {
	float k = roughness * roughness * 0.5;
	return G1(NdotL,k) * G1(NdotV,k);
}

vec3 BRDF (vec3 L, vec3 V, vec3 N, vec3 albedo, float roughness, float metallic) {
    vec3 diffuseColor = albedo * (1.0 - metallic);
	vec3 specularColor = mix(vec3(0.08), albedo, metallic);

    float NdotL = max (0.0, dot (N, L));
    float NdotV = max (0.0, dot (N, V));

    if (NdotL <= 0.0)
   	 	return vec3 (0.0); 
    
    vec3 H = normalize (L + V);
    float NdotH = max (0.0, dot (N, H));
    float VdotH = max (0.0, dot (V, H));
    
    float D = GGX (NdotH, roughness);
    vec3  F = SchlickSGFresnel (VdotH, specularColor);
    float G = geometry (NdotL, NdotV, roughness);

    vec3 fd = diffuseColor * (vec3(1.0)-specularColor) / PI;
    vec3 fs = F * D * G / (4.0);
  
    return (fd + fs);
}

vec3 computeReflectedRadiance (LightSource l, vec3 wo, vec3 n, vec3 albedo, float roughness, float metallic) {
	vec3 Li = l.color * l.intensity * PI;
	// Transform the world space light direction to view space
	vec3 wi = normalize ((transInvViewMat * vec4(-normalize (l.direction), 1.0)).xyz);
	vec3 fr = BRDF (wi, wo, n, albedo, roughness, metallic);
	return Li * fr * max (0.0, dot (wi, n));
}

vec3 pbrShading (vec3 wo, vec3 n, vec3 albedo, float roughness, float metallic) {
	vec3 radiance = vec3 (0.0);
	for (int i = 0; i < numOfLightSources; i++)
		radiance += computeReflectedRadiance (lightSources[i], wo, n, albedo, roughness, metallic);
   	return radiance; 
}

# define M_PI 3.14159265358979323846

//phasor noise parameters
float _f = 50.0;
float _b = 32.0;
float _kr;
int _impPerKernel = 16;
int _seed = 1;

int N = 15487469;
int x_;
void seed(int s){x_ = s;}
int next() { x_ *= 3039177861; x_ = x_ % N;return x_; }
float uni_0_1() {return  float(next()) / float(N);}
float uni(float min, float max){ return min + (uni_0_1() * (max - min));}


int morton(int x, int y)
{
  int z = 0;
  for (int i = 0 ; i < 32* 4 ; i++) {
    z |= ((x & (1 << i)) << i) | ((y & (1 << i)) << (i + 1));
  }
  return z;
}

vec2 phasor(vec2 x, float f, float b, float o, float phi)
{
    
    float a = exp(-M_PI * (b * b) * ((x.x * x.x) + (x.y * x.y)));
    float s = sin (2.0* M_PI * f  * (x.x*cos(o) + x.y*sin(o))+phi);
    float c = cos (2.0* M_PI * f  * (x.x*cos(o) + x.y*sin(o))+phi);
    return vec2(a*c,a*s);
}

void init_noise()
{
    _kr = sqrt(-log(0.05) / M_PI) / _b;
}

vec2 cell(ivec2 ij, vec2 uv, float f, float b)
{
	int s= morton(ij.x,ij.y) + 333;
	s = s==0? 1: s +_seed;
	seed(s);
	int impulse  =0;
	int nImpulse = _impPerKernel;
	float  cellsz = 2.0 * _kr;
	vec2 noise = vec2(0.0);
	while (impulse <= nImpulse){
		vec2 impulse_centre = vec2(uni_0_1(),uni_0_1());
		vec2 d = (uv - impulse_centre) *cellsz;
		float rp = uni(0.0,2.0*M_PI) ;
        vec2 trueUv = ((vec2(ij) + impulse_centre) *cellsz) *  viewportResolution.yy / viewportResolution.xy;
		trueUv.y = -trueUv.y;
        float o = texture(phasorNoiseTexture, trueUv).x *2.0* M_PI;
		noise += phasor(d, f, b ,o,rp );
		impulse++;
	}
	return noise;
}

vec2 eval_noise(vec2 uv, float f, float b)
{   
    init_noise();
	float cellsz = 2.0 *_kr;
	vec2 _ij = uv / cellsz;
	ivec2  ij = ivec2(_ij);
	vec2  fij = _ij - vec2(ij);
	vec2 noise = vec2(0.0);
	for (int j = -2; j <= 2; j++) {
		for (int i = -2; i <= 2; i++) {
			ivec2 nij = ivec2(i, j);
			noise += cell(ij + nij , fij - vec2(nij),f,b);
		}
	}
    return noise;
}
// _________________________________________________________

vec3 phasorNoise(vec2 uv) {
    vec2 phasorNoise = eval_noise(uv, _f, _b);
    float phi = atan(phasorNoise.y, phasorNoise.x);
    float I = length(phasorNoise);
    return vec3(sin(phi) * 0.3 + 0.5);
}


void main() {
    vec3 n = normalize(fNormal);
    vec3 wo = normalize(-fPosition);
    vec3 noiseColor = phasorNoise(fTexCoord);
    vec3 finalAlbedo = material.albedo * noiseColor;
    colorResponse = vec4(pbrShading(wo, n, finalAlbedo, material.roughness, material.metallicness), 1.0);
}