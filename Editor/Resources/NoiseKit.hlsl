
float random2D(float2 xy, float2 dir)
{
    float val = dot(sin(xy), dir);
    return frac(14129.124 * sin(val));
}

float2 random2Df2(float2 xy, float2 dir)
{
    float a = random2D(xy, float2(7.129, 69.169) + dir);
    float b = random2D(xy, float2(5.125, 17.321) + dir);
    float2 c = float2(a, b);
    return c;
}

float random3D(float3 xyz, float3 dir)
{
    float val = dot(sin(xyz), dir);
    return frac(14129.124 * sin(val));
}

float3 random3Df3(float3 xyz, float3 dir)
{
    float a = random3D(xyz, float3(7.129, 69.169, 25.315) + dir);
    float b = random3D(xyz, float3(5.125, 17.321, 41.129) + dir);
    float c = random3D(xyz, float3(9.125, 25.321, 6.129) + dir);
    float3 d = float3(a, b, c);
    return d;
}

float remap(float x, float a, float b, float c, float d)
{
    return (((x - a) / (b - a)) * (d - c)) + c;
}

float sampleBezier(float t, float a, float b, float c)
{
    float val = (1.0f - t) * (1.0f - t) * a + 2.0f * (1.0f - t) * t * b + t * t * c;
    return val;
}


