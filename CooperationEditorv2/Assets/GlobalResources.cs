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
using UnityEngine.UI;

//hold E and click to placeObject
//click and hold on Object and press Q to delete object
//Press S to save Level


public class GlobalResources : MonoBehaviour
{
    [SerializeField]
    LevelLoader levelLoader;
    [SerializeField]
    LevelExporter levelExporter;
    [SerializeField]
    ItemPopulater populater;

    [SerializeField]
    GameObject objectCachePerant; //<--------set in editor
    Dictionary<string, Texture2D> textureCache = new Dictionary<string, Texture2D>();
    Dictionary<string, GameObject> objectCache = new Dictionary<string, GameObject>();

    public GameObject ImportGLTF(string filepath) {
        string filename = filepath.Split("/")[^1];
        if (objectCache.ContainsKey(filename))
        {
            return Instantiate(objectCache[filename]);
        }
        if (!File.Exists(filepath)) { 
            return Instantiate(placeHolder); 
        }

        GameObject newObj = Importer.LoadFromFile(filepath);

        GameObject tempSave = Instantiate(newObj);
        tempSave.transform.position = new Vector3(100, 1000, 100);
        tempSave.transform.parent = objectCachePerant.transform;
        objectCache.Add(filename, tempSave);
        
        return newObj;
    }
    public GameObject ImportImage(string filepath) {
        //create quad object
        GameObject BillboardObject = Instantiate(quadTemplate);
        BillboardObject.transform.position = Vector3.zero;
        MeshRenderer quadMeshRenderer = BillboardObject.GetComponent<MeshRenderer>();

        //create texture variables and populate them with right data
        Texture2D Tex2D;
        string filename = filepath.Split("/")[^1];
        if (textureCache.ContainsKey(filename)) { 
            Tex2D = textureCache[filename]; 
        }
        else {
            if (!File.Exists(filepath)) { return BillboardObject; }

            //create sprite and set mertial to 
            byte[] FileData = File.ReadAllBytes(filepath);
            Tex2D = new Texture2D(2, 2);
            Tex2D.LoadImage(FileData);
            textureCache.Add(filename, Tex2D);
        }
        quadMeshRenderer.material.mainTexture = Tex2D;
        // Enable transparency
        quadMeshRenderer.material.SetFloat("_Mode", 3); // 3 = Transparent mode in Standard shader
        quadMeshRenderer.material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
        quadMeshRenderer.material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
        quadMeshRenderer.material.SetInt("_ZWrite", 0);
        quadMeshRenderer.material.DisableKeyword("_ALPHATEST_ON");
        quadMeshRenderer.material.EnableKeyword("_ALPHABLEND_ON");
        quadMeshRenderer.material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        quadMeshRenderer.material.renderQueue = 3000; // Transparent rendering queue


        //look into to support texture porpertys
        //quadMeshRenderer.material.SetTextureScale("_MainTex", new Vector2(1, 1)); // Scale
        //quadMeshRenderer.material.SetColor("_Color", Color.white);

        //inital rotation is -90
        //rotation around y is +
        //rotation around x is -
        //rotation around z is -

        return BillboardObject;
    }

    public string workingDirectory = ".\\testing";
    public const string levelDir = "/Levels";
    public const string codeDir = "/Code";
    public const string artDir = "/Art";
    public const string art3dDir = "/3D";
    public const string art2dDir = "/2D";
    public string LevelName = "Level_1_players_2.yaml";

    public List<string> ExternalIncludes;



    public LevelFile levelFile;
    public Dictionary<string, ObjectClass> allObjects = new Dictionary<string, ObjectClass>();
    public int levelWidth;
    public List<List<(string, ObjectClass)>> level = new List<List<(string, ObjectClass)>>(); //<<--used to set the level up in the world
    public List<GameObject> CurrentLevel;//<<-- all game objects that are in the current map 
    public GameObject placeHolder; //<----- set in editor
    public GameObject quadTemplate; //<----- set in editor


    public bool LoadedEverything = false;



    //outlines used for visual feed back to user
    public Material _hoverObj;
    public Material _selectrObj;


