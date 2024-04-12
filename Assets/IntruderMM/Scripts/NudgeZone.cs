using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NudgeZone : MonoBehaviour
{
    [Tooltip("Nudge speed")]
    public float speed;
    [Tooltip("(REQUIRED) Assign a transform here with the blue Z-axis (forward) facing the direction you want to nudge")]
    public Transform directionTransform;
    [Header("Options")]
    [Tooltip("Will nudge the opposite direction if character is behind the Direction Transform, useful for thin objects like tops of doors")]
    public bool twoWay = false;
    [Tooltip("(OPTIONAL) Two Way will use this transform forward direction if behind the Direction Transform")]
    public Transform twoWayDirectionTransform;

#if UNITY_EDITOR
    public void OnDrawGizmosSelected()
    {
        if (directionTransform == null)
        {
            return;
        }

        float speedVectorSize = speed * 0.25f;

        Gizmos.color = UnityEngine.Color.magenta;
        Gizmos.DrawRay(directionTransform.position, directionTransform.forward * speedVectorSize);

        if (twoWay)
        {
            Gizmos.color = UnityEngine.Color.yellow;

            if (twoWayDirectionTransform)
            {
                Gizmos.DrawRay(twoWayDirectionTransform.position, twoWayDirectionTransform.forward * speedVectorSize);
            }
            else
            {
                Gizmos.DrawRay(directionTransform.position, -directionTransform.forward * speedVectorSize);
            }
        }
    }
#endif
}
