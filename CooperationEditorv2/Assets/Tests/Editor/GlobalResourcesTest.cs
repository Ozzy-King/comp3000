using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using System.Reflection;

using System.Text.RegularExpressions;

using YamlDotNet.Core;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

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


public class GlobalResourcesTest
{
    GameObject cameraGO;
    [SetUp]
    public void SetUp()
    {
        // Create a mock camera GameObject
        cameraGO = new GameObject("TestCamera");
        Camera cam = cameraGO.AddComponent<Camera>();
        cam.tag = "MainCamera"; // Important: Unity uses this to define Camera.main

        // Set its position to mock
        cameraGO.transform.position = new Vector3(10, 20, 30);
    }

    [Test]
    public void checkImportGLTF(){
        FieldInfo globResObjCache = typeof(GlobalResources).GetField("objectCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResObjCachePerant = typeof(GlobalResources).GetField("objectCachePerant", BindingFlags.NonPublic | BindingFlags.Instance);
        GameObject p = new GameObject();

        GameObject a = new GameObject();
        GlobalResources g = a.AddComponent<GlobalResources>();
        globResObjCachePerant.SetValue(g, p);
        
        Dictionary<string, GameObject> cache = (Dictionary<string, GameObject>)globResObjCache.GetValue(g);

        Assert.AreEqual(cache.Count, 0); //empty test
        
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloor.glb"); //inital add test
        Assert.AreEqual(cache.Count, 1);

        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloor.glb"); //readd test, shouldnt add it again
        Assert.AreEqual(cache.Count, 1);
        
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloorEnd.glb"); //can add another one
        Assert.AreEqual(cache.Count, 2);
    }
    [Test]
    public void checkImportImage(){
        List<GameObject> catchOBJ = new List<GameObject>();
        LogAssert.ignoreFailingMessages = true;

        FieldInfo globResTexCache = typeof(GlobalResources).GetField("textureCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResObjCachePerant = typeof(GlobalResources).GetField("objectCachePerant", BindingFlags.NonPublic | BindingFlags.Instance);
        GameObject p = new GameObject();
        
        GameObject qua = new GameObject();
        qua.AddComponent<MeshRenderer>();


        GameObject a = new GameObject();
        GlobalResources g = a.AddComponent<GlobalResources>();
        globResObjCachePerant.SetValue(g, p);
        g.quadTemplate = qua;
        
        Dictionary<string, Texture2D> cache = (Dictionary<string, Texture2D>)globResTexCache.GetValue(g);

        Assert.AreEqual(cache.Count, 0); //empty test
        
        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/BucketTut.png")); //inital add test
        Assert.AreEqual(cache.Count, 1);

        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/BucketTut.png")); //readd test, shouldnt add it again
        Assert.AreEqual(cache.Count, 1);

        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/LeverTut.png")); //can add another one
        Assert.AreEqual(cache.Count, 2);

        for(int i = 0; i < 2; i++){
            UnityEngine.Object.DestroyImmediate(catchOBJ[i].GetComponent<MeshRenderer>().material);
            GameObject.DestroyImmediate(catchOBJ[i]);
        }
        GameObject.DestroyImmediate(a);
    }

    [Test]
    public void checkClearCacheObjects_Image(){
        List<GameObject> catchOBJ = new List<GameObject>();
        LogAssert.ignoreFailingMessages = true;

        MethodInfo globCleanImageCache= typeof(GlobalResources).GetMethod("cleanImageCache", BindingFlags.NonPublic | BindingFlags.Instance);
        MethodInfo globCleanObjectCache = typeof(GlobalResources).GetMethod("cleanObjectsCache", BindingFlags.NonPublic | BindingFlags.Instance);

        FieldInfo globResObjCache = typeof(GlobalResources).GetField("objectCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResTexCache = typeof(GlobalResources).GetField("textureCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResObjCachePerant = typeof(GlobalResources).GetField("objectCachePerant", BindingFlags.NonPublic | BindingFlags.Instance);
        GameObject p = new GameObject();
        
        GameObject qua = new GameObject();
        qua.AddComponent<MeshRenderer>();


        GameObject a = new GameObject();
        GlobalResources g = a.AddComponent<GlobalResources>();
        globResObjCachePerant.SetValue(g, p);
        g.quadTemplate = qua;
        
        Dictionary<string, Texture2D> cache = (Dictionary<string, Texture2D>)globResTexCache.GetValue(g);
        
        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/BucketTut.png")); //inital add test
        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/LeverTut.png")); //can add another one

        Dictionary<string, GameObject> Objcache = (Dictionary<string, GameObject>)globResObjCache.GetValue(g);
        
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloor.glb"); //inital add test
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloorEnd.glb"); //can add another 
        
        Assert.AreEqual(cache.Count, 2);
        Assert.AreEqual(Objcache.Count, 2);

        globCleanImageCache.Invoke(g, null);
        globCleanObjectCache.Invoke(g, null);

        Assert.AreEqual(cache.Count, 0);
        Assert.AreEqual(Objcache.Count, 0);

        for(int i = 0; i < 2; i++){
            UnityEngine.Object.DestroyImmediate(catchOBJ[i].GetComponent<MeshRenderer>().material);
            GameObject.DestroyImmediate(catchOBJ[i]);
        }
        GameObject.DestroyImmediate(a);

    }

    [Test]
    public void checkOnApplicationQuit(){
        MethodInfo globOnAppQuit= typeof(GlobalResources).GetMethod("OnApplicationQuit", BindingFlags.NonPublic | BindingFlags.Instance);

        List<GameObject> catchOBJ = new List<GameObject>();
        LogAssert.ignoreFailingMessages = true;

        MethodInfo globCleanImageCache= typeof(GlobalResources).GetMethod("cleanImageCache", BindingFlags.NonPublic | BindingFlags.Instance);
        MethodInfo globCleanObjectCache = typeof(GlobalResources).GetMethod("cleanObjectsCache", BindingFlags.NonPublic | BindingFlags.Instance);

        FieldInfo globResObjCache = typeof(GlobalResources).GetField("objectCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResTexCache = typeof(GlobalResources).GetField("textureCache", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo globResObjCachePerant = typeof(GlobalResources).GetField("objectCachePerant", BindingFlags.NonPublic | BindingFlags.Instance);
        GameObject p = new GameObject();
        
        GameObject qua = new GameObject();
        qua.AddComponent<MeshRenderer>();


        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "testManyObj.yaml";

        globResObjCachePerant.SetValue(g, p);
        g.quadTemplate = qua;
        
        Dictionary<string, Texture2D> cache = (Dictionary<string, Texture2D>)globResTexCache.GetValue(g);
        
        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/BucketTut.png")); //inital add test
        catchOBJ.Add(g.ImportImage("./testDir/Art/2D/LeverTut.png")); //can add another one

        Dictionary<string, GameObject> Objcache = (Dictionary<string, GameObject>)globResObjCache.GetValue(g);
        
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloor.glb"); //inital add test
        g.ImportGLTF("./testDir/Art/3D/Levers/Red/LeverRFloorEnd.glb"); //can add another 


        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        l.parseLevel();

        g.CurrentLevel = new List<GameObject>();
        g.CurrentLevel.Add(new GameObject());
        g.pickedup = true;
        g.LoadedEverything = true;
        //levelFile
        //allObjects
        //level
        //Objcache
        //cache

        //check all values that OnAppcliationQUit resets

        Assert.AreEqual(g.pickedup, true);
        Assert.AreEqual(g.LoadedEverything, true);
        Assert.IsNotNull(g.levelFile);
        Assert.Greater(g.allObjects.Count, 0);
        Assert.Greater(g.level.Count, 0);
        Assert.Greater(Objcache.Count, 0);
        Assert.Greater(cache.Count, 0);

        globOnAppQuit.Invoke(g, null);

        Assert.AreEqual(g.pickedup, false);
        Assert.AreEqual(g.LoadedEverything, false);
        Assert.IsNull(g.levelFile);
        Assert.AreEqual(g.allObjects.Count, 0);
        Assert.AreEqual(g.level.Count, 0);
        Assert.AreEqual(Objcache.Count, 0);
        Assert.AreEqual(cache.Count, 0);


        for(int i = 0; i < 2; i++){
            UnityEngine.Object.DestroyImmediate(catchOBJ[i].GetComponent<MeshRenderer>().material);
            GameObject.DestroyImmediate(catchOBJ[i]);
        }
        GameObject.DestroyImmediate(a);

    }




    [Test]
    public void checkPopulateDropDown(){
        FieldInfo GlobBut = typeof(GlobalResources).GetField("LoadButton", BindingFlags.NonPublic | BindingFlags.Instance);

        GameObject a = new GameObject();
        
        GlobalResources g = a.AddComponent<GlobalResources>();

        GameObject text = new GameObject();
        TMP_InputField textFeild = text.AddComponent<TMP_InputField>();
        textFeild.text = "./testDir";

        GameObject DropDown = new GameObject();
        TMP_Dropdown dropdown = DropDown.AddComponent<TMP_Dropdown>();

        GameObject button = new GameObject();
        Button but = button.AddComponent<Button>();

        g.levelDropdown = dropdown;
        g.inputFilePath = text;
        GlobBut.SetValue(g, button);

        g.populateLevelDropDown();
        Assert.Greater(dropdown.options.Count, 1);
    
        GameObject.DestroyImmediate(a);
    }
    [TearDown]
    public void TearDown()
    {
        GameObject.DestroyImmediate(cameraGO);
    }
}
