const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const vec2 DEFAULT_RANDOM_FROM_VEC2_PARAM = vec2(0.840,0.290);

mat2 rotate2d(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat2(
        c, -s,
        s, c
    );
}

float randomFromFloat(float seed, float param) {
  return fract(sin(seed) * param);
}
float randomFF(float seed) {
  return randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
}
float rand(float seed) {
  return randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
}
vec2 randomVec2(float seed) {
  return vec2(2.0*randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM)-1.0,
      2.0*randomFromFloat(rand(0.77*seed), DEFAULT_RANDOM_FROM_FLOAT_PARAM)-1.0);
}

float minus1to1(float value){
  return 2.0*value-1.0;
}

float noise(float seed) {
  float i = floor(seed);  // integer
  float f = fract(seed);
  return mix(rand(i), rand(i + 1.0), smoothstep(0.,1.,f));
}

float randomFromVec2WithParams(vec2 st, vec2 params, float param2) {
  return randomFromFloat(dot(st.xy, params), param2);
}
float randomFromVec2(vec2 st) {
  return randomFromVec2WithParams(st, DEFAULT_RANDOM_FROM_VEC2_PARAM, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
}
