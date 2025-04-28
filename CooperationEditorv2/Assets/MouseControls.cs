using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class MouseControls : MonoBehaviour
{

    //holds all information on resources avaliable
    [SerializeField]
    GlobalResources globalResources;

    Vector3 beginDrag = Vector3.zero;
    Vector3 endDrag = Vector3.zero;

    [SerializeField]
    GameObject hoverTextTemplate;
    GameObject hoverTextOBJ = null;

    public GameObject cellCube;

    void addHoverText(Vector3 pos)
    {
        if (hoverTextOBJ == null) {
            hoverTextOBJ = Instantiate(hoverTextTemplate);
            hoverTextOBJ.transform.position = pos + new Vector3(0, 10, 0);
            hoverTextOBJ.AddComponent<BillboardScript>();
        }
    }
    void removeHoverText() {
        if (hoverTextOBJ != null)
        {
            Destroy(hoverTextOBJ);
            hoverTextOBJ = null;
        }
    }
    void setHoverText(string text) {
        if (hoverTextOBJ != null) {
            hoverTextOBJ.GetComponent<TMP_Text>().text = text;
        }
    }
    void setHoverTextPos(Vector3 pos) {
        if (hoverTextOBJ != null) {
            hoverTextOBJ.transform.position = pos + new Vector3(0, 10, 0);
        }
    }

    
    [SerializeField]
    Camera cam;
    Vector3 oldMouse;

    bool placeing = false;

    GameObject lastHoverObj = null;
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
        SkinnedMeshRenderer[] childrenskinnedMeshRendere = obj.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (MeshRenderer ch in childrenMeshRendere)
        {
            List<Material> materials = new List<Material>(ch.materials);
            if (!materials.Exists(x => x.shader == mat.shader))
            {
                materials.Add(mat);
                ch.materials = materials.ToArray();
            }
        }
        foreach (SpriteRenderer ch in childrenSpriteRendere)
        {
            List<Material> materials = new List<Material>(ch.materials);
            if (!materials.Exists(x => x.shader == mat.shader))
            {
                materials.Add(mat);
                ch.materials = materials.ToArray();
            }
        }
        foreach (SkinnedMeshRenderer ch in childrenskinnedMeshRendere)
        {
            List<Material> materials = new List<Material>(ch.materials);
            if (!materials.Exists(x => x.shader == mat.shader))
            {
                materials.Add(mat);
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
        SkinnedMeshRenderer[] childrenskinnedMeshRendere = obj.GetComponentsInChildren<SkinnedMeshRenderer>();
        Material matToDelete;
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
        foreach (SkinnedMeshRenderer ch in childrenskinnedMeshRendere)
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
        if (globalResources.LoadedEverything == false) { return; }

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

        cellCube.transform.position = HitWorldPosition + new Vector3(0,1,0);

        //cast ray to y = 0
        bool didHit = Physics.Raycast(ray, out rayHit, distance);

        //need to add object create function that sets up the object and return the top perant object
        //while holding e
        if (Input.GetKey(KeyCode.E))
        {
            placeing = true;
            //if its the first time pressing e
            if (Input.GetKeyDown(KeyCode.E))
            {
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);

                setLastHoverObj(globalResources.createObject(globalResources.CurrentObjectSelectID));
                addMaterial(lastHoverObj, globalResources._hoverObj);

                removeHoverText();
            }
            //move object to mouse position
            lastHoverObj.transform.position = HitWorldPosition;
            //if clicked place objectand create a new one to move to mouse position
            if (Input.GetMouseButtonDown(0)) {
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);
                globalResources.CurrentLevel.Add(lastHoverObj);

                setLastHoverObj(globalResources.createObject(globalResources.CurrentObjectSelectID));
                addMaterial(lastHoverObj, globalResources._hoverObj);
            }
        }
        else
        {
            //if coming out of holding e delete object and reset placeing bool
            if (placeing == true) {
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);
                Destroy(lastHoverObj);
                lastHoverObj = null;
            }
            placeing=false;
            //if mouse button is being held down
            if (Input.GetMouseButton(0))
            {
                //if there is a object that was hit by the mouse ray
                if (lastHoverObj != null)
                {
                    removeMaterial(lastHoverObj, globalResources._hoverObj);
                    removeMaterial(lastHoverObj, globalResources._selectrObj);
                    addMaterial(lastHoverObj, globalResources._selectrObj);

                    lastHoverObj.transform.position = HitWorldPosition;
                    setHoverTextPos(lastHoverObj.transform.position);
                }
            }
            //if mouse button isnt held and the ray did hit, set hit obejct to last hover
            else if (didHit)
            {
                //if right mouse is click over object delete(can be held down with no side effects)
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);
                setLastHoverObj(rayHit.transform.gameObject);
                addMaterial(lastHoverObj, globalResources._hoverObj);

                //create hovertextOBJ
                addHoverText(lastHoverObj.transform.position);
                setHoverTextPos(lastHoverObj.transform.position);
                setHoverText(lastHoverObj.name);

                //if right mouse buttons is clicked
                if (Input.GetMouseButtonDown(1)) {
                    globalResources.CurrentLevel.Remove(lastHoverObj);
                    Destroy(lastHoverObj);
                    lastHoverObj = null;
                    removeHoverText();
                }

                //if moddle mouse button is clicked
                if (Input.GetMouseButtonDown(2)) {
                    beginDrag = newMouse;
                }
                else if (Input.GetMouseButtonUp(2)) {
                    endDrag = newMouse;
                    if (Vector3.Distance(beginDrag, endDrag) <= 0.5f) {
                        globalResources.CurrentObjectSelectID = lastHoverObj.name;
                    }
                }

            }
            //else remove hover mats from object and set last hover to null
            else
            {
                removeMaterial(lastHoverObj, globalResources._hoverObj);
                removeMaterial(lastHoverObj, globalResources._selectrObj);
                setLastHoverObj(null);
                removeHoverText();//remove hover text
            }
        }
        //used for when it hits

        oldMouse = newMouse;
    }
}
