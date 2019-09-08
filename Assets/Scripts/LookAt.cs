using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAt : MonoBehaviour
{

    void OnValidate()
    {
        Refresh();
    }

    void Reset()
    {
        Refresh();
    }

    private void Refresh()
    {
        GetComponent<Camera>().transform.LookAt(GameObject.Find("Hologram").transform);
    }
}
