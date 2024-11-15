using System;
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

    GameObject lastHoverObj;
    void setLastHoverObj(GameObject obj) {
        if (obj == null) { lastHoverObj = null; return; }
        lastHoverObj = findParent(obj);
    }


    bool mouseButtonClicked = false;

    //add material to children of object
    public void addMaterial(GameObject obj, Material mat)
    {
        if (obj == null || mat == null) { return; }
        MeshRenderer[] childrenMeshRendere = obj.GetComponentsInChildren<MeshRenderer>();
        foreach (MeshRenderer ch in childrenMeshRendere)
        {
            List<Material> materials = new List<Material>(ch.materials);
            if (!materials.Exists(x => x.shader == mat.shader))
            {
                materials.Add(new Material(mat));
                ch.materials = materials.ToArray();
            }
        }
    }
    //remove a material from material list of object children
    public void removeMaterial(GameObject obj, Material mat)
    {
        if (obj == null || mat == null) { return; }
        MeshRenderer[] childrenMeshRendere = obj.GetComponentsInChildren<MeshRenderer>();
        foreach (MeshRenderer ch in childrenMeshRendere)
        {
            List<Material> newMat = new List<Material>(ch.materials);
            if (newMat.Exists(x => x.shader == mat.shader))
            {
                newMat.RemoveAll(x => x.shader == mat.shader);
                ch.SetMaterials(newMat);
            }
        }
    }
    //get the top perant of object
    public GameObject findParent(GameObject obj)
    {
        GameObject parent = obj;
        while (parent.transform.parent != null)
        {
            parent = parent.transform.parent.gameObject;
        }
        return parent;
    }



    // Start is called before the first frame update
    void Start() {
        cam = gameObject.GetComponent<Camera>();
        oldMouse = Input.mousePosition;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 newMouse = Input.mousePosition;

        //calculations and ray traceing to hit and object and find where the mouse positions intersects with y = 0
        RaycastHit rayHit;
        //Ray ray = cam.ScreenPointToRay(Input.mousePosition);
        Ray ray = cam.ViewportPointToRay(cam.ScreenToViewportPoint(Input.mousePosition));

        //find point at which ray hits y = 0
        float objToYzero = Mathf.Abs(gameObject.transform.position.y / ray.direction.y); //how many steps to get from objects position to y = 0 (camera is always looging down)
        Vector3 temp = (ray.direction * objToYzero);//could move objs position down to y= 0 with right transofrm on x and z
        float distance = Mathf.Sqrt(Mathf.Pow(temp.x, 2) + Mathf.Pow(ray.origin.y, 2) + Mathf.Pow(temp.z, 2));

        Vector3 HitWorldPosition = ray.origin + (ray.direction * objToYzero);
        HitWorldPosition = new Vector3((Mathf.FloorToInt(HitWorldPosition.x) / 2) * 2, 0, (Mathf.FloorToInt(HitWorldPosition.z) / 2) * 2);

        //cast ray to y = 0
        bool didHit = Physics.Raycast(ray, out rayHit, distance);

        //add appropiate out line to objects(prioritise pickup)
        if (globalResources.pickedup)
        {
            removeMaterial(lastHoverObj, globalResources._hoverObj);
            removeMaterial(lastHoverObj, globalResources._selectrObj);
            setLastHoverObj(globalResources.CurrentObjectSelect);
            addMaterial(lastHoverObj, globalResources._selectrObj);
        }
        else if (didHit)
        {
            removeMaterial(lastHoverObj, globalResources._hoverObj);
            removeMaterial(lastHoverObj, globalResources._selectrObj);
            setLastHoverObj(rayHit.transform.gameObject);
            addMaterial(lastHoverObj, globalResources._hoverObj);
        }
        else {
            removeMaterial(lastHoverObj, globalResources._hoverObj);
            removeMaterial(lastHoverObj, globalResources._selectrObj);
            setLastHoverObj(null);
        }

        //move slsected object wither pickedup or new to cursor position
        if (globalResources.CurrentObjectSelect != null) {
            //sets positon of current object
            globalResources.CurrentObjectSelect.transform.position = HitWorldPosition;
        }


        //controlls ------ R ROTATE E PLACE nothing select
        //rotate the object currently being selected with R
        if (Input.GetKey(KeyCode.R))
        {
            Debug.Log("old:" + oldMouse + " new: " + Input.mousePosition);

            globalResources.CurrentObjectSelect.transform.eulerAngles = globalResources.CurrentObjectSelect.transform.eulerAngles + new Vector3(0, oldMouse.x - newMouse.x, 0);
        }
        //if holding E a new object will be placed
        else if (Input.GetKey(KeyCode.E)) {
            if (globalResources.CurrentObjectSelect == null) {
                globalResources.objectChange(); //<-- sets objects back to current object if it is null(null hwen is comes from sleect mode)
            }


            //debuging
            Debug.DrawRay(ray.origin, ray.direction * objToYzero, Color.yellow);

            //TODO fix this is deleteing the objects whe selecting then placeing <-- should be fixed now but keep here to remeber if something goes wrong 
            if (Input.GetMouseButtonDown(0))
            {
                globalResources.objectPlace();
            }

        }
        //by default use is in select mode (no object will be by the mouse) 
        else {
            //if an object that not ment to exist is appearing get rid of it
            if (!globalResources.pickedup && globalResources.CurrentObjectSelect != null) {
                Destroy(globalResources.CurrentObjectSelect);
            }

            if (Input.GetMouseButtonDown(0) && !mouseButtonClicked)
            {
                mouseButtonClicked = true;
                //if it hit an object and not currenly picked anything up, pickup object
                if (didHit && !globalResources.pickedup)
                {
                    //gets the top perant of the hit obejct
                    GameObject parent = findParent(rayHit.transform.gameObject);
                    globalResources.objectSet(parent);
                }
            }
            else if (Input.GetMouseButton(0)) {
                Debug.Log("loggin held");
                if (didHit && !globalResources.pickedup)
                {
                    //gets the top perant of the hit obejct
                    GameObject parent = findParent(rayHit.transform.gameObject);
                    globalResources.objectSet(parent);
                }
                globalResources.CurrentObjectSelect.transform.position = HitWorldPosition;

            }
            else {
                mouseButtonClicked = false;
                if (globalResources.pickedup){
                    globalResources.objectPlace();
                }
            }



        }

        //used for when it hits

        oldMouse = newMouse;
    }
}