    //-------------------------------------used for current object manipulation
    //current object selected and if its being picked up or i sa new place
    public GameObject CurrentObjectSelect;
    public string CurrentObjectSelectID;
    public bool pickedup = false;
    //------------------------------------------
    void cleanImageCache()
    {
        string[] keys = textureCache.Keys.ToArray();
        for (int i =0; i < keys.Length; i++) {
            Destroy(textureCache[keys[i]]);
        }
        textureCache.Clear();
    }
    void cleanObjectsCache() {
        string[] keys = objectCache.Keys.ToArray();
        for (int i = 0; i < keys.Length; i++)
        {
            Destroy(objectCache[keys[i]]);
        }
        objectCache.Clear();
    }
    void OnApplicationQuit()
    {
        //reset all data holders.
        pickedup = false;
        LoadedEverything = false;
        levelFile = null;
        allObjects.Clear();
        level.Clear();

        cleanObjectsCache();

        for (int i = CurrentLevel.Count - 1; i >= 0; i--)
        {
            Destroy(CurrentLevel[i]);
        }
        CurrentLevel.Clear();

        cleanImageCache();
    }

    //------------------------------------attribute manipulation
    public GameObject attributeTable;

    //------------------------------------load external Object Files
    public void loadNewIncludes() {
        //check file exists
        string fileName = IncludeInputFeild.GetComponent<TMP_InputField>().text;
        string fullPath = workingDirectory + GlobalResources.levelDir + "/" + fileName;
        if (!File.Exists(fullPath) || levelFile.include.Contains(fileName)) { return; }

        //import the new inlcude file
        levelLoader.importExternalIncludes(fileName);

        //add new inlcude file to levelFile
        levelFile.include.Add(fileName);

        StartCoroutine(populater.populateScrollView());

    }

    //------------------------------------screenButtons <--------------all set in editor
    [SerializeField]
    GameObject LoadButton;
    [SerializeField]
    GameObject LoadNewButton;
    [SerializeField]
    GameObject ReloadButton;
    [SerializeField]
    GameObject SaveButton;

    [SerializeField]
    GameObject IncludeAddButton;
    [SerializeField]
    GameObject IncludeInputFeild;

    [SerializeField]
    GameObject placeingObjectText;

    //the input for the path and file being loaded and saved to
    public GameObject inputFilePath;


    public void LoadNewLevel() {
        OnApplicationQuit();

        LoadedEverything = false;

        LoadNewButton.SetActive(false);
        LoadButton.SetActive(true);
        inputFilePath.GetComponent<TMP_InputField>().interactable = true;

        ReloadButton.GetComponent<Button>().interactable = false;
        SaveButton.GetComponent<Button>().interactable = false;
    }
    public void reloadLevel() {
        levelExporter.saveLevel();
        start();
    }


    // Start is called before the first frame update
    void start()
    {
        //reset all data holders.
        pickedup = false;
        levelFile = null;
        allObjects.Clear();
        level.Clear();
        for (int i = CurrentLevel.Count-1; i >= 0; i--) {
            Destroy(CurrentLevel[i]);
        }
        CurrentLevel.Clear();
        LoadedEverything = false;

        string path_FileName = inputFilePath.GetComponent<TMP_InputField>().text;
        LevelName = path_FileName.Split("/")[^1];
        workingDirectory = path_FileName.Replace("/"+LevelName, "") ;

        if (levelLoader.INIT() == 1) { return; }
        if (levelLoader.loadLevel() == 1){ return; }
        if (levelLoader.LoadObjects()==1) { return; }
        if (levelLoader.parseLevel()==1) { return; }
        CurrentObjectSelectID = allObjects.Keys.First();

        //place objects in scene from level
        StartCoroutine(formLevelObjs());

        //Debug.Log(levelFile.grid);
        StartCoroutine(populater.populateScrollView());

    }

