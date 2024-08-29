using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class LightingSwitchManager : MonoBehaviour
{
    public int currentState;

    public LightingSwitchGroup[] lightingSwitchGroups;

    public static LightingSwitchManager main;

    public List<GameObject> objectsToSetAsStatic;

    public ReflectionProbe[] reflectionProbes;
}