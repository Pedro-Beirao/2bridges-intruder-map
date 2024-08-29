using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class LightingSwitchRenderSettingsData : ScriptableObject
{
	public bool fog;

	public float fogStartDistance;

	public float fogEndDistance;

	public FogMode fogMode;

	public Color fogColor;

	public float fogDensity;

	public AmbientMode ambientMode;

	public Color ambientSkyColor;

	public Color ambientEquatorColor;

	public Color ambientGroundColor;

	public float ambientIntensity;

	public Color ambientLight;

	public Color subtractiveShadowColor;

	public Material skybox;

	public Light sun;

	public SphericalHarmonicsL2 ambientProbe;

	public Cubemap customReflection;

	public float reflectionIntensity;

	public int reflectionBounces;

	public DefaultReflectionMode defaultReflectionMode;

	public int defaultReflectionResolution;

	public float haloStrength;

	public float flareStrength;

	public float flareFadeSpeed;

}