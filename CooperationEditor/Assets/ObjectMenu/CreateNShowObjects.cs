using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateNShowObjects : MonoBehaviour
{
    [SerializeField]
    GameObject CardPrefab;
    [SerializeField]
    GameObject contentObj;

    static float tPosx = 70f;
    static float tPosy = 90f;

    
    public int numObj = 10;

    // Start is called before the first frame update
    void Start()
    {
        int numx = (int)(Camera.main.pixelWidth / ((CardPrefab.GetComponent<RectTransform>().rect.width / CardPrefab.transform.localScale.x) + 13))-1;
        for (int y = 0; y < 7; y++)
        {

            for (int x = 0; numx < 7; x++)
            {
                GameObject temp = Instantiate(CardPrefab, contentObj.transform);
                RectTransform tempRect = GetComponent<RectTransform>();
                temp.transform.position = new Vector3(tPosx + (130 * x), -(tPosy + (163 * y)), 0);
            }
        }
    }

        // Update is called once per frame
        void Update()
    {
        Debug.Log(Camera.main.pixelWidth);
    }
}
