using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ItemPopulater : MonoBehaviour
{
    [SerializeField]
    GameObject cardPrefab;
    [SerializeField]
    GameObject camPrefab;


    [SerializeField]
    GlobalResources globalResources;
    [SerializeField]
    GameObject scrollbarContent;

    int max = 10;

    public IEnumerator populateScrollView() {
        GameObject temp = Instantiate(cardPrefab);
        Rect rect = new Rect(0, 0, temp.GetComponent<RectTransform>().rect.width, temp.GetComponent<RectTransform>().rect.height);
        RenderTexture renderTexture = new RenderTexture(Mathf.CeilToInt(rect.width), Mathf.CeilToInt(rect.height), 24);
        

        GameObject cam = Instantiate(camPrefab);
        cam.GetComponent<Camera>().targetTexture = renderTexture;


        Destroy(temp);
        int c = 0;
        foreach ((string name, ObjectClass obj) in globalResources.allObjects)
        {
            if (max >= 0) { max++; }
            else { yield break; }
            Bounds bounds = new Bounds();

            Texture2D screenShot = new Texture2D(Mathf.CeilToInt(rect.width), Mathf.CeilToInt(rect.height), TextureFormat.RGBA32, false);  
            //loop each object in each cell
            GameObject HolderObj = new GameObject();//holds al the models for object
            HolderObj.AddComponent<ObjectAttributes>().objectName = name;
            HolderObj.name = name;
            HolderObj.transform.position = new Vector3(0, 100, 0);

            //display obejcst and images, if nothing renders then palceholder(capsule) to show the object
            bool visible = false;

            //take account of base obejcts, id and mapObject wont work as both can get resolved to in game objects uavaliable for viewing
            if (obj._base.Count > 0)
            {
                foreach (string baseObj in obj._base)
                {
                    bounds.Encapsulate( globalResources.instintateObj(baseObj, globalResources.allObjects[baseObj], new Vector3(0, 0, 100), HolderObj));
                }
            }

            //import each object used
            if (obj.art3d == null)
            {
                foreach (Art3d objsArt in obj.art3d)
                {
                    visible = true;
                    GameObject Temp = globalResources.ImportGLTF(globalResources.workingDirectory + "/" + objsArt.model);
                    Temp.AddComponent<ObjectAttributes>().attributes3d = objsArt;
                    foreach (Renderer rend in Temp.GetComponentsInChildren<Renderer>())
                    {
                        MeshCollider col = rend.transform.gameObject.AddComponent<MeshCollider>();
                        col.convex = true;
                        col.isTrigger = true;

                        bounds.Encapsulate(col.bounds);
                    }

                    Temp.name = obj.dir;

                    //CenterPivotAtBottomMiddle(Temp);

                    Temp.transform.position = new Vector3(0, 100, 0);

                    Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                    Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                    Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                    Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                    Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                    Debug.Log(obj.dir);
                    Temp.transform.parent = HolderObj.transform;
                }
            }
            //create all 2d art assets for the obejct
            if (obj.art2d != null)
            {
                foreach (Art2d objsArt in obj.art2d)
                {
                    visible = true;
                    GameObject Temp = globalResources.ImportImage(globalResources.workingDirectory + GlobalResources.artDir + GlobalResources.art2dDir + "/" + objsArt.texture);
                    Temp.AddComponent<ObjectAttributes>().attributes2d = objsArt;
                    BoxCollider collider = Temp.AddComponent<BoxCollider>();
                    collider.isTrigger = true;

                    bounds.Encapsulate(collider.bounds);

                    Temp.name = obj.dir;

                    //CenterPivotAtBottomMiddle(Temp);

                    Temp.transform.position = new Vector3(0, 100, 0);

                    Temp.transform.position += new Vector3(-objsArt.pos.x, objsArt.pos.y, -objsArt.pos.z);//position offset
                    Temp.transform.rotation = Quaternion.Euler(0, 90, 0);//rotate around y to get it into north east south west
                    Temp.transform.Rotate(new Vector3(0, obj.DirToAngle(), 0));//rotate around y to get it into north east south west
                    Temp.transform.Rotate(new Vector3(objsArt.rot.x, objsArt.rot.y, objsArt.rot.z));//added roation for inital direction

                    Temp.transform.localScale = new Vector3(objsArt.scale.x, objsArt.scale.y, objsArt.scale.z);
                    Debug.Log(obj.dir);
                    Temp.transform.parent = HolderObj.transform;
                }
            }
            if (!visible)
            {
                GameObject Temp = Instantiate(globalResources.placeHolder);
                Temp.transform.position = new Vector3(0, 100, 0);
                Temp.transform.parent = HolderObj.transform;

                bounds.Encapsulate(Temp.GetComponent<Collider>().bounds);
            }

            cam.transform.position = bounds.center + HolderObj.transform.position + (bounds.size);
            cam.transform.LookAt(bounds.center + HolderObj.transform.position);

            var distance = bounds.size.y * 0.5f / Mathf.Tan(cam.GetComponent<Camera>().fieldOfView * 0.5f * Mathf.Deg2Rad);
            cam.transform.position -= cam.transform.forward * (distance+1);

            //get the correct distance from objects
            //Vector3 centerPoint = bounds.center;
            //float maxExtent = bounds.extents.magnitude;
            //float minDistance = maxExtent / Mathf.Tan(Camera.main.fieldOfView * Mathf.Deg2Rad / 2f);
            //cam.transform.position = (HolderObj.transform.position+ centerPoint) - Camera.main.transform.forward * (minDistance+2);

            Debug.Log(2.0f * Vector3.Distance(cam.transform.position, HolderObj.transform.position) * Mathf.Tan(cam.GetComponent<Camera>().fieldOfView * 0.5f * Mathf.Deg2Rad));

            //cam.transform.position += new Vector3(0, 100, 0);
            //cam.transform.LookAt(HolderObj.transform);

            cam.GetComponent<Camera>().Render();
            yield return new WaitForEndOfFrame();
            Graphics.CopyTexture(renderTexture, screenShot);
            Sprite newSprite = Sprite.Create(screenShot, rect, new Vector2(0,0));

            GameObject card = Instantiate(cardPrefab, scrollbarContent.transform);
            card.transform.position = new Vector3(Screen.width, Screen.height, 0);
            card.transform.position += new Vector3(-(scrollbarContent.GetComponent<RectTransform>().rect.width/2), -((rect.height/2)+((rect.height+10)*c)), 0);
            card.GetComponent<Image>().sprite = newSprite;
            //card.transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>().text = name;
            card.GetComponentInChildren<TextMeshProUGUI>().text = name;
            card.GetComponent<Button>().onClick.AddListener(() =>{
                globalResources.CurrentObjectSelectID = name;
            });
            c++;
            Destroy(HolderObj);
        }
        scrollbarContent.GetComponent<RectTransform>().sizeDelta = new Vector2(scrollbarContent.GetComponent<RectTransform>().sizeDelta.x, ((rect.height / 2) + ((rect.height + 10) * c)) );

        Destroy(renderTexture);
        Destroy(cam);

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
