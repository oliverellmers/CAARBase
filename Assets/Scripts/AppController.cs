using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class AppController : MonoBehaviour
{
    //public bool showInfoScreen = true;
    // Start is called before the first frame update

    [SerializeField]
    private CanvasGroup LoadingFadeCanvas;


    void Start()
    {
        DontDestroyOnLoad(gameObject);

        if (FindObjectsOfType(GetType()).Length > 1)
        {
            Destroy(gameObject);
            return;
        }

        LoadingFadeCanvas.alpha = 1f;
        Fade();

        PlayerPrefs.SetInt("ShowInfoScreen", 1);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Fade() {
        StartCoroutine(DOFade());
    }

    IEnumerator DOFade() {
        LoadingFadeCanvas.DOFade(1f, 0.01f);
        LoadingFadeCanvas.interactable = true;
        LoadingFadeCanvas.blocksRaycasts = true;
        yield return new WaitForSeconds(0.125f);
        LoadingFadeCanvas.DOFade(0f, 1.5f);
        yield return new WaitForSeconds(1.5f);
        LoadingFadeCanvas.interactable = false;
        LoadingFadeCanvas.blocksRaycasts = false;
    }
}
