#version 300 es

// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;
in vec3 a_tangent;
in vec2 a_texture_coord;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// output to fragment stage
// TODO: Create varyings to pass data to the fragment stage (position, texture coords, and more)
out vec3 vert_position;
out vec2 text_coord;
out mat3 mat_TBN;

void main() {

    // transform a vertex from object space directly to screen space
    // the full chain of transformations is:
    // object space -{model}-> world space -{view}-> view space -{projection}-> clip space
    vec4 vertex_position_world = u_m * vec4(a_position, 1.0);

    // TODO: Construct TBN matrix from normals, tangents and bitangents
    // TODO: Use the Gram-Schmidt process to re-orthogonalize tangents
    // NOTE: Different from the book, try to do all calculations in world space using the TBN to transform normals
    // HINT: Refer to https://learnopengl.com/Advanced-Lighting/Normal-Mapping for all above

    vec3 T = normalize(vec3(u_m * vec4(a_tangent, 1.0)));
    vec3 N = normalize(vec3(u_m * vec4(a_normal, 1.0)));
    // Gram-Schmidt
    T = normalize(T - dot(T, N) * N);
    vec3 B = cross(N, T);

    mat_TBN = mat3(T, B, N);

    // TODO: Forward data to fragment stage
    vert_position = vertex_position_world.xyz;
    text_coord = a_texture_coord;

    gl_Position = u_p * u_v * vertex_position_world;
}