using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class CardClick : MonoBehaviour
{
    public int ID;
    [SerializeField]
    GameObject globalresources;

    private void Start()
    {
        globalresources = GameObject.Find("ResourceManager");
    }

    public void selectClick()
    {
        globalresources.GetComponent<GlobalResources>().CurrentObjectSelectID = ID;
    }

}
