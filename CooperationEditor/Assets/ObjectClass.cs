using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using YamlDotNet.Serialization;


public class vec3
{
    public float x, y, z;
}
public class Art3d
{
    public vec3 pos;
    public vec3 rot;
    public vec3 scale;
    public string model;
}
public class ObjectClass
{
    public List<string> tags;
    public List<string> mods;
    public string dir;
    public string mapObject;
    public Art3d art3d;
}

public class FileProperties
{
    public string creatorName;
}

public class DepthOfField
{
    public bool enabled;
    public float focusDistance;
    public float focalLength;
    public float aperture;
}
public class PostProcessing
{
    public DepthOfField depthOfField;
}

public class Music
{
    public bool usePresent;
}

public class Sounds
{
    public List<string> fileNames;
}

public class LevelFile
{
    [YamlMember(Alias = "include")]
    public List<string> include { get; set; }

    [YamlMember(Alias = "file_properties")]
    public FileProperties fileProperties { get; set; }

    [YamlMember(Alias = "scene_name")]
    public string sceneName { get; set; }

    [YamlMember(Alias = "post_processing")]
    public PostProcessing postProcessing { get; set; }

    [YamlMember(Alias = "grid")]
    public string grid { get; set; }

    [YamlMember(Alias = "grid_objects")]
    public Dictionary<string, List<string>> gridObjects { get; set; }

    [YamlMember(Alias = "object_definitions")]
    public Dictionary<string, ObjectClass> objectDefinitions { get; set; }

    [YamlMember(Alias = "sounds")]
    public Dictionary<string, Sounds> sounds { get; set; }

    [YamlMember(Alias = "global_data")]
    public string globalData { get; set; }
}
