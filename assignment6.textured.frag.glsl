#version 300 es

#define MAX_LIGHTS 16

// Fragment shaders don't have a default precision so we need
// to pick one. mediump is a good default. It means "medium precision".
precision mediump float;

uniform bool u_show_normals;

// struct definitions
struct AmbientLight {
    vec3 color;
    float intensity;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
};

struct Material {
    vec3 kA;
    vec3 kD;
    vec3 kS;
    float shininess;
    sampler2D map_kD;
    sampler2D map_nS;
    sampler2D map_norm;
};

// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// camera position in world space
uniform vec3 u_eye;

// with webgl 2, we now have to define an out that will be the color of the fragment
out vec4 o_fragColor;

// received from vertex stage
// TODO: Create variables to receive from the vertex stage
in vec3 vert_position;
in vec2 text_coord;
in mat3 mat_TBN;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {
    // TODO: Implement this
    // TODO: Include the material's map_kD to scale kA and to provide texture even in unlit areas
    // NOTE: We could use a separate map_kA for this, but most of the time we just want the same texture in unlit areas
    // HINT: Refer to http://paulbourke.net/dataformats/mtl/ for details
    // HINT: Parts of ./shaders/phong.frag.glsl can be re-used here

    return (material.kA * texture(material.map_kD, text_coord).rgb * light.intensity * light.color);
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    // TODO: Implement this
    // TODO: Use the material's map_kD and map_nS to scale kD and shininess
    // HINT: The darker pixels in the roughness map (map_nS) are the less shiny it should be
    // HINT: Refer to http://paulbourke.net/dataformats/mtl/ for details
    // HINT: Parts of ./shaders/phong.frag.glsl can be re-used here
    vec3 L = normalize(-light.direction);
    vec3 N = normalize(normal);
    vec3 V = normalize(eye - vertex_position);
    vec3 R = normalize(-reflect(L, N));
    vec3 diffuse_I = material.kD * light.intensity * max(dot(N, L), 0.0) * texture(material.map_kD, text_coord).rgb;
    vec3 spec_I = material.kS * light.intensity * pow(max(dot(R, V), 0.0), material.shininess) * texture(material.map_nS, text_coord).rgb;
    
    return (diffuse_I + spec_I) * light.color;
}

// Shades a point light and returns its contribution
vec3 shadePointLight(Material material, PointLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    // TODO: Implement this
    // TODO: Use the material's map_kD and map_nS to scale kD and shininess
    // HINT: The darker pixels in the roughness map (map_nS) are the less shiny it should be
    // HINT: Refer to http://paulbourke.net/dataformats/mtl/ for details
    // HINT: Parts of ./shaders/phong.frag.glsl can be re-used here
    vec3 L = normalize(light.position - vertex_position);
    vec3 N = normalize(normal);
    vec3 V = normalize(eye - vertex_position);
    vec3 R = normalize(-reflect(L, N));
    float I = (1.0 / (1.0 + pow((distance(vertex_position, light.position)), 2.0))) * light.intensity;
    vec3 diffuse_I = material.kD * I * max(dot(N, L), 0.0) * texture(material.map_kD, text_coord).rgb;
    vec3 spec_I = material.kS * I * pow(max(dot(R, V), 0.0), material.shininess) * texture(material.map_nS, text_coord).rgb;
    
    return (diffuse_I + spec_I) * light.color;
}

void main() {
    // TODO: Calculate the normal from the normal map and tbn matrix to get the world normal
    vec3 normal = texture(u_material.map_norm, text_coord).rgb;
    normal = normal * 2.0 - 1.0;
    normal = normalize(mat_TBN * normal);

    // if we only want to visualize the normals, no further computations are needed
    // !do not change this code!
    if (u_show_normals == true) {
        o_fragColor = vec4(normal, 1.0);
        return;
    }

    // we start at 0.0 contribution for this vertex
    vec3 light_contribution = vec3(0.0);

    // iterate over all possible lights and add their contribution
    for(int i = 0; i < MAX_LIGHTS; i++) {
        // TODO: Call your shading functions here like you did in A5
        // shade each component of Intensity
        vec3 Ia = shadeAmbientLight(u_material, u_lights_ambient[i]);
        vec3 I_direct = shadeDirectionalLight(u_material, u_lights_directional[i], normal, u_eye, vert_position);
        vec3 I_point = shadePointLight(u_material, u_lights_point[i], normal, u_eye, vert_position);
        // collect contribution of each
        light_contribution += (Ia + I_direct + I_point);
    }

    o_fragColor = vec4(light_contribution, 1.0);
}