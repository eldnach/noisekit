# NoiseKit - Procedural Volumetric Texture Generation 

Procedural generation of tileable volumetric textures in the Unity Editor. Choose from available noise types, edit noise properties, perform channel packing and export as 3D/2D textures.

<p align="center">
  <img width="100%" src="https://github.com/eldnach/noisekit/blob/main/.github/images/NoiseKitExample.gif?raw=true" alt="NoiseComposition">
</p>

## Requirements
NoiseKit is supported in Unity 2021 LTS and later. Compute shader support is required.
 
## Setup
1. In the Unity Editor, go to `Window > Package Manager`
2. On the top left on the Package Manager window, click on `+ > Add package from git URL...` 
3. Add the following URL "https://github.com/eldnach/noisekit.git" and click `Add`

Once installed, open the NoiseKit panel from the main toolbar: `Window > NoiseKit > Open`

## Noise Types
The following noise types are currently supported:
- Value
- Perlin
- Cellular 
- Fractal Value
- Fractal Perlin

## Controls
`Mode`: toggle between 2D and 3D noise generation.
`Noise Selection`: add or remove noise instances, and set the desired noise type.  
`Noise Editor`: control the available noise properties (per instance).  
`Channels`: add or remove noise channels, and perform channel packing.  
`Viewport`: preview the generated noise texture and per-channel masks.  
`Export`: set the exported texture's precision (8/16 bit per channel), resolution and file path.  

<p align="left">
  <img width="40%" src="https://github.com/eldnach/noisekit/blob/main/.github/images/NoiseKitControls.png?raw=true" alt="NoiseControls">
</p>

Additional noise types are pending.