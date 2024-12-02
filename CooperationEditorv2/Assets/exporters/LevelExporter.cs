using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using System.IO;

public class LevelExporter : MonoBehaviour
{
    public GlobalResources globres;
    LevelFile file;
    public List<GameObject>[,] CurrentLevelMapped;
    string grid = "";
    public void RecreateLevelLayout (){
        float levelSmallestX = 0;
        float levelSmallestY = 0;
        float levelLargestX = 0;
        float levelLargestY = 0;
        float levelWidth = 0;
        float levelHeight = 0;
        foreach (GameObject obj in globres.CurrentLevel) {
            if (obj.transform.position.z < levelSmallestX) { levelSmallestX = obj.transform.position.z; }
            if (obj.transform.position.x < levelSmallestY) { levelSmallestY = obj.transform.position.x; }

            if (obj.transform.position.z > levelLargestX) { levelLargestX = obj.transform.position.z; }
            if (obj.transform.position.x > levelLargestY) { levelLargestY = obj.transform.position.x; }
        }
        levelWidth = (levelLargestX - levelSmallestX)/2;
        levelHeight = (levelLargestY - levelSmallestY)/2;
        CurrentLevelMapped = new List<GameObject>[(int)(levelHeight)+1,(int)(levelWidth)+1];
        //sort out the gameobjects
        foreach (GameObject obj in globres.CurrentLevel)
        {
            //transforms positon to positive
            Vector2 tranposePos = new Vector2((obj.transform.position.z + -levelSmallestX)/2, (obj.transform.position.x + -levelSmallestY)/2 );
            if (CurrentLevelMapped[(int)tranposePos.y, (int)tranposePos.x] == null) { CurrentLevelMapped[(int)tranposePos.y, (int)tranposePos.x] = new List<GameObject>(); }
            CurrentLevelMapped[(int)tranposePos.y, (int)tranposePos.x].Add(obj);
        }
        grid = "";
        for (int y = 0; y < levelHeight+1; y++) {

            for (int x = 0; x < levelWidth+1; x++) {
                grid += ""+(char)(x + 65) + (char)(y + 65) + (x != levelWidth ? "," : "");
            }
            grid += "\n";
        }
    }
    public void createOutputYaml() {
        file = globres.levelFile;
        Dictionary<string, List<string>> gridObjects = new Dictionary<string, List<string>>();
        for (int y = 0; y < CurrentLevelMapped.GetLength(0); y++)
        {
            
            for (int x = 0; x < CurrentLevelMapped.GetLength(1); x++)
            {
                List<string> cell = new List<string>();
                string gridId = "" + (char)(x + 65) + (char)(y + 65);
                if (CurrentLevelMapped[y, x] != null)
                {
                    foreach (GameObject obj in CurrentLevelMapped[y, x])
                    {
                        cell.Add(obj.GetComponent<ObjectAttributes>().objectName);
                    }
                }
                gridObjects.Add(gridId, cell);
            }
        }
        file.grid = grid;
        file.gridObjects = gridObjects;
        var serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        var yaml = serializer.Serialize(file);
        File.WriteAllText(globres.workingDirectory + GlobalResources.levelDir + "/" + globres.LevelName, yaml);
        Debug.Log(yaml);
    }



    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.S)) {
            RecreateLevelLayout();
            createOutputYaml();
        }
    }
}
