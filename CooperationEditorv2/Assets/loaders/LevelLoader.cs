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

    public void loadLevel() {
        //currently assuming existing levels are getting edited
        if (!File.Exists(globalResources.workingDirectory + GlobalResources.levelDir + globalResources.LevelName)) { return; }

        //read yaml file in
        string yml =File.ReadAllText(globalResources.workingDirectory + GlobalResources.levelDir + globalResources.LevelName);
        Debug.Log(yml);
        //create desirializer and store result in global resoources
        IDeserializer deserializer = new DeserializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance).IgnoreUnmatchedProperties()
            .Build();

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

        //be caeful circular definitions will cause this to infintly loop
        IDeserializer deserializer = new DeserializerBuilder()
     .WithNamingConvention(CamelCaseNamingConvention.Instance)
     .Build();

        List<string> includeFiles = globalResources.levelFile.include;
        foreach (string includeFile in includeFiles)
        {
            //get full path and deerilize new file
            string fullPath = globalResources.workingDirectory + GlobalResources.levelDir + includeFile;
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
                List<ObjectClass> ObjList = new List<ObjectClass>();//list to hold objects for the cell
                List<string> GridPosList = globalResources.levelFile.gridObjects[comps[i]];//get the list of object used in the cell
                foreach (string gridObjName in GridPosList) { //loop thouhgh the object in cell
                    ObjList.Add(globalResources.allObjects[gridObjName]);//find the object class which hass all attributes and add to list
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
