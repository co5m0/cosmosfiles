// -- CONFIGURATION --
vec4 BOLT_COLOR = vec4(0.2, 0.4, 1.0, 1.0); // Deep electric blue
const float DURATION = 0.15; // Duration of the thunder flash
const float BOLT_WIDTH = 0.0003; // Thinner main bolt (halved from 0.006)
const float GLOW_INTENSITY = 0.02; // How far the glow spreads
const float JITTER_AMPLITUDE = 0.08; // How jagged the lightning is
const float THRESHOLD_MIN_DISTANCE = 1.0; // Min distance to trigger (in cursor widths)
const float BLUR = 2.0;

// --- CONSTANTS ---
const float PI = 3.14159265359;

// --- UTILS ---
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// 1D random based on seed
float random(float seed) {
    return fract(sin(seed) * 43758.5453123);
}

// Map value from range [a, b] to [c, d]
float map(float value, float min1, float max1, float min2, float max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float segment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Main logic
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // Setup coordinates
    vec2 uv = normalize(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);

    // Get cursor positions in normalized space
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.0), normalize(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.0), normalize(iPreviousCursor.zw, 0.0));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);

    float moveDist = distance(centerCC, centerCP);
    float minDist = currentCursor.w * THRESHOLD_MIN_DISTANCE; // relative to cursor height

    // Detect if we should animate
    float timeSinceChange = iTime - iTimeCursorChange;
    
    // Only trigger on significant movement and within duration
    if (moveDist > minDist && timeSinceChange < DURATION) {
        
        // Use iTimeCursorChange as a seed so the bolt shape is constant for this specific movement
        float seed = iTimeCursorChange;
        
        // Progress of the animation (0.0 to 1.0)
        float progress = timeSinceChange / DURATION;
        
        // Fade out quickly at the end
        float fade = 1.0 - smoothstep(0.7, 1.0, progress);
        
        // Flash intensity (flicker)
        float flicker = rand(vec2(iTime, seed)) * 0.5 + 0.5;
        float intensity = fade * flicker;

        // --- Generate Lightning Bolt ---
        // We will subdivide the path from previous to current cursor
        
        vec2 start = centerCP;
        vec2 end = centerCC;
        vec2 dir = end - start;
        vec2 norm = normalize(vec2(-dir.y, dir.x)); // Perpendicular vector
        
        // Procedural jagged line: 
        // We'll define a few fixed control points based on the seed
        // Because loops can be expensive/unrolled, we'll do a fixed number of subdivisions manually or in a small loop
        
        float distToBolt = 1000.0;
        
        // Iterations for fractal generation (simulated by just adding noise offsets to segments)
        // A simple way is to iterate along the line and check distance to "jittered" segments
        
        vec2 currentPoint = start;
        const int SEGMENTS = 5; 
        
        for (int i = 1; i <= SEGMENTS; i++) {
            float t = float(i) / float(SEGMENTS);
            vec2 targetPoint = mix(start, end, t);
            
            // Add jitter to intermediate points (not start/end exactly, but end can be slightly jittered if we want, though usually it strikes the target)
            if (i < SEGMENTS) {
                float segSeed = seed + float(i) * 13.52;
                float jitter = (random(segSeed) - 0.5) * JITTER_AMPLITUDE; // -0.5 to 0.5
                
                // Jitter perpendicular to the main direction
                // Also maybe a bit of parallel jitter
                targetPoint += norm * jitter;
            }
            
            // Distance to this segment
            float d = segment(uv, currentPoint, targetPoint);
            distToBolt = min(distToBolt, d);
            
            currentPoint = targetPoint;
        }

        // --- Rendering ---
        
        // Core of the bolt
        float core = smoothstep(BOLT_WIDTH, 0.0, distToBolt);
        
        // Glow/Halo
        // 1.0 / (d + eps) style glow
        float glow = GLOW_INTENSITY / (distToBolt + 0.001);
        glow = pow(glow, 1.5) * 0.5; // Tuning the falloff
        
        // Combine core and glow
        vec3 boltColor = BOLT_COLOR.rgb;
        
        // Add random branching? (Maybe for V2, keep it simple for now)

        // Composite
        vec4 effect = vec4(boltColor, (core + glow) * intensity);
        
        // Don't draw over the current cursor text too much (optional, but usually trails are behind)
        // But lightning is bright, so maybe on top? 
        // Existing shaders punch a hole for the cursor.
        // float sdfCurrentCursor = length(max(abs(uv - centerCC) - currentCursor.zw * 0.5, 0.0));
        // effect.a *= smoothstep(0.0, 0.01, sdfCurrentCursor); // Punch hole if desired
        
        // Add to fragment color (Additative blending looks best for light)
        fragColor.rgb = clamp(fragColor.rgb + effect.rgb * effect.a, 0.0, 1.0);
    }
}
