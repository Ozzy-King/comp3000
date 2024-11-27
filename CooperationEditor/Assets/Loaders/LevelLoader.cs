using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;


public class LevelLoader : MonoBehaviour
{
    [SerializeField]
    GlobalResources globalResources;

    void loadLevel() {
        string yml = @"
include: [frankShare.yaml]
fileProperties:
  creatorName: osbourne
sceneName: EmptyWorld
postProcessing:
  depthOfField: { enabled: false, focusDistance: 58, focalLength: 0.0, aperture: 1.0 }
grid: |
  AA,BA,CA
  AB,BB,CB
  AC,BC,CC

gridObjects:

  AA: [ camera_focus ]
  AB: [  brick_wall_corner_se ]
  AC: [ brick_wall_s ]
  
  BA: [ camera_focus ]
  BB: [  brick_wall_corner_se ]
  BC: [ brick_wall_s ]
  
  CA: [ camera_focus ]
  CB: [  brick_wall_corner_se ]
  CC: [ brick_wall_s ]
  
objectDefinitions:
sounds:
globalData:
";

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
