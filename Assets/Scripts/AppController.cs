using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AppController : MonoBehaviour
{
    //public bool showInfoScreen = true;
    // Start is called before the first frame update
    void Start()
    {
        DontDestroyOnLoad(gameObject);

        if (FindObjectsOfType(GetType()).Length > 1)
        {
            Destroy(gameObject);
            return;
        }

        PlayerPrefs.SetInt("ShowInfoScreen", 1);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
