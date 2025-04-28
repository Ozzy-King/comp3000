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

public class levelExporterTest
{

    [Test]
    public void checkRecreateLevelLayout(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "testManyObj.yaml";

        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        l.parseLevel();

        LevelExporter e = a.AddComponent<LevelExporter>();
        e.globres = g;
        g.CurrentLevel = new List<GameObject>();
        g.CurrentLevel.Clear();

        GameObject tempObj = new GameObject();
        int rnHeight = Random.Range(1, 10);
        int rnWidth = Random.Range(1, 10);
        for(int y = 0; y < rnHeight*2; y+=2){
            for(int x = 0; x < rnWidth*2; x+=2){
                GameObject n = GameObject.Instantiate(tempObj);
                n.transform.position = new Vector3(y, 0 , x);
                n.name = "newObj";
                g.CurrentLevel.Add(n);
            }
        }
        e.RecreateLevelLayout();
        Assert.AreEqual(e.CurrentLevelMapped.GetLength(0), rnHeight);
        Assert.AreEqual(e.CurrentLevelMapped.GetLength(1), rnWidth);
    
        GameObject.DestroyImmediate(a); 
    }


    [Test]
    public void checkCreateOutputYaml(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "testManyObj.yaml";

        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        l.parseLevel();

        LevelExporter e = a.AddComponent<LevelExporter>();
        e.globres = g;
        g.CurrentLevel = new List<GameObject>();
        g.CurrentLevel.Clear();

        GameObject tempObj = new GameObject();
        int rnHeight = Random.Range(1, 10);
        int rnWidth = Random.Range(1, 10);
        for(int y = 0; y < rnHeight*2; y+=2){
            for(int x = 0; x < rnWidth*2; x+=2){
                GameObject n = GameObject.Instantiate(tempObj);
                n.transform.position = new Vector3(y, 0 , x);
                n.name = "inFile1";
                ObjectAttributes temppp = n.AddComponent<ObjectAttributes>();
                temppp.objectName = "inFile1";
                g.CurrentLevel.Add(n);
            }
        }
        e.RecreateLevelLayout();
        Debug.Log(">>>>>>><<<<<<<<<<");

        e.createOutputYaml();

        g.allObjects.Clear();
        l.LoadObjects();
        l.loadLevel();
        l.parseLevel();

        int levely = g.levelFile.grid.Split('\n', System.StringSplitOptions.RemoveEmptyEntries).Length;
        int levelx = g.levelWidth;

        Assert.AreEqual(rnHeight, levely);
        Assert.AreEqual(rnWidth, levelx);

        GameObject.DestroyImmediate(a); 
    }


    [Test]
    public void checkCreateLevel(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "testManyObj.yaml";

        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        l.parseLevel();

        LevelExporter e = a.AddComponent<LevelExporter>();
        e.globres = g;
        g.CurrentLevel = new List<GameObject>();
        g.CurrentLevel.Clear();

        GameObject tempObj = new GameObject();
        int rnHeight = Random.Range(1, 10);
        int rnWidth = Random.Range(1, 10);
        for(int y = 0; y < rnHeight*2; y+=2){
            for(int x = 0; x < rnWidth*2; x+=2){
                GameObject n = GameObject.Instantiate(tempObj);
                n.transform.position = new Vector3(y, 0 , x);
                n.name = "inFile1";
                ObjectAttributes temppp = n.AddComponent<ObjectAttributes>();
                temppp.objectName = "inFile1";
                g.CurrentLevel.Add(n);
            }
        }
        e.saveLevel();

        g.allObjects.Clear();
        l.LoadObjects();
        l.loadLevel();
        l.parseLevel();

        int levely = g.levelFile.grid.Split('\n', System.StringSplitOptions.RemoveEmptyEntries).Length;
        int levelx = g.levelWidth;

        Assert.AreEqual(rnHeight, levely);
        Assert.AreEqual(rnWidth, levelx);

        GameObject.DestroyImmediate(a); 
    }


    // A UnityTest behaves like a coroutine in Play Mode. In Edit Mode you can use
    // `yield return null;` to skip a frame.
    //[UnityTest]
    //public IEnumerator NewTestScriptWithEnumeratorPasses()
    //{
    //    // Use the Assert class to test conditions.
    //    // Use yield to skip a frame.
    //    yield return null;
    //}
}
