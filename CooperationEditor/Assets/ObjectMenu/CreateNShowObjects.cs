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

        //remove all carsd in context 
        foreach (MeshRenderer m in contentObj.GetComponents<MeshRenderer>()) {
            GameObject.Destroy(m);
        }
        Texture2D[] objectsImages;
        Sprite[] objectsImageSprites;
        
        //setup render texture for camera to use
        if (globTexture == null) {
            globTexture = new RenderTexture((int)CardPrefab.GetComponent<RectTransform>().rect.width, (int)CardPrefab.GetComponent<RectTransform>().rect.height, 24);
        }
        globTexture.useMipMap = true;
        PhotoGetter.targetTexture = globTexture;

        //get global resources and check that there are object avaliable
        globalResources = _globalResources.GetComponent<GlobalResources>();
        if (globalResources.gameObjectList.Count <= 0) { inRoutine = false; yield break; }

        //create textures for each object
        objectsImages = new Texture2D[globalResources.gameObjectList.Count];
        objectsImageSprites = new Sprite[globalResources.gameObjectList.Count];

        int c = 0;
        foreach (string file in globalResources.gameObjectList) {
            if (CameraContent != null) { GameObject.Destroy(CameraContent); }
            CameraContent = globalResources.ImportGLTF(file);
            CameraContent.name = file;
            Debug.Log(file);
            CameraContent.transform.position = new Vector3(0, 10000, 0);
            CameraContent.transform.eulerAngles = new Vector3(0, -90f, 0);

            PhotoGetter.transform.position = new Vector3(0, 10005, -5);
            PhotoGetter.transform.LookAt(CameraContent.transform.position);

            PhotoGetter.Render();//render camera so redner texture updates
            yield return new WaitForEndOfFrame();

            objectsImages[c] = new Texture2D(globTexture.width, globTexture.height);
            Graphics.CopyTexture(globTexture, objectsImages[c]);
            objectsImageSprites[c] = Sprite.Create(objectsImages[c],new Rect(0, 0, objectsImages[c].width, objectsImages[c].height), Vector2.zero);


            c++;
        }
        globalResources.objectChange();



        //create cards in view
        c = 0;
        int numx = (int)(Camera.main.pixelWidth / ((CardPrefab.GetComponent<RectTransform>().rect.width * CardPrefab.transform.localScale.x) + 13))-1;
        for (int y = 0; y < objectsImages.Length / numx; y++)
        {
            for (int x = 0; x < numx; x++, c++)
            {
                //if (x == 0) { }
                GameObject temp = Instantiate(CardPrefab, contentObj.transform);
                RectTransform tempRect = GetComponent<RectTransform>();
                temp.transform.position = new Vector3(tPosx + (130 * x), -((163 * y))+ tPosy, 0);
                temp.GetComponent<Image>().sprite = objectsImageSprites[c];
                temp.GetComponent<CardClick>().ID = c;
                if (c == objectsImages.Length-1) { break; }
            }
        }
        float lastPos = tPosy + ((CardPrefab.GetComponent<RectTransform>().rect.height * CardPrefab.transform.localScale.y) * (objectsImages.Length / numx)) + padding;//height of the last card

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
