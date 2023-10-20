float sdCircle( in vec2 p, in vec2 c, float r )
{
    return length(p - c) - r;
}
float sdDisc( in vec2 p, in vec2 c, float r )
{
    return length(p - c);
}
float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

float sdLine( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = dot(pa,ba)/dot(ba,ba);
    return length( pa - ba*h );
}
float sdTangentLines(vec2 uv, vec2 center, float radius, vec2 point) {
    vec2 v = point - center;
    float len_v = length(v);
    float cos_a = radius / len_v;
    float sin_a = sqrt(1.0 - cos_a * cos_a);
    vec2 u = v / len_v;
    vec2 perp_u = vec2(-u.y, u.x); // 90 degrees counterclockwise rotation
    vec2 T1 = center + radius * (cos_a * u - sin_a * perp_u);
    vec2 T2 = center + radius * (cos_a * u + sin_a * perp_u);

    // Find shortest distance from `uv` to lines P1-T1 and P1-T2
    float d1 = abs((T1.y - point.y) * uv.x - (T1.x - point.x) * uv.y + T1.x * point.y - T1.y * point.x) / length(T1 - point);
    float d2 = abs((T2.y - point.y) * uv.x - (T2.x - point.x) * uv.y + T2.x * point.y - T2.y * point.x) / length(T2 - point);

    return min(d1, d2);
}

float sdTangentLine(vec2 uv, vec2 center, float radius, vec2 point) {
    vec2 v = point - center;
    float len_v = length(v);

    // Check if the point is outside the circle
    if (len_v <= radius) {
        return 1.0e6; // Return a large positive value
    }

    float cos_a = radius / len_v;
    float sin_a = sqrt(1.0 - cos_a * cos_a);
    vec2 u = v / len_v;
    vec2 perp_u = vec2(-u.y, u.x); // 90 degrees counterclockwise rotation
    vec2 T1 = center + radius * (cos_a * u - sin_a * perp_u);

    // Compute signed distance from `uv` to line P1-T1
    float d = (T1.y - point.y) * uv.x - (T1.x - point.x) * uv.y + T1.x * point.y - T1.y * point.x;

    // Assign a sign to d based on which side of the line uv is on
    float side = sign((uv.x - point.x) * (T1.y - point.y) - (uv.y - point.y) * (T1.x - point.x));
    //d *= side;

    return - d / length(T1 - point);
}

