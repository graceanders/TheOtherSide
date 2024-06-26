Shader "Unlit/ScrollEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0, 1)) = 0.25
        _CutoutThresh("Cutout Threshold", Range(0, 1.0)) = 0.2
        _Distance("Distance", Float) = 1
        _Frequency("Frequency", Range(0, 50)) = 1
        _Speed("Speed", Float) = 1
        _Amplitude("Amplitude", Range(0, 1.0)) = 1
    }
    SubShader
    {
        //Tags { "RenderType" = "Opaque" }
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _Transparency;
            float _CutoutThresh;
            float _Distance;
            float _Frequency;
            float _Speed;
            float _Amplitude;

            v2f vert (appdata v)
            {
                v2f o;

                //v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Frequency) * _Distance * _Amplitude;
                v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Frequency) * _Distance * _Amplitude;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            //float (32 bit float)
            //half (16 bit float)
            //fixed (low precision) -1 to 1
            //float4 -> half4 -> fixed4

            //Matrix
            //float4x4 -> half4x4

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb *= col.a;
                clip(col.a - 1);

                col.a = _Transparency;
                col *= _TintColor;

                clip(col.b - _CutoutThresh);

                return col;
            }
            ENDCG
        }
    }
}
