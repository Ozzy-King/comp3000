using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    bool enableMovement = true;

    Vector2 mouseScreenPos;
    Vector3 up;//used for zooming
    Vector3 forward;//used to move forward
    Vector3 right;// used to move side to side

    const float xangle = 35.264f;
    [SerializeField]
    int maxPanningSpeed = 200;
    int panningSpeed = 0;

    int scrollDistMax = 30;
    int scrollDistMin = 0;
    int currentScrollDist = 0;

    // Start is called before the first frame update
    void Start() {
        forward = transform.forward; //camera is already rotated -45 deg
        transform.eulerAngles = new Vector3(transform.eulerAngles.x + xangle, transform.eulerAngles.y, transform.eulerAngles.z);//turn camera down
        right = transform.right;//get reight transform
        up = transform.forward;
        panningSpeed = maxPanningSpeed / scrollDistMax * (scrollDistMax-currentScrollDist);
        mouseScreenPos = new Vector2(Input.mousePosition.x, Input.mousePosition.y);

    }

    // Update is called once per frame
    void Update()
    {
        if (enableMovement) {
            //control for panning around
            if (Input.GetMouseButton(2)) {//gets middle mouse button down
                Vector2 currentMouse = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
                Vector3 difference = mouseScreenPos - currentMouse;
                gameObject.transform.localPosition += right * difference.x / panningSpeed;
                gameObject.transform.localPosition += forward * difference.y / panningSpeed;
            }
            //zooming
            if (Input.mouseScrollDelta.y != 0)//1=in -1=out
            {
                bool valid = false;
                if (Input.mouseScrollDelta.y > 0 && currentScrollDist - 1 >= scrollDistMin) {
                    currentScrollDist -= 1;
                    valid = true;
                }
                if (Input.mouseScrollDelta.y < 0 && currentScrollDist + 1 <= scrollDistMax)
                {
                    currentScrollDist += 1;
                    valid = true;
                }

                if (valid) {
                    gameObject.transform.localPosition += up * Input.mouseScrollDelta.y;
                }
                panningSpeed = maxPanningSpeed / scrollDistMax * (scrollDistMax - currentScrollDist); //update panning speed based on zoom,

                Debug.Log(Input.mouseScrollDelta);
            }






            
            mouseScreenPos = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
        }
    }
}
