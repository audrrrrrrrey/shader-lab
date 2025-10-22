using UnityEngine;

public class RotateCamera : MonoBehaviour
{
    public Transform target;

    void FixedUpdate()
    {
        transform.LookAt(target);
        transform.Translate(Vector3.right * Time.deltaTime);
    }
}
