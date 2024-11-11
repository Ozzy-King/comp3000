using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Siccity.GLTFUtility;
using TMPro;

public class GlobalResources : MonoBehaviour
{
    GameObject ImportGLTF(string filepath) {
        return Importer.LoadFromFile(filepath);
    }


    public string workingDirectory = ".\\workingDir";

    int oldSizeOBJList = 0;
    public List<string> gameObjectList = new List<string>();

    int oldSizeLUAList = 0;
    public List<string> luaScriptList = new List<string>();

    [SerializeField]
    GameObject _ObjectDropDown;//object holdering dropdown
    TMP_Dropdown ObjectDropDown;//actual dropdown

    public GameObject CurrentObjectSelect;
    public bool pickedup = false;

    //gets called onchange of dropdown selection
    public void objectChange() {
        GameObject.Destroy(CurrentObjectSelect);
        CurrentObjectSelect = ImportGLTF(gameObjectList[ObjectDropDown.value]);
    }

    public void objectPlace()
    {
        GameObject newCurrentObjectSelect = ImportGLTF(gameObjectList[ObjectDropDown.value]);
        newCurrentObjectSelect.transform.position = CurrentObjectSelect.transform.position;
        newCurrentObjectSelect.transform.rotation = CurrentObjectSelect.transform.rotation;

        Mesh newColliderMesh = new Mesh();
        MeshFilter [] meshFilterSubObjects = CurrentObjectSelect.GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combineMeshs = new CombineInstance[meshFilterSubObjects.Length];
        for (int i = 0; i < meshFilterSubObjects.Length; i++) {
            combineMeshs[i].mesh = meshFilterSubObjects[i].sharedMesh;
            combineMeshs[i].transform = meshFilterSubObjects[i].transform.localToWorldMatrix;
        }
        newColliderMesh.CombineMeshes(combineMeshs, true);

        MeshCollider collideTemp = CurrentObjectSelect.AddComponent<MeshCollider>();
        collideTemp.convex = true;
        collideTemp.isTrigger = true;
        collideTemp.sharedMesh = newColliderMesh;

        CurrentObjectSelect = newCurrentObjectSelect;
        pickedup = false;
    }

    public void objectSet(GameObject obj) {
        GameObject.Destroy(CurrentObjectSelect);
        CurrentObjectSelect = obj;
        pickedup = true;
    }

    [SerializeField]
    GameObject _LuaDropDown;//object holdering dropdown
    TMP_Dropdown LuaDropDown;//actual dropdown

    // Start is called before the first frame update
    void Start()
    {
        ObjectDropDown = _ObjectDropDown.GetComponent<TMP_Dropdown>();
        ObjectDropDown.ClearOptions();
    }

    // Update is called once per frame
    void Update()
    {
        //checks if object list has be added to or removed from and updates
        if (oldSizeOBJList != gameObjectList.Count) {
            List<string> temp = new List<string>();
            ObjectDropDown.ClearOptions();
            foreach (string objStr in gameObjectList) {
                //string[] temp2 = objStr.Split("/")[^1];
                temp.Add(objStr.Split("\\")[^1]);
            }
            ObjectDropDown.AddOptions(temp);
            oldSizeOBJList = gameObjectList.Count;
            if (CurrentObjectSelect == null) {//if no object is selected then use the first object in new list
                objectChange();
            }
        }
    }
}
