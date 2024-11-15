using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectAttributes : MonoBehaviour
{
    // Start is called before the first frame update

    Vector3 gridPos; //<--objects initil placement before offset is used (when exporting min x and y will be added so that the origin is shiftend to 0,0)
    Vector3 offset = new Vector3(0,0,0); //<--and reletive move basedon absolute position

    //rotation and scale are stored in objects transform


    public void PosChange() //called to get the objects new grid
    {
        gridPos = transform.position;
        transform.position = gridPos + offset;//sets new positon based on curent gridpos and offset
    }


    void Start()
    {
        



    }

    // Update is called once per frame
    void Update()
    {



        
    }
}
