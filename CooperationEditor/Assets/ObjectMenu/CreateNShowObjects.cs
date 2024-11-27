using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CreateNShowObjects : MonoBehaviour
{
    [SerializeField]
    GameObject CardPrefab;
    [SerializeField]
    GameObject contentObj;


    [SerializeField]
    GameObject _globalResources;
    GlobalResources globalResources;

    [SerializeField]
    Camera PhotoGetter;
    GameObject CameraContent;
    [SerializeField]
    RenderTexture globTexture;//holds the rendered image to copy to new texture
    [SerializeField]


    static float tPosx = 70f;
    static float tPosy = 90f;
    static float padding = 13f; 
    
    public int numObj = 10;

    bool temp = false;
    bool inRoutine = false;

    Vector2 contentDelta;

    // Start is called before the first frame update
    IEnumerator StartFunc()
    {
        if (inRoutine) { yield break; }
        inRoutine = true;

        //contentObj.transform.position -= new Vector3(0,contentObj.transform.position.y,0); 
        //remove all cards in context 
        foreach (Image m in contentObj.GetComponents<Image>()) {
            GameObject.Destroy(m.gameObject);
        }
        
        //setup render texture for camera to use
        if (globTexture == null) {
            globTexture = new RenderTexture((int)CardPrefab.GetComponent<RectTransform>().rect.width, (int)CardPrefab.GetComponent<RectTransform>().rect.height, 24);
        }
        globTexture.useMipMap = true;
        PhotoGetter.targetTexture = globTexture;

        //get global resources and check that there are object avaliable
        globalResources = _globalResources.GetComponent<GlobalResources>();
        if (globalResources.gameObjectList.Count <= 0) { inRoutine = false; yield break; }
        globalResources.objectChange();


        List<string> fileNames = new List<string>();
        foreach (ObjectClass obj in globalResources.gameObjectList) { fileNames.Add(obj.art3d.model); }

        //create cards in view
        int c = 0;
        int numx = (int)(Camera.main.pixelWidth / ((CardPrefab.GetComponent<RectTransform>().rect.width * CardPrefab.transform.localScale.x) + 13));
        for (int y = 0; y < Mathf.CeilToInt((float)fileNames.Count / numx); y++)
        {
            for (int x = 0; x < numx; x++, c++)
            {
                if (CameraContent != null) { GameObject.Destroy(CameraContent); }
                CameraContent = globalResources.ImportGLTF(fileNames[c]);
                CameraContent.name = fileNames[c];
                Debug.Log(fileNames[c]);
                CameraContent.transform.position = new Vector3(0, 10000, 0);
                CameraContent.transform.eulerAngles = new Vector3(0, -90f, 0);

                PhotoGetter.transform.position = new Vector3(0, 10005, -5);
                PhotoGetter.transform.LookAt(CameraContent.transform.position);

                PhotoGetter.Render();//render camera so redner texture updates
                yield return new WaitForEndOfFrame();

                Texture2D objectImage = new Texture2D(globTexture.width, globTexture.height);
                Graphics.CopyTexture(globTexture, objectImage);
                Sprite objectImageSprite = Sprite.Create(objectImage,new Rect(0, 0, objectImage.width, objectImage.height), Vector2.zero);




                //if (x == 0) { }
                GameObject temp = Instantiate(CardPrefab, contentObj.transform);
                RectTransform tempRect = GetComponent<RectTransform>();
                temp.transform.position = new Vector3(tPosx + (130 * x), -((163 * y))+ tPosy, 0);
                temp.GetComponent<Image>().sprite = objectImageSprite;
                temp.GetComponent<CardClick>().ID = c;
                if (c == fileNames.Count - 1) { break; }
            }
        }
        float lastPos = tPosy + (CardPrefab.GetComponent<RectTransform>().rect.height * CardPrefab.transform.localScale.y * Mathf.CeilToInt((float)fileNames.Count / numx)) + padding;//height of the last card

        float contentRectheight = lastPos + ((CardPrefab.GetComponent<RectTransform>().rect.height * CardPrefab.transform.localScale.y)/2) + padding; //set to last pos and add half card increase with 13 padding
        Vector2 newContentDelta = contentObj.GetComponent<RectTransform>().sizeDelta;
        newContentDelta.y = contentRectheight - contentDelta.y;
        contentObj.GetComponent<RectTransform>().sizeDelta = newContentDelta;


        temp = true;
        inRoutine = false;
    }

    public void reLoadButtonClick() {
        StartCoroutine(StartFunc());
    }

    void Start()
    {
        contentDelta = contentObj.GetComponent<RectTransform>().sizeDelta;


    }

    // Update is called once per frame
    void Update()
    {
        if (!temp) {
            StartCoroutine(StartFunc());
        }
    }
}
