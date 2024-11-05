using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class GlobalResources : MonoBehaviour
{

    public string workingDirectory = ".\\workingDir";

    int oldSizeOBJList = 0;
    public List<string> gameObjectList = new List<string>();

    int oldSizeLUAList = 0;
    public List<string> luaScriptList = new List<string>();

    [SerializeField]
    GameObject _ObjectDropDown;//object holdering dropdown
    TMP_Dropdown ObjectDropDown;//actual dropdown

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
        }
    }
}
