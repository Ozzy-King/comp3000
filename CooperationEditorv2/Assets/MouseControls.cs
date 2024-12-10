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
        SpriteRenderer[] childrenSpriteRendere = obj.GetComponentsInChildren<SpriteRenderer>();
        foreach (MeshRenderer ch in childrenMeshRendere)
        {
            List<Material> materials = new List<Material>(ch.materials);
            if (!materials.Exists(x => x.shader == mat.shader))
            {
                materials.Add(new Material(mat));
                ch.materials = materials.ToArray();
            }
        }
        foreach (SpriteRenderer ch in childrenSpriteRendere)
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
        SpriteRenderer[] childrenSpriteRendere = obj.GetComponentsInChildren<SpriteRenderer>();
        foreach (MeshRenderer ch in childrenMeshRendere)
        {
            List<Material> newMat = new List<Material>(ch.materials);
            if (newMat.Exists(x => x.shader == mat.shader))
            {
                newMat.RemoveAll(x => x.shader == mat.shader);
                ch.SetMaterials(newMat);
            }
        }
        foreach (SpriteRenderer ch in childrenSpriteRendere)
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

        //need to add object create function that sets up the object and return the top perant object
        // if (Input.GetKey(KeyCode.E)) {
        //     if (Input.GetKeyDown(KeyCode.E))
        //     {
        //         removeMaterial(lastHoverObj, globalResources._hoverObj);
        //         removeMaterial(lastHoverObj, globalResources._selectrObj);
        //         
        //         setLastHoverObj(rayHit.transform.gameObject);
        //     }
        // }

        if (Input.GetMouseButton(0))
        {
            if (lastHoverObj != null)
            {
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);
                addMaterial(lastHoverObj, globalResources._selectrObj);

                lastHoverObj.transform.position = HitWorldPosition;
            }
        }
        else if (didHit)
        {
            removeMaterial(lastHoverObj, globalResources._hoverObj);
            removeMaterial(lastHoverObj, globalResources._selectrObj);
            setLastHoverObj(rayHit.transform.gameObject);
            addMaterial(lastHoverObj, globalResources._hoverObj);
        }
        else
        {
            removeMaterial(lastHoverObj, globalResources._hoverObj);
            removeMaterial(lastHoverObj, globalResources._selectrObj);
            setLastHoverObj(null);
        }

        //used for when it hits

        oldMouse = newMouse;
    }
}
