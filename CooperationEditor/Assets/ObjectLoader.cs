using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Siccity.GLTFUtility;
using Unity.VisualScripting;
using System.IO;
using Unity.PlasticSCM.Editor.WebApi;

public class ObjectLoader : MonoBehaviour
{

    [SerializeField]
    GlobalResources globalResources;

    GameObject ImportGLTF(string filepath) {
        return Importer.LoadFromFile(filepath);
    }

    // Start is called before the first frame update
    void Start() {
        //load global resouces to get working directory
        globalResources = gameObject.GetComponent<GlobalResources>();

        List<string> directories = new List<string>();
        directories.Add(globalResources.workingDirectory + "\\art\\3d\\");
        //load from workingDir/art/3d/... folder
        while (directories.Count != 0) {
            //gets directoey and removes from the direcotes list
            string currentDir = directories[0];
            directories.RemoveAt(0);

            //gets all sub direcoes and adds to directory list
            string[] subDirs = Directory.GetDirectories(currentDir);
            for (int i = 0; i < subDirs.Length; i++) {
                directories.Add(subDirs[i]);
            }

            //finally load in all gltf files found in folder
            string[] gltfFiles = Directory.GetFiles(currentDir, "*.glb");
            for (int i = 0; i < gltfFiles.Length; i++) {
                globalResources.gameObjectList.Add(gltfFiles[i]);
                Debug.Log(gltfFiles[i]);
            }
        }

    
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