float valueNoise2D(float2 uv, float2 dir, float2 period, float cp0, float cp1, float cp2)
{

    float2 nfc = frac(uv);
    nfc = lerp(nfc * nfc,  1 - (1 - nfc) * (1 - nfc), nfc);

    float2 btmCell = floor(uv);
    float2 topCell = ceil(uv);

    btmCell = (btmCell % period + period) % period;
    topCell = (topCell % period + period) % period;

    float2 bl = float2(btmCell.x, btmCell.y);
    float2 br = float2(topCell.x, btmCell.y);
    float2 tl = float2(btmCell.x, topCell.y);
    float2 tr = float2(topCell.x, topCell.y);

    float2 noiseDir = float2(8.129, 69.169) + dir;
    float a = random2D(bl, noiseDir);
    float b = random2D(br, noiseDir);
    float c = random2D(tl, noiseDir);
    float d = random2D(tr, noiseDir);
   
    float bottom = lerp(a, b, nfc.x);
    float top = lerp(c, d, nfc.x);
    float noise = lerp(bottom, top, nfc.y);
    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float valueNoise3D(float3 uv, float3 dir, float3 period, float cp0, float cp1, float cp2)
{
    float3 nfc = frac(uv);
    nfc = lerp(nfc * nfc, 1 - (1 - nfc) * (1 - nfc), nfc);

    float3 btmCell = floor(uv);
    float3 topCell = ceil(uv);

    btmCell = (btmCell % period + period) % period;
    topCell = (topCell % period + period) % period;

    float3 blF = float3(btmCell.x, btmCell.y, btmCell.z);
    float3 brF = float3(topCell.x, btmCell.y, btmCell.z);
    float3 tlF = float3(btmCell.x, topCell.y, btmCell.z);
    float3 trF = float3(topCell.x, topCell.y, btmCell.z);
    float3 blB = float3(btmCell.x, btmCell.y, topCell.z);
    float3 brB = float3(topCell.x, btmCell.y, topCell.z);
    float3 tlB = float3(btmCell.x, topCell.y, topCell.z);
    float3 trB = float3(topCell.x, topCell.y, topCell.z);

    float3 noiseDir = float3(8.129, 69.169, 12.495) + dir;
    float a = random3D(blF, noiseDir);
    float b = random3D(brF, noiseDir);
    float c = random3D(tlF, noiseDir);
    float d = random3D(trF, noiseDir);
    float e = random3D(blB, noiseDir);
    float f = random3D(brB, noiseDir);
    float g = random3D(tlB, noiseDir);
    float h = random3D(trB, noiseDir);

    float bottomF = lerp(a, b, nfc.x);
    float topF = lerp(c, d, nfc.x);
    float noiseF = lerp(bottomF, topF, nfc.y);

    float bottomB = lerp(e, f, nfc.x);
    float topB = lerp(g, h, nfc.x);
    float noiseB = lerp(bottomB, topB, nfc.y);

    float noise = lerp(noiseF, noiseB, nfc.z);

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float perlinNoise2D(float2 uv, float2 dir, float2 period, float cp0, float cp1, float cp2)
{
    float2 btmCell = floor(uv);
    float2 topCell = ceil(uv);

    btmCell = (btmCell % period + period) % period;
    topCell = (topCell % period + period) % period;

    float2 bl = float2(btmCell.x, btmCell.y);
    float2 br = float2(topCell.x, btmCell.y);
    float2 tl = float2(btmCell.x, topCell.y);
    float2 tr = float2(topCell.x, topCell.y);

    float2 noiseDir = float2(8.129, 69.169) + dir;
    float2 blDir = random2Df2(bl, noiseDir) * 2.0 - 1.0;
    float2 brDir = random2Df2(br, noiseDir) * 2.0 - 1.0;
    float2 tlDir = random2Df2(tl, noiseDir) * 2.0 - 1.0;
    float2 trDir = random2Df2(tr, noiseDir) * 2.0 - 1.0;

    float2 nfc = frac(uv);

    float blVal = dot(blDir, nfc - float2(0.0, 0.0));
    float brVal = dot(brDir, nfc - float2(1.0, 0.0));
    float tlVal = dot(tlDir, nfc - float2(0.0, 1.0));
    float trVal = dot(trDir, nfc - float2(1.0, 1.0));

    nfc = lerp(nfc * nfc,  1 - ((1 - nfc) * (1 - nfc)), nfc);
    float bottom = lerp(blVal, brVal, nfc.x);
    float top = lerp(tlVal, trVal, nfc.x);
    float noise = lerp(bottom, top, nfc.y) + 0.5;
    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float perlinNoise3D(float3 uv, float3 dir, float3 period, float cp0, float cp1, float cp2)
{
    float3 btmCell = floor(uv);
    float3 topCell = ceil(uv);

    btmCell = (btmCell % period + period) % period;
    topCell = (topCell % period + period) % period;

    float3 blF = float3(btmCell.x, btmCell.y, btmCell.z);
    float3 brF = float3(topCell.x, btmCell.y, btmCell.z);
    float3 tlF = float3(btmCell.x, topCell.y, btmCell.z);
    float3 trF = float3(topCell.x, topCell.y, btmCell.z);
    float3 blB = float3(btmCell.x, btmCell.y, topCell.z);
    float3 brB = float3(topCell.x, btmCell.y, topCell.z);
    float3 tlB = float3(btmCell.x, topCell.y, topCell.z);
    float3 trB = float3(topCell.x, topCell.y, topCell.z);

    float3 noiseDir = float3(8.129, 69.169, 34.125) + dir;
    float3 blFDir = random3Df3(blF, noiseDir) * 2.0 - 1.0;
    float3 brFDir = random3Df3(brF, noiseDir) * 2.0 - 1.0;
    float3 tlFDir = random3Df3(tlF, noiseDir) * 2.0 - 1.0;
    float3 trFDir = random3Df3(trF, noiseDir) * 2.0 - 1.0;
    float3 blBDir = random3Df3(blB, noiseDir) * 2.0 - 1.0;
    float3 brBDir = random3Df3(brB, noiseDir) * 2.0 - 1.0;
    float3 tlBDir = random3Df3(tlB, noiseDir) * 2.0 - 1.0;
    float3 trBDir = random3Df3(trB, noiseDir) * 2.0 - 1.0;

    float3 nfc = frac(uv);

    float blFVal = dot(blFDir, nfc - float3(0.0, 0.0, 0.0));
    float brFVal = dot(brFDir, nfc - float3(1.0, 0.0, 0.0));
    float tlFVal = dot(tlFDir, nfc - float3(0.0, 1.0, 0.0));
    float trFVal = dot(trFDir, nfc - float3(1.0, 1.0, 0.0));
    float blBVal = dot(blBDir, nfc - float3(0.0, 0.0, 1.0));
    float brBVal = dot(brBDir, nfc - float3(1.0, 0.0, 1.0));
    float tlBVal = dot(tlBDir, nfc - float3(0.0, 1.0, 1.0));
    float trBVal = dot(trBDir, nfc - float3(1.0, 1.0, 1.0));

    nfc = lerp(nfc * nfc, 1 - ((1 - nfc) * (1 - nfc)), nfc);
    float bottomF = lerp(blFVal, brFVal, nfc.x);
    float topF = lerp(tlFVal, trFVal, nfc.x);
    float noiseF = lerp(bottomF, topF, nfc.y) + 0.5;

    float bottomB = lerp(blBVal, brBVal, nfc.x);
    float topB = lerp(tlBVal, trBVal, nfc.x);
    float noiseB = lerp(bottomB, topB, nfc.y) + 0.5;

    float noise = lerp(noiseF, noiseB, nfc.z);

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float cellularNoise2D(float2 uv, float2 dir, float period, float cp0, float cp1, float cp2)
{
    uv = uv * period + 0.01;
    float2 cell = ceil(uv);
    float2 nfc = frac(uv);

    float minDist = 1.0;

    for (int x = -1; x <= 1; x++) { 
        for (int y = -1; y <= 1; y++) {

            float2 offset =  float2(float(x), float(y));
            float2 randomPos = offset + random2Df2( (cell + offset) % period , dir);
            float2 fragToPos = randomPos - nfc;
            float distToPos = length(fragToPos);
            minDist = min(minDist, distToPos);

            for (int z = -1; z <= 1; z++) {
                randomPos = float2(x + z * 3.0, y - 3.0);
                fragToPos = randomPos - nfc;
                distToPos = length(fragToPos);
                minDist = min(minDist, distToPos);

                randomPos =  float2(x + z * 3.0, y - 0.0);
                fragToPos = randomPos - nfc;
                distToPos = length(fragToPos);
                minDist = min(minDist, distToPos);

                randomPos = float2(x + z * 3.0, y + 3.0);
                fragToPos = randomPos - nfc;
                distToPos = length(fragToPos);
                minDist = min(minDist, distToPos);
            }       
        }
    }
    float noise = sampleBezier(minDist, cp0, cp1, cp2);
    return noise;
}

float cellularNoise3D(float3 uv, float3 dir, float period, float cp0, float cp1, float cp2)
{
    uv = uv * period + 0.01;
    float3 cell = ceil(uv);
    float3 nfc = frac(uv);

    float minDist = 1.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            for (int z = -1; z <= 1; z++) {
                float3 offset = float3(float(x), float(y), float(z));
                float3 randomPos = offset + random3Df3((cell + offset) % period, dir);
                float3 fragToPos = randomPos - nfc;
                float distToPos = length(fragToPos);
                minDist = min(minDist, distToPos);

                for (int w = -1; w <= 1; w++) {
                    randomPos = float3(x + w * 3.0, y - 3.0, z - 3.0);
                    fragToPos = randomPos - nfc;
                    distToPos = length(fragToPos);
                    minDist = min(minDist, distToPos);

                    randomPos = float3(x + w * 3.0, y - 0.0, z - 0.0);
                    fragToPos = randomPos - nfc;
                    distToPos = length(fragToPos);
                    minDist = min(minDist, distToPos);

                    randomPos = float3(x + w * 3.0, y + 3.0, z + 3.0);
                    fragToPos = randomPos - nfc;
                    distToPos = length(fragToPos);
                    minDist = min(minDist, distToPos);
                }
            }
        }
    }
    float noise = sampleBezier(minDist, cp0, cp1, cp2);
    return noise;
}


float fractalValueNoise2D( float2 uv, float2 noiseDir, float amp, float freq, float oct, float gain, float lacu, float2 period, float perst, float cp0, float cp1, float cp2)
{    
    float frequency = 2 + floor(freq) * 2;
    float amplitude = amp;
    float lacunarity = 2 + floor(lacu) * 2;
    noiseDir = float2(8.129, 69.169) + noiseDir;
    int octaves = (int)oct + 1;
    float noise = 0.0;
    float factor = 1.0;
    for (int i=0; i<octaves; i++)
    {
        noise += amplitude * valueNoise2D(uv * frequency, noiseDir, period * frequency, cp0, cp1, cp2) * factor;
        factor *= perst;
        frequency *= lacunarity;
        amplitude *= gain;  
    }

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float fractalValueNoise3D(float3 uv, float3 noiseDir, float amp, float freq, float oct, float gain, float lacu, float3 period, float perst, float cp0, float cp1, float cp2)
{
    float frequency = 2 + floor(freq) * 2;
    float amplitude = amp;
    float lacunarity = 2 + floor(lacu) * 2;
    noiseDir = float3(8.129, 69.169, 14.591) + noiseDir;
    int octaves = (int)oct + 1;
    float noise = 0.0;
    float factor = 1.0;
    for (int i = 0; i < octaves; i++)
    {
        noise += amplitude * valueNoise3D(uv * frequency, noiseDir, period * frequency, cp0, cp1, cp2) * factor;
        factor *= perst;
        frequency *= lacunarity;
        amplitude *= gain;
    }

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}


float fractalPerlinNoise2D(float2 uv, float2 noiseDir, float amp, float freq, float oct, float gain, float lacu, float2 period, float perst, float cp0, float cp1, float cp2)
{    
    float frequency = 2 + floor(freq) * 2;
    float amplitude = amp;
    float lacunarity = 2 + floor(lacu) * 2;
    noiseDir = float2(8.129, 69.169) + noiseDir;
    int octaves = (int)oct + 1;
    float noise = 0.0;
    float factor = 1.0;
    for (int i = 0; i < octaves; i++)
    {
        noise += amplitude * perlinNoise2D(uv * frequency, noiseDir, period * frequency, cp0, cp1, cp2) * factor;
        factor *= perst;
        frequency *= lacunarity;
        amplitude *= gain;
    }

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}

float fractalPerlinNoise3D(float3 uv, float3 noiseDir, float amp, float freq, float oct, float gain, float lacu, float3 period, float perst, float cp0, float cp1, float cp2)
{
    float frequency = 2 + floor(freq) * 2;
    float amplitude = amp;
    float lacunarity = 2 + floor(lacu) * 2;
    noiseDir = float3(8.129, 69.169, 9.591) + noiseDir;
    int octaves = (int)oct + 1;
    float noise = 0.0;
    float factor = 1.0;
    for (int i = 0; i < octaves; i++)
    {
        noise += amplitude * perlinNoise3D(uv * frequency, noiseDir, period * frequency, cp0, cp1, cp2) * factor;
        factor *= perst;
        frequency *= lacunarity;
        amplitude *= gain;
    }

    noise = sampleBezier(noise, cp0, cp1, cp2);
    return noise;
}




