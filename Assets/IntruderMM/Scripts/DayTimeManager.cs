using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class DayTimeManager : MonoBehaviour
{
	public bool randomTime = true;

	public int[] randomTimeIndexChances;

	private List<int> randomIndexStack = new List<int>();

	public LightingSwitchManager lightingSwitchManager;
}