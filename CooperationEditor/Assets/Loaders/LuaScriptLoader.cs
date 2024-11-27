using Siccity.GLTFUtility;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class LuaScriptLoader : MonoBehaviour
{
    [SerializeField]
    GlobalResources globalResources;


    // Start is called before the first frame update
    void Start()
    {
        //load global resouces to get working directory
        globalResources = gameObject.GetComponent<GlobalResources>();

        List<string> directories = new List<string>();
        directories.Add(globalResources.workingDirectory + "/code/");
        //load from workingDir/art/3d/... folder
        while (directories.Count != 0)
        {
            //gets directoey and removes from the direcotes list
            string currentDir = directories[0];
            directories.RemoveAt(0);

            //gets all sub direcoes and adds to directory list
            string[] subDirs = Directory.GetDirectories(currentDir);
            for (int i = 0; i < subDirs.Length; i++)
            {
                directories.Add(subDirs[i]);
            }

            //finally load in all gltf files found in folder
            string[] luaFiles = Directory.GetFiles(currentDir, "*.lua");
            for (int i = 0; i < luaFiles.Length; i++)
            {
                globalResources.luaScriptList.Add(luaFiles[i]);
                Debug.Log(luaFiles[i]);
            }
        }


    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
