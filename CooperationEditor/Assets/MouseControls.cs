using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseControls : MonoBehaviour
{

    //holds all information on resources avaliable
    [SerializeField]
    GlobalResources globalResources;
    [SerializeField]
    Camera cam;
    Vector3 oldMouse;
    
    // Start is called before the first frame update
    void Start() {
        cam = gameObject.GetComponent<Camera>();
        oldMouse = Input.mousePosition;
    }

    

    // Update is called once per frame
    void Update()
    {
        Vector3 newMouse = Input.mousePosition;

        //rotate the object currently being selected with R
        if (Input.GetKey(KeyCode.R))
        {
            Debug.Log("old:" + oldMouse + " new: " + Input.mousePosition);

            globalResources.CurrentObjectSelect.transform.eulerAngles = globalResources.CurrentObjectSelect.transform.eulerAngles + new Vector3(0, oldMouse.x - newMouse.x, 0);
        }
        //shoot ray form mouse position to later itneract witht he object
        else
        {
            //TODO need to have mouse world pos bound to grid


            RaycastHit rayHit;
            //Ray ray = cam.ScreenPointToRay(Input.mousePosition);
            Ray ray = cam.ViewportPointToRay(cam.ScreenToViewportPoint(Input.mousePosition));

            //find point at which ray hits y = 0
            float objToYzero = Mathf.Abs(gameObject.transform.position.y / ray.direction.y); //how many sets to get from objects position to y = 0 (camera is always looging down)
            Vector3 temp = (ray.direction * objToYzero);//could move objs position down to y= 0 with right transofrm on x and z
            float distance = Mathf.Sqrt(Mathf.Pow(temp.x, 2) + Mathf.Pow(ray.origin.y, 2) + Mathf.Pow(temp.z, 2));

            //cast ray to y = 0
            bool didHit = Physics.Raycast(ray, out rayHit, distance);

            //sets positon of current object
            globalResources.CurrentObjectSelect.transform.position = ray.origin + (ray.direction * objToYzero);

            //debuging
            Debug.DrawRay(ray.origin, ray.direction * objToYzero, Color.yellow);

            //TODO fix this is deleteing the objects whe selecting then placeing <-- should be fixed now but keep here to remeber if something goes wrong 
            if (Input.GetMouseButtonDown(0))
            {
                //if either an object has been picked up or is placeing an object not yet place - place the object
                if (!didHit || globalResources.pickedup)
                {
                    globalResources.objectPlace();
                }
                //else it hit and object gets picked up
                else { 
                    globalResources.objectSet(rayHit.transform.gameObject);
                }
            }

        }

        //used for when it hits

        oldMouse = newMouse;
    }
}
