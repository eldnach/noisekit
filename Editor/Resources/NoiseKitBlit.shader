Shader "Hidden/NoiseKitBlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
            Tags { "Queue" = "Overlay+1" }
            // No culling or depth
            Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local DEBUG
            #pragma shader_feature_local _NOISEMODE3D

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            #if _NOISEMODE3D
                Texture3D _NoiseTex3D;
                SamplerState sampler_NoiseTex3D;
            #else
                Texture2D _NoiseTex;
                SamplerState sampler_NoiseTex;
            #endif

            float _Red;
            float _Green;
            float _Blue;
            float _Alpha;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
                float toggle;
                #if _NOISEMODE3D
                    col = _NoiseTex3D.Sample(sampler_NoiseTex3D, float3(i.uv.x, i.uv.y, 0.0));
                    toggle = 1.0 - step(1.0, (_Red + _Green + _Blue) / 3.0) * _Alpha;
                #else
                    col = _NoiseTex.Sample(sampler_NoiseTex, i.uv);
                    toggle = 1.0 - step(1.0, (_Red + _Green + _Blue) / 3.0) * _Alpha;
                #endif

                col.r = (col.r * _Red) * toggle  + col.a * _Alpha;
                col.g = (col.g * _Green) * toggle + col.a * _Alpha;
                col.b = (col.b * _Blue) * toggle + col.a * _Alpha;
                col.a = 1.0;
                return col;
            }
            ENDHLSL
        }
    }
}
