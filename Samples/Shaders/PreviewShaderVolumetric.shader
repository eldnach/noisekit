Shader "Unlit/PreviewShaderVoumetric"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _StepSize("Step Size", float) = 0.01
        _Alpha("Alpha", float) = 1.0
        _VolScale("VolumeScale", float) = 1.0

    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend One OneMinusSrcAlpha
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define STEPS 512
            #define EPSILON 0.001f

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 wPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            Texture3D _MainTex;
            SamplerState sampler_MainTex;
            float4  _MainTex_ST;
            float _StepSize;
            float _Alpha;
            float _VolScale;

            v2f vert (appdata v)
            {
                v2f o;

                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityWorldToClipPos(o.wPos);
                return o;
            }

            float4 BlendUnder(float4 color, float4 newColor)
            {
                color.rgb += (1.0 - color.a) * newColor.a * newColor.rgb;
                color.a += (1.0 - color.a) * newColor.a;
                return color;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                float3 fragWorldPos = i.wPos;
                float3 camWorldPos = _WorldSpaceCameraPos;
                float3 cam2frag = (fragWorldPos - camWorldPos);
                float3 rayDir = (cam2frag) / length(cam2frag);

                float4 col = float4(0.0, 0.0, 0.0, 0.0);
                float3 rayPos = fragWorldPos;

                for (int i = 0; i < STEPS; i++) {
                    if (max(abs(rayPos.x), max(abs(rayPos.y), abs(rayPos.z))) < (_VolScale * 0.5) + EPSILON)
                    {
                        float4 sampl = _MainTex.Sample(sampler_MainTex, rayPos * float3(_MainTex_ST.x, _MainTex_ST.y, 1.0) + float3(_MainTex_ST.z, _MainTex_ST.w, 0.0) + float3(_Time.x * 5.0 , 0.0, 0.0));
                        sampl = min(sampl, float4(1.0, 1.0, 1.0, 1.0));
                        sampl.a *= _Alpha;
                        col = BlendUnder(col, sampl);
                        rayPos += rayDir * _StepSize;
                    }
                }
                return col;
            }
            ENDCG
        }
    }
}
