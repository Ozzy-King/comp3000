using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;
using TMPro;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
using System.Text.RegularExpressions;

public class ItemPopulater : MonoBehaviour
{

    [SerializeField]
    GlobalResources globalResources;
    [SerializeField]
    GameObject scrollbarContent;

    [SerializeField]
    GameObject buttonTemplate;

    const int numberOfItems = 13;
    [SerializeField]
    GameObject[] ItemList = new GameObject[numberOfItems];
    [SerializeField]
    GameObject searchTextInput;
    [SerializeField]
    GameObject pageNumber;

    string searchString = "";
    int page = 0;
    string[] keyList = new string[0];


    

    public void pageForward() {
        if (page < keyList.Length/numberOfItems) {
            page += 1;
            StartCoroutine(populateScrollView());
        }
    }
    public void pageBackward()
    {
        if (page > 0) {
            page -= 1;
            StartCoroutine(populateScrollView());
        }
    }

    public void OnSearchChange() {
        page = 0;
        searchString = searchTextInput.GetComponent<TMP_InputField>().text;
        StartCoroutine(populateScrollView());
    }

    public void searchKeys() {
        keyList = globalResources.allObjects.Keys.ToArray();
        List<string> newKeyString = new List<string>();
        string pattern = @".*" + searchString+".*";

        MatchCollection matches;
        if (searchString != "") {
            foreach (string str in keyList) {
                matches = Regex.Matches(str, pattern, RegexOptions.IgnoreCase);
                if (matches.Count > 0) { newKeyString.Add(str); }
            }
            keyList = newKeyString.ToArray();
        }

    }

    public IEnumerator populateScrollView() {
        searchKeys();

        int keyListLen = keyList.Length;
        for (int i = page* numberOfItems, c = 0; c < numberOfItems; i++, c++) {
            GameObject currentButton = ItemList[c];
            if (i < keyListLen) {
                currentButton.SetActive(true);
                string key = keyList[i];
                currentButton.GetComponentInChildren<TextMeshProUGUI>().text = key;
                currentButton.GetComponent<Button>().onClick.RemoveAllListeners();
                currentButton.GetComponent<Button>().onClick.AddListener(() => {
                    globalResources.CurrentObjectSelectID = key;
                });
            }
            else {
                currentButton.SetActive(false);
            }
        }

        pageNumber.GetComponent<TMP_Text>().text = (page+1).ToString() + "/" + ((keyList.Length / numberOfItems)+1).ToString();
        yield return null;
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
