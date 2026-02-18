// -- CONFIGURATION --
const float DURATION = 0.35;           // Life of the sparks
const int PARTICLE_COUNT = 12;         // Number of sparks per keystroke
const float GRAVITY = 2.5;             // Gravity force (positive = down, because y is usually up in these coords, wait. UV 0,0 is usually bottom-left? Let's check.)
                                       // In `normalize`: `(value * 2.0 - iResolution.xy) / iResolution.y`. Center is 0,0.
                                       // If y moves up, Gravity should be negative.
                                       // Ghostty/Terminal usually: 0,0 top-left?
                                       // In `cursor_sweep.glsl`: `vec2 v0 = vec2(..., currentCursor.y - currentCursor.w)` (Top - height).
                                       // This implies Y grows downwards? Or Y is up but the rectangle calculation subtracts height?
                                       // Standard GL coords: 0,0 is bottom-left.
                                       // Let's assume standard GL behavior (Gravity = -9.8).
                                       // However, `normalize` centers it.
                                       // Let's try negative gravity (fall down).

const float SPREAD_SPEED = 0.35;       // Speed of explosion
const float DRAG = 0.95;               // Air resistance (velocity decay)
const float SIZE_BASE = 0.0025;        // Base radius of a spark

// Colors
const vec3 COLOR_HOT = vec3(1.0, 1.0, 0.8);  // White-Yellow
const vec3 COLOR_WARM = vec3(1.0, 0.6, 0.2); // Orange
const vec3 COLOR_COLD = vec3(0.8, 0.2, 0.1); // Red-ish

// --- UTILS ---

// Standard pseudo-random 
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// 3D random for vectors
vec3 rand3(vec2 p) {
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
                   dot(p,vec2(269.5,183.3)), 
                   dot(p,vec2(419.2,371.9)) );
    return fract(sin(q)*43758.5453);
}

// Coordinate normalization (matches other shaders)
vec2 normalize_coords(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

// SDF for a circle (particle)
float sdfCircle(vec2 p, vec2 c, float r) {
    return distance(p, c) - r;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // Setup coordinates
    vec2 uv = normalize_coords(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);

    // Get cursor info
    vec4 currentCursor = vec4(normalize_coords(iCurrentCursor.xy, 1.0), normalize_coords(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize_coords(iPreviousCursor.xy, 1.0), normalize_coords(iPreviousCursor.zw, 0.0));

    // Center of current cursor
    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    // Center of previous cursor
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);

    // Movement vector
    vec2 moveDir = centerCC - centerCP;
    float moveDist = length(moveDir);
    float minDist = currentCursor.w * 0.5; // Only trigger if moved a bit (half cursor width)

    // Time progress
    float timeSinceChange = iTime - iTimeCursorChange;

    // Only render if within duration and there was a move
    if (moveDist > minDist && timeSinceChange < DURATION) {
        
        float progress = timeSinceChange / DURATION;
        float seed = iTimeCursorChange;
        
        // Accumulate light from sparks
        vec3 accumColor = vec3(0.0);
        float accumAlpha = 0.0;

        for (int i = 0; i < PARTICLE_COUNT; i++) {
            // Random properties for this particle
            vec3 rnd = rand3(vec2(seed, float(i))); // x, y, z randoms
            
            // Random angle and speed
            float angle = rnd.x * 6.28318;
            float speed = (rnd.y * 0.5 + 0.5) * SPREAD_SPEED;
            
            // Initial Velocity
            // Bias slightly opposite to movement?
            // vec2 baseVel = normalize(moveDir) * -0.2; // Backwards spray
            // Let's just do radial explosion for now, looks more "magical"
            vec2 velocity = vec2(cos(angle), sin(angle)) * speed;
            
            // Apply simple physics
            // p = p0 + v*t + 0.5*a*t^2
            // We use 'timeSinceChange' as t
            float t = timeSinceChange;
            
            // Gravity effect (downwards)
            // Assuming Y-up (standard GL), gravity is negative Y. 
            // If Y-down (screen coords), gravity is positive Y.
            // Let's assume standard physics (-y).
            vec2 pos = centerCC + velocity * t + vec2(0.0, -GRAVITY) * 0.5 * t * t;
            
            // Fade out
            // Life is random per particle?
            float life = 0.5 + 0.5 * rnd.z; // 0.5 to 1.0 of DURATION
            float pLife = clamp(progress / life, 0.0, 1.0); // 0 to 1
            float alpha = 1.0 - pow(pLife, 2.0); // Quadratic fade
            
            if (pLife >= 1.0) continue;

            // Render Particle
            float dist = distance(uv, pos);
            float radius = SIZE_BASE * (1.0 - pLife * 0.5); // Shrink slightly
            
            // Glowy blob look
            // smoothstep from radius to 0
            float particle = 1.0 - smoothstep(0.0, radius, dist);
            // Add a wider glow
            float glow = exp(-dist * 150.0) * 0.5;
            
            float intensity = particle + glow;
            
            // Color based on life (Hot -> Cold)
            vec3 pColor = mix(COLOR_HOT, COLOR_WARM, smoothstep(0.0, 0.3, pLife));
            pColor = mix(pColor, COLOR_COLD, smoothstep(0.3, 0.8, pLife));
            
            accumColor += pColor * intensity * alpha;
        }
        
        // Composite
        // Additive blending looks best for sparks
        fragColor.rgb = clamp(fragColor.rgb + accumColor, 0.0, 1.0);
    }
}
