//#define DEBUG // Define the DEBUG symbol
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Siccity.GLTFUtility;
using TMPro;
using System;
using Unity.VisualScripting;
using System.Linq;
using System.IO;

//hold E and click to placeObject
//click and hold on Object and press Q to delete object
//Press S to save Level


public class GlobalResources : MonoBehaviour
{
    [SerializeField]
    LevelLoader levelLoader;
    [SerializeField]
    ItemPopulater populater;

    public GameObject ImportGLTF(string filepath) {
        return Importer.LoadFromFile(filepath);
    }
    public GameObject ImportImage(string filepath) {
        GameObject BillboardObject = new GameObject();
        Texture2D Tex2D;
        Sprite sprite2D;
        if (!File.Exists(filepath)) { return BillboardObject; }
        
        //create sprite
        byte[] FileData = File.ReadAllBytes(filepath);
        Tex2D = new Texture2D(2, 2);
        Tex2D.LoadImage(FileData);
        sprite2D = Sprite.Create(Tex2D, new Rect(0, 0, Tex2D.width, Tex2D.height), new Vector2(0, 0));

        //set sprite to render
        SpriteRenderer render = BillboardObject.AddComponent<SpriteRenderer>();
        render.sprite = sprite2D;

        //BillboardObject.AddComponent<BillboardScript>();
        
        return BillboardObject;
    }

    public string workingDirectory = ".\\testing";
    public const string levelDir = "/levels";
    public const string codeDir = "/code";
    public const string artDir = "/art";
    public const string art3dDir = "/3d";
    public const string art2dDir = "/2d";
    public string LevelName = "Level_1_players_2.yaml";

    public LevelFile levelFile;
    public Dictionary<string, ObjectClass> allObjects = new Dictionary<string, ObjectClass>();
    public int levelWidth;
    public List<List<(string, ObjectClass)>> level = new List<List<(string, ObjectClass)>>(); //<<--used to set the level up in the world
    public List<GameObject> CurrentLevel;//<<-- all game objects that are in the current map 
    public GameObject placeHolder; //<----- set in editor

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
    public string CurrentObjectSelectID;
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
        levelLoader.INIT();
        levelLoader.loadLevel();
        levelLoader.LoadObjects();
        levelLoader.parseLevel();
        StartCoroutine(populater.populateScrollView());
        CurrentObjectSelectID = allObjects.Keys.First();

        //place objects in scene from level

        for (int y = 0, c = 0; y < level.Count/ levelWidth; y++) { //loop throuhg the y
            for (int x = 0; x < levelWidth; x++, c++) { //loop throuhg the c
                Vector2 newPos = new Vector2((x * 2), (y * 2));

                //TODO if a defintion has no object or image then replace with billboard spite of definition name
                foreach ((string name, ObjectClass obj) in level[c]) {  //loop each object in each cell
                    GameObject HolderObj = new GameObject();//holds al the models for object
                    HolderObj.AddComponent<ObjectAttributes>().objectName = name;
                    HolderObj.name = name;
                    HolderObj.transform.position = new Vector3(newPos.y, 0, newPos.x);

                    //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
                    bool visible = false;
                    //import each object used
                    foreach (Art3d objsArt in obj.art3d)
                    {
                        visible = true;
                        GameObject Temp = ImportGLTF(workingDirectory + "/" + objsArt.model);
                        Temp.AddComponent<ObjectAttributes>().attributes3d = objsArt;
                        foreach (Renderer rend in Temp.GetComponentsInChildren<Renderer>()) {
                            MeshCollider col = rend.transform.gameObject.AddComponent<MeshCollider>();
                            col.convex = true;
                            col.isTrigger = true;
                        }

                        Temp.name = obj.dir;

                        //CenterPivotAtBottomMiddle(Temp);

                        Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                        Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                        Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                        Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                        Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                        Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                        Debug.Log(obj.dir);
                        Temp.transform.parent = HolderObj.transform;
                    }
                    foreach (Art2d objsArt in obj.art2d)
                    {
                        visible = true;
                        GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
                        Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
                        BoxCollider collider = Temp.AddComponent<BoxCollider>();
                        collider.isTrigger = true;

                        Temp.name = obj.dir;

                        //CenterPivotAtBottomMiddle(Temp);

                        Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                        Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                        Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                        Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                        Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                        Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                        Debug.Log(obj.dir);
                        Temp.transform.parent = HolderObj.transform;
                    }
                    if (!visible) {
                        GameObject Temp = Instantiate(placeHolder);
                        Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);
                        Temp.transform.parent = HolderObj.transform;
                    }
                    CurrentLevel.Add(HolderObj);
                }
            }
        }
   
        Debug.Log(levelFile.grid);
        LoadedEverything = true;
    }


    public GameObject createObject(string name) {
        ObjectClass obj = allObjects[name];

        GameObject HolderObj = new GameObject();//holds al the models for object
        HolderObj.AddComponent<ObjectAttributes>().objectName = name;
        HolderObj.name = name;
        HolderObj.transform.position = new Vector3(0, 0, 0);

        //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
        bool visible = false;
        //import each object used
        foreach (Art3d objsArt in obj.art3d)
        {
            visible = true;
            GameObject Temp = ImportGLTF(workingDirectory + "/" + objsArt.model);
            Temp.AddComponent<ObjectAttributes>().attributes3d = objsArt;
            foreach (Renderer rend in Temp.GetComponentsInChildren<Renderer>())
            {
                MeshCollider col = rend.transform.gameObject.AddComponent<MeshCollider>();
                col.convex = true;
                col.isTrigger = true;
            }

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(0, 0, 0);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
            Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
            Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        foreach (Art2d objsArt in obj.art2d)
        {
            visible = true;
            GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
            Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
            BoxCollider collider = Temp.AddComponent<BoxCollider>();
            collider.isTrigger = true;

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(0, 0, 0);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
            Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
            Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        if (!visible)
        {
            GameObject Temp = Instantiate(placeHolder);
            Temp.transform.position = new Vector3(0, 0, 0);
            Temp.transform.parent = HolderObj.transform;
        }
        return HolderObj;
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
