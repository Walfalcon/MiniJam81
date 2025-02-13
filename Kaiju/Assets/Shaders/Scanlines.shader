﻿Shader "Unlit/Scanlines"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanLines("Scanline Texture", 2D) = "white" {}
        _Strength("Strength", Float) = 0
        _Size("size", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _ScanLines;
            float _Strength;
            int _Size;
            float4 _MainTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 scanlineUV = i.uv * (_ScreenParams.y / _Size);
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 scanlines = tex2D(_ScanLines, scanlineUV);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
               return lerp(col, col * scanlines, _Strength);
            }
            ENDCG
        }
    }
}
