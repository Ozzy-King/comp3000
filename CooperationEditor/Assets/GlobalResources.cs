using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Siccity.GLTFUtility;
using TMPro;
using System;

public class GlobalResources : MonoBehaviour
{
    public GameObject ImportGLTF(string filepath) {
        return Importer.LoadFromFile(filepath);
    }

    public string workingDirectory = ".\\workingDir";

    int oldSizeOBJList = 0;
    public List<string> gameObjectList = new List<string>();

    int oldSizeLUAList = 0;
    public List<string> luaScriptList = new List<string>();

    //lua scripts loaded by luaScriptLoader
    [SerializeField]
    GameObject _LuaDropDown;//object holdering dropdown
    TMP_Dropdown LuaDropDown;//actual dropdown

    //outlines used for visual feed back to user
    public Material _hoverObj;
    public Material _selectrObj;


    //-------------------------------------used for current object manipulation
    //current object selected and if its being picked up or i sa new place
    public GameObject CurrentObjectSelect;
    public int CurrentObjectSelectID;
    public bool pickedup = false;

    //gets called onchange of dropdown selection
    public void objectChange() {
        if (CurrentObjectSelect != null) {
            GameObject.Destroy(CurrentObjectSelect);
        }
        CurrentObjectSelect = ImportGLTF(gameObjectList[CurrentObjectSelectID]);
        Renderer[] ChildrenObjects = CurrentObjectSelect.GetComponentsInChildren<Renderer>();

    }

    public void objectPlace()
    {
        GameObject newCurrentObjectSelect = ImportGLTF(gameObjectList[CurrentObjectSelectID]);
        newCurrentObjectSelect.transform.position = CurrentObjectSelect.transform.position;
        newCurrentObjectSelect.transform.rotation = CurrentObjectSelect.transform.rotation;

        if (!pickedup)
        {
            //give all children a mesh collider tha will be used to detaect which object is hit
            Transform[] ChildrenObjects = CurrentObjectSelect.GetComponentsInChildren<Transform>();
            foreach (Transform childObject in ChildrenObjects) {
                if (childObject != gameObject.GetComponent<Transform>()) { //makes sure it doesnt attach one to paerant object
                    MeshCollider temp = childObject.gameObject.AddComponent<MeshCollider>();
                    temp.convex = true;
                    temp.isTrigger = true;
                }
            }
            //gives the perant object its own attribute script
            ObjectAttributes newObjectAttributes = CurrentObjectSelect.AddComponent<ObjectAttributes>();
            newObjectAttributes.PosChange();
        }

        CurrentObjectSelect = newCurrentObjectSelect;
        pickedup = false;
    }


    public void objectSet(GameObject obj) {
        GameObject.Destroy(CurrentObjectSelect);
        CurrentObjectSelect = obj;
        pickedup = true;
    }
    //------------------------------------------

    //------------------------------------attribute manipulation
    public GameObject attributeTable;
    public 

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
    }
}
