using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BillboardScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(Camera.main.transform);

        // Flip the object around the Y-axis (180 degrees) to ensure the front faces the camera
        transform.Rotate(0, 180, 0);
        // gameObject.transform.Rotate(new Vector3(0, 180 ,0));
        // gameObject.transform.rotation = Quaternion.Euler(-(gameObject.transform.rotation.eulerAngles.x), gameObject.transform.rotation.eulerAngles.y, gameObject.transform.rotation.eulerAngles.z);


    }
}
