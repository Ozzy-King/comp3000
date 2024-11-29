using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Siccity.GLTFUtility;
using TMPro;
using System;
using Unity.VisualScripting;
using System.Linq;

public class GlobalResources : MonoBehaviour
{
    [SerializeField]
    LevelLoader levelLoader;

    public GameObject ImportGLTF(string filepath) {
        return Importer.LoadFromFile(filepath);
    }

    public string workingDirectory = ".\\workingDir";
    public const string levelDir = "/levels/";
    public const string codeDir = "/code/";
    public const string artDir = "/art/";
    public const string art3dDir = "/art3d/";
    public string LevelName = "ozzy_1_players_2.yaml";

    public LevelFile levelFile;
    public Dictionary<string, ObjectClass> allObjects = new Dictionary<string, ObjectClass>();
    public int levelWidth;
    public List<List<ObjectClass>> level = new List<List<ObjectClass>>();

    public bool LoadedEverything = false;


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

    }

    public void objectPlace()
    {

    }


    public void objectSet(GameObject obj) {

    }
    //------------------------------------------

    //------------------------------------attribute manipulation
    public GameObject attributeTable;
    public 

    // Start is called before the first frame update
    void Start()
    {
        levelLoader.loadLevel();
        levelLoader.LoadObjects();
        levelLoader.parseLevel();


        //place objects in scene

        for (int y = 0, c = 0; y < level.Count/ levelWidth; y++) { //loop throuhg the y
            for (int x = 0; x < levelWidth; x++, c++) { //loop throuhg the c
                Vector2 newPos = new Vector2(-(x * 2), -(y * 2));
                GameObject EmptyGridSpace = new GameObject();
                EmptyGridSpace.transform.position = new Vector3(newPos.x, 0, newPos.y);
                EmptyGridSpace.name = "" + (char)(x+'A') + (char)(y+'A');
                foreach (ObjectClass obj in level[c]) {  //loop each object in each cell
                    if (obj.art3d.Count <= 0) { continue; } //skip object with no model //TODO have default object so object with no art can still be used
                    Art3d objsArt = obj.art3d[^1];
                    GameObject Temp = ImportGLTF(workingDirectory+"/"+objsArt.model);
                    CenterPivotAtBottomMiddle(Temp);
                    Temp.transform.position = new Vector3(newPos.x, 0, newPos.y);

                    
                    Temp.transform.position += new Vector3(objsArt.pos.z, objsArt.pos.y, objsArt.pos.x);

                    Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                    Debug.Log(obj.dir);
                    Temp.transform.parent = EmptyGridSpace.transform;
                    
                }
            }
        }
        


        Debug.Log(levelFile.grid);
        LoadedEverything = true;
    }

    //testing write own version
    public static void CenterPivotAtBottomMiddle(GameObject target)
    {
        if (target == null)
        {
            Debug.LogError("Target GameObject is null. Please provide a valid GameObject.");
            return;
        }

        if (target.transform.childCount == 0)
        {
            Debug.LogWarning($"GameObject '{target.name}' has no children to calculate the center.");
            return;
        }

        // Find all child renderers
        Renderer[] renderers = target.GetComponentsInChildren<Renderer>();

        if (renderers.Length == 0)
        {
            Debug.LogWarning($"GameObject '{target.name}' has no renderers in its children.");
            return;
        }

        // Calculate the combined bounds of all children
        Bounds combinedBounds = renderers[0].bounds;
        foreach (Renderer renderer in renderers.Skip(1))
        {
            combinedBounds.Encapsulate(renderer.bounds);
        }

        // Determine the bottom-middle position
        Vector3 bottomMiddle = new Vector3(
            combinedBounds.center.x,
            combinedBounds.min.y,
            combinedBounds.center.z
        );

        // Offset the target object so the bottom middle is at the origin
        Vector3 offset = target.transform.position - bottomMiddle;
        target.transform.position -= offset;

        // Offset all children to maintain their original positions
        foreach (Transform child in target.transform)
        {
            child.position += offset;
        }

        Debug.Log($"Pivot of '{target.name}' has been recentered to the bottom middle.");
    }


    // Update is called once per frame
    void Update()
    {
    }
}
