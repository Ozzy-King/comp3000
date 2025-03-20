using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using YamlDotNet.Core;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;


public class LevelLoader : MonoBehaviour
{
    [SerializeField]
    GlobalResources globalResources;

    IDeserializer deserializer;
    ISerializer serializer;

    public int INIT() {
        deserializer = new DeserializerBuilder().IgnoreUnmatchedProperties()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();


        return 0;
    }

    ObjectClass convertObjToObjectClass(object objectClass) {
        string yaml = serializer.Serialize(objectClass);
        return deserializer.Deserialize<ObjectClass>(yaml);
    }

    public int loadLevel() {
        string filepath = globalResources.workingDirectory + GlobalResources.levelDir + "/" + globalResources.LevelName;
        //currently assuming existing levels are getting edited
        if (!File.Exists(filepath)) { return 1; }

        //read yaml file in
        string yml =File.ReadAllText(filepath);
        //Debug.Log(yml);
        //create desirializer and store result in global resoources

        //yml contains a string containing your YAML
        LevelFile p = deserializer.Deserialize<LevelFile>(yml);
        globalResources.levelFile = p;
        


        var serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        var yaml = serializer.Serialize(p);
        //Debug.Log(yaml);
        return 0;
    }

    /// <summary>
    /// go though the inluced
    /// </summary>
    public int LoadObjects()
    {
        //first add object definitonas from level file to global all objects list
        if (globalResources.levelFile.objectDefinitions != null)
        {
            foreach ((string objName, ObjectClass obj) in globalResources.levelFile.objectDefinitions)
            {
                globalResources.allObjects.Add(objName, obj);
            }
        }

        //get the list of inlcude files in the levelfiles
        List<string> includeFiles =new List<string>();
        //copy the list over to not add external yamls with saveing
        foreach (string a in globalResources.levelFile.include) {
            includeFiles.Add(a);
        }

        for (int i = 0; i < includeFiles.Count; i++) { 

            string includeFile = includeFiles[i];
            //get full path and deerilize new included file
            try
            { 
                string fullPath = globalResources.workingDirectory + GlobalResources.levelDir + "/" + includeFile;
                //Debug.Log(fullPath);
                LevelFile newIncludeFile = deserializer.Deserialize<LevelFile>(File.ReadAllText(fullPath));
                //add includes files to current list
                if (newIncludeFile.include != null)
                {
                    foreach (string t in newIncludeFile.include)
                    {
                        includeFiles.Add(t);
                    }
                }
                //add each object to the global List
                if (newIncludeFile.objectDefinitions != null)
                {
                    foreach ((string objName, ObjectClass obj) in newIncludeFile.objectDefinitions)
                    {
                        if (!globalResources.allObjects.ContainsKey(objName))
                        {
                            globalResources.allObjects.Add(objName, obj);
                        }
                    }
                }
            }
            catch (YamlException ex)
            {
                Debug.LogError($"Error parsing YAML int {includeFile}");
                Debug.LogError($"Error parsing YAML at line {ex.Start.Line}, column {ex.Start.Column}.");
                Debug.LogError($"Error message: {ex.Message}");
            }

        }
        return 0;
    
    }

    public int parseLevel() {
        int anonymousCounter = 0;
        string[] levelRows = globalResources.levelFile.grid.Split('\n', System.StringSplitOptions.RemoveEmptyEntries);
        foreach (string row in levelRows) {
            
            string[] comps = row.Split(',', System.StringSplitOptions.RemoveEmptyEntries);//split to individual components
            globalResources.levelWidth = comps.Length;
            //loop though each cell(component) in the row
            for (int i = 0; i < comps.Length; i++) { 
                comps[i] = comps[i].Trim(' ');
                List<(string, ObjectClass)> ObjList = new List<(string, ObjectClass)>();//list to hold objects for the cell
                List<object> GridPosList = globalResources.levelFile.gridObjects[comps[i]];//get the list of object used in the cell
                foreach (object gridObjName in GridPosList)
                { //loop thouhgh the object in cell
                    //tests if it is a predifened object
                    if (gridObjName is string)
                    {
                        ObjList.Add(((string)gridObjName, globalResources.allObjects[(string)gridObjName]));//find the object class which hass all attributes and add to list
                    }
                    //if it is an anoymous object then will need to create a object class 
                    else {
                        //cast the ojebct to an object class and add it to to the all object list
                        ObjectClass newClassVar = convertObjToObjectClass(gridObjName);
                        //Debug.Log(newClassVar);
                        //Debug.Log(gridObjName);
                        string ObjectClassName = "__anonymous__" + Random.Range(0, int.MaxValue);
                        globalResources.allObjects.Add(ObjectClassName, newClassVar);
                        //add to level defninition to be inlcuded in export
                        globalResources.levelFile.objectDefinitions.Add(ObjectClassName, newClassVar);
                        //add object to object list
                        ObjList.Add( (ObjectClassName, globalResources.allObjects[ObjectClassName]) );
                        anonymousCounter++;
                    }
                }
                globalResources.level.Add(ObjList);//add cells object list to 
            } //get rid of leading and trailing space
        }
        return 0;
    }


    public void importExternalIncludes(string file) {
        List<string> includeList = new List<string>();
        includeList.Add(file);

        Dictionary<string, ObjectClass> newObjectsDefs = new Dictionary<string, ObjectClass>();

        /////TODO add checks to make sure all loaded correctly
        for (int i = 0; i < includeList.Count; i++) {
            //find and deserililize file
            string fullPath = globalResources.workingDirectory + GlobalResources.levelDir + "/" + includeList[i];
            //Debug.Log(fullPath);
            LevelFile newIncludeFile = deserializer.Deserialize<LevelFile>(File.ReadAllText(fullPath));

            //add included include file to include list to be proccessed
            includeList.AddRange(newIncludeFile.include);

            //add parsed objects to allobjects
            if (newIncludeFile.objectDefinitions != null)
            {
                foreach ((string objName, ObjectClass obj) in newIncludeFile.objectDefinitions)
                {
                    newObjectsDefs.Add(objName, obj);
                }
            }

        }

        foreach ((string objName, ObjectClass obj) in newObjectsDefs) {
            globalResources.allObjects.Add(objName, obj);
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
