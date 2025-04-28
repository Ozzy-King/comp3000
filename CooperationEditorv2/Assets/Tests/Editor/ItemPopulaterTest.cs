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

using UnityEngine;
using UnityEngine.UI;
using TMPro;

using System.Linq.Expressions;
using System.Linq;

public class ItemPopulaterTest
{
    [UnityTest]
    public IEnumerator checkPopulateScrollView(){
        //setup level loader
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
        l.parseLevel();
        
        //setup theitem populator
        GameObject buttonTemp = new GameObject();//create button tempalte
        Button buttonTempBut = buttonTemp.AddComponent<Button>();
        GameObject buttonTempChild = new GameObject();//create butom template child
        TextMeshProUGUI buttonTempChildText = buttonTempChild.AddComponent<TextMeshProUGUI>();
        buttonTempChild.transform.parent = buttonTemp.transform;

        GameObject[] itemLis = new GameObject[13];

        for (int j = 0; j < itemLis.Length; j++)
        {
            itemLis[j] = GameObject.Instantiate(buttonTemp);
        }

        GameObject page = new GameObject();
        page.AddComponent<TextMeshProUGUI>();
        GameObject searchBox = new GameObject();
        searchBox.AddComponent<TMP_InputField>();


        ItemPopulater i = a.AddComponent<ItemPopulater>();
        FieldInfo itemPop_glob = typeof(ItemPopulater).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_ItList = typeof(ItemPopulater).GetField("ItemList", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_searchBox = typeof(ItemPopulater).GetField("searchTextInput", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_PgNum = typeof(ItemPopulater).GetField("pageNumber", BindingFlags.NonPublic | BindingFlags.Instance);

        itemPop_glob.SetValue(i, g);
        itemPop_searchBox.SetValue(i, searchBox);
        itemPop_PgNum.SetValue(i, page);
        itemPop_ItList.SetValue(i, itemLis);

        yield return i.populateScrollView();

        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile");

        GameObject.DestroyImmediate(a); 
    }


    [UnityTest]
    public IEnumerator checkPageForward_PageBackward(){
        //setup level loader
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
        
        //setup theitem populator
        GameObject buttonTemp = new GameObject();//create button tempalte
        Button buttonTempBut = buttonTemp.AddComponent<Button>();
        GameObject buttonTempChild = new GameObject();//create butom template child
        TextMeshProUGUI buttonTempChildText = buttonTempChild.AddComponent<TextMeshProUGUI>();
        buttonTempChild.transform.parent = buttonTemp.transform;

        GameObject[] itemLis = new GameObject[13];

        for (int j = 0; j < itemLis.Length; j++)
        {
            itemLis[j] = GameObject.Instantiate(buttonTemp);
        }

        GameObject page = new GameObject();
        page.AddComponent<TextMeshProUGUI>();
        GameObject searchBox = new GameObject();
        searchBox.AddComponent<TMP_InputField>();


        ItemPopulater i = a.AddComponent<ItemPopulater>();
        FieldInfo itemPop_glob = typeof(ItemPopulater).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_ItList = typeof(ItemPopulater).GetField("ItemList", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_searchBox = typeof(ItemPopulater).GetField("searchTextInput", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_PgNum = typeof(ItemPopulater).GetField("pageNumber", BindingFlags.NonPublic | BindingFlags.Instance);

        itemPop_glob.SetValue(i, g);
        itemPop_searchBox.SetValue(i, searchBox);
        itemPop_PgNum.SetValue(i, page);
        itemPop_ItList.SetValue(i, itemLis);

        yield return i.populateScrollView();

        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile1");
        Assert.AreEqual(page.GetComponent<TMP_Text>().text, "1/3");

        i.pageForward();
        yield return i.populateScrollView();
        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile14");
        Assert.AreEqual(page.GetComponent<TMP_Text>().text, "2/3");

        i.pageBackward();
        yield return i.populateScrollView();
        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile1");
        Assert.AreEqual(page.GetComponent<TMP_Text>().text, "1/3");

        GameObject.DestroyImmediate(a); 
    }


    [UnityTest]
    public IEnumerator checkOnSearchChange(){
        //setup level loader
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
        
        //setup theitem populator
        GameObject buttonTemp = new GameObject();//create button tempalte
        Button buttonTempBut = buttonTemp.AddComponent<Button>();
        GameObject buttonTempChild = new GameObject();//create butom template child
        TextMeshProUGUI buttonTempChildText = buttonTempChild.AddComponent<TextMeshProUGUI>();
        buttonTempChild.transform.parent = buttonTemp.transform;

        GameObject[] itemLis = new GameObject[13];

        for (int j = 0; j < itemLis.Length; j++)
        {
            itemLis[j] = GameObject.Instantiate(buttonTemp);
        }

        GameObject page = new GameObject();
        page.AddComponent<TextMeshProUGUI>();
        GameObject searchBox = new GameObject();
        searchBox.AddComponent<TMP_InputField>();


        ItemPopulater i = a.AddComponent<ItemPopulater>();
        FieldInfo itemPop_glob = typeof(ItemPopulater).GetField("globalResources", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_ItList = typeof(ItemPopulater).GetField("ItemList", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_searchBox = typeof(ItemPopulater).GetField("searchTextInput", BindingFlags.NonPublic | BindingFlags.Instance);
        FieldInfo itemPop_PgNum = typeof(ItemPopulater).GetField("pageNumber", BindingFlags.NonPublic | BindingFlags.Instance);

        itemPop_glob.SetValue(i, g);
        itemPop_searchBox.SetValue(i, searchBox);
        itemPop_PgNum.SetValue(i, page);
        itemPop_ItList.SetValue(i, itemLis);

        yield return i.populateScrollView();

        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile1");
        Assert.AreEqual(page.GetComponent<TMP_Text>().text, "1/3");

        searchBox.GetComponent<TMP_InputField>().text = "12";
        i.OnSearchChange();
        yield return i.populateScrollView();
        Assert.AreEqual(itemLis[0].GetComponentInChildren<TextMeshProUGUI>().text, "inFile12");
        Assert.AreEqual(page.GetComponent<TMP_Text>().text, "1/1");


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
