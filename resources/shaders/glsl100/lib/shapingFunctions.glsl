float funcSharpSpike(in float x, in float sharpness) {
  return pow(min(cos(3.14 * (fract(x)-0.5)/2.0), 1.0 - abs(fract(x)-0.5)),sharpness);
}

float funcPlateau(in float x, in float flatness) {
  return (1.0-pow(abs(2.0*fract(x)-1.0),flatness));
}

float funcPlateauWithThreshold(in float x, in float flatness, in float threshold) {
  return (1.0-pow(abs((1.0-threshold/10.0)*(2.0*fract(x)-1.0)),flatness));
}
//
//          /\
//      ___/  \___
//     /          \
//    /            \
//
float funcSmoothSpike(in float x, in float plateauHeight, in float spikeSharpness, in float plateauFlatness) {
  return plateauHeight*funcPlateau(x, spikeSharpness) +
    (1.0-plateauHeight)*funcSharpSpike(x, plateauFlatness);
}

const float DEFAULT_SPIKE_SHARPNESS = 12.0;
const float DEFAULT_PLATEAU_FLATNESS = 12.0;
float funcSmoothSpikeWithDefaults(in float x, in float plateauHeight) {
  return plateauHeight*funcPlateau(x, DEFAULT_PLATEAU_FLATNESS) +
    (1.0-plateauHeight)*funcSharpSpike(x, DEFAULT_SPIKE_SHARPNESS);
}

float funcSmoothSpikeNoZeroWithDefaults(in float x, in float plateauHeight) {
  return plateauHeight*funcPlateau(x, DEFAULT_PLATEAU_FLATNESS) +
    (1.0-plateauHeight)*funcSharpSpike(x, DEFAULT_SPIKE_SHARPNESS);
}

float funcSmoothSpikeWithThresholdWithDefaults(in float x, in float plateauHeight, in float threshold) {
  return plateauHeight*funcPlateauWithThreshold(x, DEFAULT_PLATEAU_FLATNESS, threshold) +
    (1.0-plateauHeight)*funcSharpSpike(x, DEFAULT_SPIKE_SHARPNESS);
}
