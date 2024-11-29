using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using YamlDotNet.Serialization;


public class vec3
{
    public float x = 0, y = 0, z = 0;
}
public class vec3Scale
{
    public float x = 1f, y = 1f, z = 1f;
}
public class Art3d
{
    public vec3 pos = new vec3();
    public vec3 rot = new vec3();
    public vec3Scale scale = new vec3Scale();
    public string model = "";
}
public class ObjectClass
{
    enum _dir { 
        north, east, south, west
    }
    public List<string> tags = new List<string>();
    public List<string> mods = new List<string>();
    public string dir = "";
    public string mapObject = "";

    [YamlMember(Alias = "art3d")]
    public List<Art3d> art3d { get; set; } = new List<Art3d>();
}

public class FileProperties
{
    public string creatorName = "LevelEditor";
}

public class DepthOfField
{
    public bool enabled = false;
    public float focusDistance = 58;
    public float focalLength = 0.0f;
    public float aperture = 1.0f;
}
public class PostProcessing
{
    public DepthOfField depthOfField = new DepthOfField();
}

public class Music
{
    public bool usePresent = false;
}

public class Sounds
{
    public List<string> fileNames = new List<string>();
}

public class LevelFile
{
    [YamlMember(Alias = "include")]
    public List<string> include { get; set; } = new List<string>();

    [YamlMember(Alias = "file_properties")]
    public FileProperties fileProperties { get; set; } = new FileProperties();

    [YamlMember(Alias = "scene_name")]
    public string sceneName { get; set; } = "EmptyWorld";

    [YamlMember(Alias = "post_processing")]
    public PostProcessing postProcessing { get; set; } = new PostProcessing();

    [YamlMember(Alias = "grid")]
    public string grid { get; set; } = "  AA,BA,CA\n  AB,BB,CB\n  AC,BC,CC";

    [YamlMember(Alias = "grid_objects")]
    public Dictionary<string, List<string>> gridObjects { get; set; } = new Dictionary<string, List<string>>();

    [YamlMember(Alias = "object_definitions")]
    public Dictionary<string, ObjectClass> objectDefinitions { get; set; } = new Dictionary<string, ObjectClass>();

    [YamlMember(Alias = "sounds")]
    public Dictionary<string, Sounds> sounds { get; set; } = new Dictionary<string, Sounds>();

    //not sure on this feild so change when needed
    [YamlMember(Alias = "global_data")]
    public string globalData { get; set; } = "";
}
