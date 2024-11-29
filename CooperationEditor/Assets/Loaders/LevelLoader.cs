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

    void loadLevel() {
        //check file exits
        bool ex = File.Exists(globalResources.workingDirectory + "/levels/" + globalResources.LevelName);
        if (!ex) {
            return;
        }

        string yml = File.ReadAllText(globalResources.LevelName);

        var deserializer = new DeserializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();

        //yaml contains a string containing your YAML
        var p = deserializer.Deserialize<LevelFile>(yml);
        System.Console.WriteLine(p.grid);


        var serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        var yaml = serializer.Serialize(p);
        System.Console.WriteLine(yaml);
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
