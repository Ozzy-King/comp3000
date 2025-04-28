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

public class levelLoaderTest
{
    // levelLoader
    [Test]
    public void checkNullValues()
    {
        GameObject a = new GameObject();
        LevelLoader t = a.AddComponent<LevelLoader>();

        FieldInfo dezField = typeof(LevelLoader).GetField("deserializer", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo serField = typeof(LevelLoader).GetField("serializer", BindingFlags.NonPublic | BindingFlags.Instance);

        var deserializerValue = dezField.GetValue(t);
        var serializerValue = serField.GetValue(t);

      
        Assert.IsNull(deserializerValue);
        Assert.IsNull(serializerValue);

        GameObject.DestroyImmediate(a);
    }

    [Test]
    public void checkINITValues(){
        GameObject a = new GameObject();
        LevelLoader t = a.AddComponent<LevelLoader>();
        var res = t.INIT();

        FieldInfo dezField = typeof(LevelLoader).GetField("deserializer", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo serField = typeof(LevelLoader).GetField("serializer", BindingFlags.NonPublic | BindingFlags.Instance);

        var deserializerValue = dezField.GetValue(t);
        var serializerValue = serField.GetValue(t);

      
        Assert.IsNotNull(deserializerValue);
        Assert.IsNotNull(serializerValue);
        Assert.AreEqual(res, 0);

        GameObject.DestroyImmediate(a);
    }

        [Test]
    public void checkLoadLevelValues(){
        

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        var res = l.INIT();
        Assert.IsNotNull(glob.GetValue(l));

        g.workingDirectory = "./testDir";

        //test file dosent exists
        g.LevelName = "doesntExist.yaml";
        res = l.loadLevel();
        Assert.AreEqual(res, 1);

        //test file exists
        g.LevelName = "test.yaml";
        res = l.loadLevel();
        Assert.AreEqual(res, 0);

        Assert.IsNotNull(g.levelFile);

        GameObject.DestroyImmediate(a);
    }


    //circulardef
    [Test]
    public void checkObjectLevelWithoutInclude(){
        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";

        l.INIT();

        g.LevelName = "test.yaml";
        l.loadLevel();
        var res = l.LoadObjects();
        Assert.AreEqual(res, 0);
        Assert.AreEqual(g.levelFile.objectDefinitions.Count, 1);


        GameObject.DestroyImmediate(a); 
    }
    [Test]
    public void checkObjectLevelWithInclude(){
        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";

        l.INIT();

        g.LevelName = "testWithInclude.yaml";
        l.loadLevel();
        var res = l.LoadObjects();
        Assert.AreEqual(res, 0);
        Assert.AreEqual(g.levelFile.objectDefinitions.Count, 1);


        GameObject.DestroyImmediate(a); 
    }
    [Test]
    public void checkObjectLevelCircInclude(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";

        l.INIT();

        g.LevelName = "testWithIncludeCirc.yaml";
        l.loadLevel();
        LogAssert.Expect(LogType.Error, new Regex("Error parsing YAML in testWithIncludeCirc.yaml"));
        LogAssert.Expect(LogType.Error, new Regex("Error parsing YAML at line 1, column 1."));
        LogAssert.Expect(LogType.Error, new Regex("Error message: circular file includes: testWithIncludeCirc.yaml"));

        var res = l.LoadObjects();
        Assert.AreEqual(res, 0);
        Assert.AreEqual(g.levelFile.objectDefinitions.Count, 1);

        GameObject.DestroyImmediate(a); 
    }



    [Test]
    public void checkParseLevel(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "test.yaml";

        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        var res = l.parseLevel();
        
        Assert.AreEqual(res, 0);
        Assert.AreEqual(g.levelFile.grid, "__\n");
        Assert.AreEqual(g.levelFile.gridObjects.Count, 1);
        //Assert.AreEqual(g.levelFile.grid, 1);

        GameObject.DestroyImmediate(a); 
    }
    [Test]
    public void checkParseLevelAnonymous(){

        GameObject a = new GameObject();
        LevelLoader l = a.AddComponent<LevelLoader>();
        GlobalResources g = a.AddComponent<GlobalResources>();
        FieldInfo glob = typeof(LevelLoader).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        glob.SetValue(l, g);
        g.workingDirectory = "./testDir";
        g.LevelName = "testAnon.yaml";

        l.INIT();
        l.loadLevel();
        l.LoadObjects();
        var res = l.parseLevel();
        
        Assert.AreEqual(res, 0);
        Assert.AreEqual(g.levelFile.objectDefinitions.Count, 2);

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
