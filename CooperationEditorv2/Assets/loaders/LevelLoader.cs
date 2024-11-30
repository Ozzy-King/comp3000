using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;


public class LevelLoader : MonoBehaviour
{
    [SerializeField]
    GlobalResources globalResources;

    IDeserializer deserializer;
    ISerializer serializer;

    public void INIT() {
        deserializer = new DeserializerBuilder().IgnoreUnmatchedProperties()
                .WithNamingConvention(CamelCaseNamingConvention.Instance)
                .Build();
        serializer = new SerializerBuilder()
        .WithNamingConvention(CamelCaseNamingConvention.Instance)
        .Build();
    }

    public void loadLevel() {
        string filepath = globalResources.workingDirectory + GlobalResources.levelDir + "/" + globalResources.LevelName;
        //currently assuming existing levels are getting edited
        if (!File.Exists(filepath)) { return; }

        //read yaml file in
        string yml =File.ReadAllText(filepath);
        Debug.Log(yml);
        //create desirializer and store result in global resoources

        //yaml contains a string containing your YAML
        LevelFile p = deserializer.Deserialize<LevelFile>(yml);
        globalResources.levelFile = p;
        


        var serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        var yaml = serializer.Serialize(p);
        Debug.Log(yaml);
    }

    /// <summary>
    /// go though the inluced
    /// </summary>
    public void LoadObjects()
    {
        //first add object definitonas from level file
        if (globalResources.levelFile.objectDefinitions != null)
        {
            foreach ((string objName, ObjectClass obj) in globalResources.levelFile.objectDefinitions)
            {
                globalResources.allObjects.Add(objName, obj);
            }
        }

        List<string> includeFiles = globalResources.levelFile.include;
        foreach (string includeFile in includeFiles)
        {
            //get full path and deerilize new file
            string fullPath = globalResources.workingDirectory + GlobalResources.levelDir + "/" + includeFile;
            Debug.Log(fullPath);
            LevelFile newIncludeFile = deserializer.Deserialize<LevelFile>(File.ReadAllText(fullPath));
            //add includes files to current list
            foreach (string t in newIncludeFile.include)
            {
                includeFiles.Add(t);
            }
            //add each object to the global List
            foreach ((string objName, ObjectClass obj) in newIncludeFile.objectDefinitions) {
                if (!globalResources.allObjects.ContainsKey(objName)) {
                    globalResources.allObjects.Add(objName, obj);
                }
            }
        }
    
    }

    public void parseLevel() {

        string[] levelRows = globalResources.levelFile.grid.Split('\n', System.StringSplitOptions.RemoveEmptyEntries);
        foreach (string row in levelRows) {
            
            string[] comps = row.Split(',');//split to individual components
            globalResources.levelWidth = comps.Length;
            //loop though each cell(component) in the row
            for (int i = 0; i < comps.Length; i++) { 
                comps[i] = comps[i].Trim(' ');
                List<(string, ObjectClass)> ObjList = new List<(string, ObjectClass)>();//list to hold objects for the cell
                List<string> GridPosList = globalResources.levelFile.gridObjects[comps[i]];//get the list of object used in the cell
                foreach (string gridObjName in GridPosList) { //loop thouhgh the object in cell
                    ObjList.Add((gridObjName, globalResources.allObjects[gridObjName]));//find the object class which hass all attributes and add to list
                }
                globalResources.level.Add(ObjList);//add cells object list to 
            } //get rid of leading and trailing space
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
