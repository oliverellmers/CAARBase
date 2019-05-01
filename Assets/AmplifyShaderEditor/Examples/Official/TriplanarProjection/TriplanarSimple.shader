// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/Triplanar Simple"
{
	Properties
	{
		_TopAlbedo("Top Albedo", 2D) = "white" {}
		_TopNormal("Top Normal", 2D) = "bump" {}
		_AO("AO", 2D) = "bump" {}
		_TriplanarAlbedo("Triplanar Albedo", 2D) = "white" {}
		_TriplanarNormal("Triplanar Normal", 2D) = "bump" {}
		_Specular("Specular", Range( 0 , 1)) = 0.02
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_CoverageFalloff("Coverage Falloff", Range( 0.01 , 5)) = 0.5
		_AlbedoTint("AlbedoTint", Color) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZTest LEqual
		CGPROGRAM
		#pragma target 3.0
		#define ASE_TEXTURE_PARAMS(textureName) textureName

		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _TopNormal;
		uniform sampler2D _TriplanarNormal;
		uniform float _CoverageFalloff;
		uniform float4 _AlbedoTint;
		uniform sampler2D _TopAlbedo;
		uniform sampler2D _TriplanarAlbedo;
		uniform float _Specular;
		uniform float _Smoothness;
		uniform sampler2D _AO;


		inline float3 TriplanarSamplingCNF( sampler2D topTexMap, sampler2D midTexMap, sampler2D botTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			float negProjNormalY = max( 0, projNormal.y * -nsign.y );
			projNormal.y = max( 0, projNormal.y * nsign.y );
			half4 xNorm; half4 yNorm; half4 yNormN; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( midTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			yNormN = ( tex2D( ASE_TEXTURE_PARAMS( botTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( midTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			xNorm.xyz = half3( UnpackNormal( xNorm ).xy * float2( nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz = half3( UnpackNormal( yNorm ).xy * float2( nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			yNormN.xyz = half3( UnpackNormal( yNormN  ).xy * float2( nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + yNormN.xyz * negProjNormalY + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSamplingCF( sampler2D topTexMap, sampler2D midTexMap, sampler2D botTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			float negProjNormalY = max( 0, projNormal.y * -nsign.y );
			projNormal.y = max( 0, projNormal.y * nsign.y );
			half4 xNorm; half4 yNorm; half4 yNormN; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( midTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			yNormN = ( tex2D( ASE_TEXTURE_PARAMS( botTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( midTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + yNormN * negProjNormalY + zNorm * projNormal.z;
		}


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar345 = TriplanarSamplingCNF( _TopNormal, _TriplanarNormal, _TriplanarNormal, ase_worldPos, ase_worldNormal, _CoverageFalloff, float2( 1,1 ), float3( 1,1,1 ), float3(0,0,0) );
			float3 tanTriplanarNormal345 = mul( ase_worldToTangent, triplanar345 );
			o.Normal = tanTriplanarNormal345;
			float4 triplanar343 = TriplanarSamplingCF( _TopAlbedo, _TriplanarAlbedo, _TriplanarAlbedo, ase_worldPos, ase_worldNormal, _CoverageFalloff, float2( 1,1 ), float3( 1,1,1 ), float3(0,0,0) );
			o.Albedo = ( _AlbedoTint * triplanar343 ).rgb;
			float3 temp_cast_2 = (_Specular).xxx;
			o.Specular = temp_cast_2;
			o.Smoothness = _Smoothness;
			o.Occlusion = tex2D( _AO, ase_worldPos.xy ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
497;965;1585;564;519.9678;151.4727;2.133458;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;339;272.6383,-85.24615;Float;True;Property;_TriplanarAlbedo;Triplanar Albedo;3;0;Create;True;0;0;False;0;None;076550629020fdc4f884fc06a31a8350;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;338;272.6383,-277.2462;Float;True;Property;_TopAlbedo;Top Albedo;0;0;Create;True;0;0;False;0;None;076550629020fdc4f884fc06a31a8350;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;352;268.646,308.1384;Float;False;Property;_CoverageFalloff;Coverage Falloff;7;0;Create;True;0;0;False;0;0.5;1.07;0.01;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;344;348.646,148.1385;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;343;1021.785,-122.2308;Float;True;Cylindrical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT3;1,1,1;False;3;FLOAT2;1,1;False;4;FLOAT;2;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;353;1166.101,-335.0175;Float;False;Property;_AlbedoTint;AlbedoTint;8;0;Create;True;0;0;False;0;0,0,0,0;0.6415094,0.6415094,0.6415094,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;347;672,656;Float;True;Property;_TriplanarNormal;Triplanar Normal;4;0;Create;True;0;0;False;0;None;21e6c397724a820498de2d60de3ee646;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;346;672,448;Float;True;Property;_TopNormal;Top Normal;1;0;Create;True;0;0;False;0;None;21e6c397724a820498de2d60de3ee646;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;356;1282.906,762.3052;Float;True;Property;_AO;AO;2;0;Create;True;0;0;False;0;None;093fe47970966994b8f1642a5fde7465;False;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;213;1184,624;Float;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;0.5;0.292;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;1184,544;Float;False;Property;_Specular;Specular;5;0;Create;True;0;0;False;0;0.02;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;1642.024,-51.53284;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;345;1088,320;Float;True;Cylindrical;World;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT3;1,1,1;False;3;FLOAT2;1,1;False;4;FLOAT;2;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;358;1815.676,1401.332;Float;True;Property;_TextureSample0;Texture Sample 0;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2182.531,207.0385;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;ASESampleShaders/Triplanar Simple;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;343;0;338;0
WireConnection;343;1;339;0
WireConnection;343;2;339;0
WireConnection;343;9;344;0
WireConnection;343;4;352;0
WireConnection;354;0;353;0
WireConnection;354;1;343;0
WireConnection;345;0;346;0
WireConnection;345;1;347;0
WireConnection;345;2;347;0
WireConnection;345;9;344;0
WireConnection;345;4;352;0
WireConnection;358;0;356;0
WireConnection;358;1;344;0
WireConnection;0;0;354;0
WireConnection;0;1;345;0
WireConnection;0;3;212;0
WireConnection;0;4;213;0
WireConnection;0;5;358;0
ASEEND*/
//CHKSM=BC9E7C1FDBADE272E07070F00D059C7A1DB151FF