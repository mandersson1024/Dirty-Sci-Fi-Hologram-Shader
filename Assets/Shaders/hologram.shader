
Shader "AlpacaSound/Hologram"
{
    Properties
    {
        _MainTint ("Main Tint", Color) = (21,114,178,1)
        _GlowTint ("Glow Tint", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0.1, 10.0)) = 2.0
        _Contrast ("Contrast", Range(0.1, 10.0)) = 2.0
        [NoScaleOffset] _MainTex("Main Texture", 2D) = "white" {}
        _FlickerTex("Flicker Texture", 2D) = "white" {}
        _FlickerSpeed("Flicker Speed", Range(1.0, 100.0)) = 3.0
        _FlickerRepeat("Flicker Repeat", Range(1.0, 100.0)) = 1.0
    }

    Subshader
    {
        Tags 
        { 
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "RenderType" = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM

            #include "UnityCG.cginc"
       
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _MainTint;
            uniform half4 _GlowTint;
            uniform float _RimPower;
            uniform float _Contrast;
            uniform sampler2D _MainTex;
            uniform sampler2D _FlickerTex;
            uniform float _FlickerSpeed;
            uniform float _FlickerRepeat;


            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 screenPos : VPOS; // ???
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert(appdata v, out float4 outpos : SV_POSITION)
            {
                outpos = UnityObjectToClipPos(v.vertex); // ???

                v2f o;
                o.screenPos = UnityObjectToClipPos(v.vertex); // ???
                o.uv = v.uv;
                o.normal = v.normal;
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                return o;
            }

            half4 frag(v2f i) : COLOR
            {
                half4 texcol = tex2D(_MainTex, i.uv);
                float fresnel = 1 - saturate(dot(i.normal, i.viewDir));
                fresnel = pow(fresnel, _RimPower);
                half4 col = lerp(_MainTint, _GlowTint, fresnel);

                fixed lum = Luminance(texcol);
                lum = pow(lum, _Contrast);
                col.a *= sqrt(lum);
                col.a = saturate(col.a + fresnel);

                col.a *= (i.screenPos.y / 2) % 2;

                float screenHeight = _ScreenParams.y;
                float flickerY = i.screenPos.y / screenHeight;
                flickerY += _Time.x * _FlickerSpeed;

                col.a += 0.1 * pow(tex2D(_FlickerTex, float2(0, flickerY * _FlickerRepeat)), 1.2);

                return col;
            }

            ENDCG
        }

    }

}