    public IEnumerator formLevelObjs() {
        LoadButton.SetActive(false);
        inputFilePath.GetComponent<TMP_InputField>().interactable = false;

        for (int y = 0, c = 0; y < level.Count / levelWidth; y++)
        { //loop throuhg the y
            for (int x = 0; x < levelWidth; x++, c++)
            { //loop throuhg the c
                Vector2 newPos = new Vector2((x * 2), (y * 2));

                //TODO if a defintion has no object or image then replace with billboard spite of definition name
                foreach ((string name, ObjectClass obj) in level[c])
                {  //loop each object in each cell
                    GameObject HolderObj = new GameObject();//holds al the models for object
                    HolderObj.AddComponent<ObjectAttributes>().objectName = name;
                    HolderObj.name = name;
                    HolderObj.transform.position = new Vector3(newPos.y, 0, newPos.x);

                    bool visible = false;
                    //take account of base obejcts, id and mapObject wont work as both can get resolved to in game objects uavaliable for viewing
                    if (obj._base != null && obj._base.Count > 0)
                    {
                        foreach (string baseObj in obj._base)
                        {
                            bool visCheck = instintateObjAsBase(baseObj, allObjects[baseObj], newPos, HolderObj, obj.DirToAngle());
                            if (visCheck && !visible)
                            {
                                visible = true;
                            }
                        }
                    }

                    //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
                    //import each object used
                    if (obj.art3d != null)
                    {
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
                                SkinnedMeshRenderer skinnedRenderer = rend as SkinnedMeshRenderer;
                                if (skinnedRenderer != null)
                                {
                                    // Create a new mesh and bake the skinned mesh into it
                                    Mesh bakedMesh = new Mesh();
                                    skinnedRenderer.BakeMesh(bakedMesh);
                                    // Assign the baked mesh to the Mesh Collider
                                    col.sharedMesh = null; // Clear old mesh reference
                                    col.sharedMesh = bakedMesh;
                                }
                            }

                            Temp.name = obj.dir;

                            //CenterPivotAtBottomMiddle(Temp);

                            Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                            Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                            Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                            ////Debug.Log(obj.dir);
                            Temp.transform.parent = HolderObj.transform;
                        }
                    }
                    if (obj.art2d != null)
                    {
                        foreach (Art2d objsArt in obj.art2d)
                        {
                            visible = true;
                            GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
                            Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
                            MeshCollider collider = Temp.GetComponent<MeshCollider>();
                            collider.isTrigger = true;

                            Temp.name = obj.dir;

                            //CenterPivotAtBottomMiddle(Temp);

                            Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset

                            Temp.transform.rotation = Quaternion.Euler(0, -90, 0);//rotate around y to get it into north east south west
                            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                            Temp.transform.Rotate(new Vector3(-objsArt.rot.x, objsArt.rot.y, -objsArt.rot.z));//added roation for inital direction

                            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);

                            MeshRenderer quadMeshRenderer = Temp.GetComponent<MeshRenderer>();
                            quadMeshRenderer.material.SetFloat("_Metallic", objsArt.metallic); // 3 = Transparent mode in Standard shader
                            quadMeshRenderer.material.SetFloat("_Glossiness", objsArt.smoothness); // 3 = Transparent mode in Standard shader


                            //use this to support billboarding
                            //if billboard or not quad(dafault to billboard if invalid)
                            if (objsArt.displayType == "billboard" || objsArt.displayType != "quad")
                            {
                                Temp.AddComponent<BillboardScript>();
                            }

                            //Debug.Log(obj.dir);
                            Temp.transform.parent = HolderObj.transform;
                        }
                    }
                    if (!visible)
                    {
                        GameObject Temp = Instantiate(placeHolder);
                        Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);
                        Temp.transform.parent = HolderObj.transform;
                    }
                    CurrentLevel.Add(HolderObj);
                    
                    
                }
            }
            yield return new WaitForSeconds(0.01f);
        }

        LoadedEverything = true;


        LoadNewButton.SetActive(true);

        ReloadButton.GetComponent<Button>().interactable = true;
        SaveButton.GetComponent<Button>().interactable = true;
        yield return null;
    }


    //when and object is used as a base it will take on the perant dir instead of the objects dir
    //used as generic and ashelp centre camer to object when taking picktures
    //returns if visible
    //false for invisible -- true for visisble
    public bool instintateObjAsBase(string name, ObjectClass obj, Vector3 newPos, GameObject HolderObj, float rotateDir = 0)
    {

        //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
        bool visible = false;
        //take account of base obejcts, id and mapObject wont work as both can get resolved to in game objects uavaliable for viewing
        if (obj._base.Count > 0)
        {
            foreach (string baseObj in obj._base)
            {
                instintateObjAsBase(baseObj, allObjects[baseObj], newPos, HolderObj, rotateDir);
            }
        }

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
                SkinnedMeshRenderer skinnedRenderer = rend as SkinnedMeshRenderer;
                if (skinnedRenderer != null)
                {
                    // Create a new mesh and bake the skinned mesh into it
                    Mesh bakedMesh = new Mesh();
                    skinnedRenderer.BakeMesh(bakedMesh);
                    //Debug.LogError(bakedMesh.vertexCount);
                    // Assign the baked mesh to the Mesh Collider
                    col.sharedMesh = null; // Clear old mesh reference
                    col.sharedMesh = bakedMesh;
                }
            }

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(newPos.y, newPos.z, newPos.x);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
            Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, rotateDir, 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
            //Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        foreach (Art2d objsArt in obj.art2d)
        {
            visible = true;
            GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
            Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
            MeshCollider collider = Temp.GetComponent<MeshCollider>();
            collider.isTrigger = true;

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset

            Temp.transform.rotation = Quaternion.Euler(0, -90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(-objsArt.rot.x, objsArt.rot.y, -objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);

            MeshRenderer quadMeshRenderer = Temp.GetComponent<MeshRenderer>();
            quadMeshRenderer.material.SetFloat("_Metallic", objsArt.metallic); // 3 = Transparent mode in Standard shader
            quadMeshRenderer.material.SetFloat("_Glossiness", objsArt.smoothness); // 3 = Transparent mode in Standard shader


            //use this to support billboarding
            //if billboard or not quad(dafault to billboard if invalid)
            if (objsArt.displayType == "billboard" || objsArt.displayType != "quad")
            {
                Temp.AddComponent<BillboardScript>();
            }
            //Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        if (!visible)
        {
            GameObject Temp = Instantiate(placeHolder);
            Temp.transform.position = new Vector3(newPos.y, newPos.z, newPos.x);
            Temp.transform.parent = HolderObj.transform;
        }
        return visible; //false for invisible -- true for visisble
    }




    //used as generic and ashelp centre camer to object when taking picktures
    public Bounds instintateObj(string name, ObjectClass obj, Vector3 newPos, GameObject HolderObj, float rotateDir = 0) {

        //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
        bool visible = false;
        Bounds bounds = new Bounds();
        //take account of base obejcts, id and mapObject wont work as both can get resolved to in game objects uavaliable for viewing
        if (obj._base.Count > 0)
        {
            foreach (string baseObj in obj._base)
            {
                bounds.Encapsulate(instintateObj(baseObj, allObjects[baseObj], newPos, HolderObj, rotateDir));
            }
        }

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
                SkinnedMeshRenderer skinnedRenderer = rend as SkinnedMeshRenderer;
                if (skinnedRenderer != null)
                {
                    // Create a new mesh and bake the skinned mesh into it
                    Mesh bakedMesh = new Mesh();
                    skinnedRenderer.BakeMesh(bakedMesh);
                    //Debug.LogError(bakedMesh.vertexCount);
                    // Assign the baked mesh to the Mesh Collider
                    col.sharedMesh = null; // Clear old mesh reference
                    col.sharedMesh = bakedMesh;
                }
                bounds.Encapsulate(col.bounds);
            }

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(newPos.y, newPos.z, newPos.x);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
            Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, rotateDir, 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
            //Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        foreach (Art2d objsArt in obj.art2d)
        {
            visible = true;
            GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
            Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
            MeshCollider collider = Temp.GetComponent<MeshCollider>();
            collider.isTrigger = true;
            bounds.Encapsulate(collider.bounds);

            Temp.name = obj.dir;

            //CenterPivotAtBottomMiddle(Temp);

            Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

            Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset

            Temp.transform.rotation = Quaternion.Euler(0, -90, 0);//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
            Temp.transform.Rotate(new Vector3(-objsArt.rot.x, objsArt.rot.y, -objsArt.rot.z));//added roation for inital direction

            Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);

            MeshRenderer quadMeshRenderer = Temp.GetComponent<MeshRenderer>();
            quadMeshRenderer.material.SetFloat("_Metallic", objsArt.metallic); // 3 = Transparent mode in Standard shader
            quadMeshRenderer.material.SetFloat("_Glossiness", objsArt.smoothness); // 3 = Transparent mode in Standard shader


            //use this to support billboarding
            //if billboard or not quad(dafault to billboard if invalid)
            if (objsArt.displayType == "billboard" || objsArt.displayType != "quad")
            {
                Temp.AddComponent<BillboardScript>();
            }

            //Debug.Log(obj.dir);
            Temp.transform.parent = HolderObj.transform;
        }
        if (!visible)
        {
            GameObject Temp = Instantiate(placeHolder);
            Temp.transform.position = new Vector3(newPos.y, newPos.z, newPos.x);
            Temp.transform.parent = HolderObj.transform;
            bounds.Encapsulate(Temp.GetComponent<Collider>().bounds);
        }

        return bounds;
    }




    //used by mouse to create new visual when placeing
    public GameObject createObject(string name)
    {
        Vector3 newPos = new Vector3(0, 0, 0);

        ObjectClass obj = allObjects[name];
        GameObject HolderObj = new GameObject();//holds al the models for object
        HolderObj.AddComponent<ObjectAttributes>().objectName = name;
        HolderObj.name = name;
        HolderObj.transform.position = new Vector3(newPos.y, 0, newPos.x);

        bool visible = false;
        //take account of base obejcts, id and mapObject wont work as both can get resolved to in game objects uavaliable for viewing
        if (obj._base != null && obj._base.Count > 0)
        {
            foreach (string baseObj in obj._base)
            {
                bool visCheck = instintateObjAsBase(baseObj, allObjects[baseObj], newPos, HolderObj, obj.DirToAngle());
                if (visCheck && !visible)
                {
                    visible = true;
                }
            }
        }

        //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
        //import each object used
        if (obj.art3d != null)
        {
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
                    SkinnedMeshRenderer skinnedRenderer = rend as SkinnedMeshRenderer;
                    if (skinnedRenderer != null)
                    {
                        // Create a new mesh and bake the skinned mesh into it
                        Mesh bakedMesh = new Mesh();
                        skinnedRenderer.BakeMesh(bakedMesh);
                        // Assign the baked mesh to the Mesh Collider
                        col.sharedMesh = null; // Clear old mesh reference
                        col.sharedMesh = bakedMesh;
                    }
                }

                Temp.name = obj.dir;

                //CenterPivotAtBottomMiddle(Temp);

                Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                //Debug.Log(obj.dir);
                Temp.transform.parent = HolderObj.transform;
            }
        }
        if (obj.art2d != null)
        {
            foreach (Art2d objsArt in obj.art2d)
            {
                visible = true;
                GameObject Temp = ImportImage(workingDirectory + artDir + art2dDir + "/" + objsArt.texture);
                Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
                MeshCollider collider = Temp.GetComponent<MeshCollider>();
                collider.isTrigger = true;

                Temp.name = obj.dir;

                //CenterPivotAtBottomMiddle(Temp);

                Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);

                Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset

                Temp.transform.rotation = Quaternion.Euler(0, -90, 0);//rotate around y to get it into north east south west
                Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                Temp.transform.Rotate(new Vector3(-objsArt.rot.x, objsArt.rot.y, -objsArt.rot.z));//added roation for inital direction

                Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);

                MeshRenderer quadMeshRenderer = Temp.GetComponent<MeshRenderer>();
                quadMeshRenderer.material.SetFloat("_Metallic", objsArt.metallic); // 3 = Transparent mode in Standard shader
                quadMeshRenderer.material.SetFloat("_Glossiness", objsArt.smoothness); // 3 = Transparent mode in Standard shader


                //use this to support billboarding
                //if billboard or not quad(dafault to billboard if invalid)
                if (objsArt.displayType == "billboard" || objsArt.displayType != "quad")
                {
                    Temp.AddComponent<BillboardScript>();
                }

                //Debug.Log(obj.dir);
                Temp.transform.parent = HolderObj.transform;
            }
        }
        if (!visible)
        {
            GameObject Temp = Instantiate(placeHolder);
            Temp.transform.position = new Vector3(newPos.y, 0, newPos.x);
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

        //Debug.Log($"Pivot of '{target.name}' has been recentered to the bottom middle.");
    }


    // Update is called once per frame
    void Update()
    {
        placeingObjectText.GetComponent<TextMeshProUGUI>().text = "Placing: "+CurrentObjectSelectID;



    }
}
