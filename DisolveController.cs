using UnityEngine;
using System.Collections;

public class DisolveController : MonoBehaviour {

    public float disolveFreq = 1f; //The noise frequency
    public float disolveSpeed = 1f; //Disolve effect speed
    public Vector3 disolvePoint; //The point to disolve around
    float disolveAmount = 0;
    public bool disolved = false; //true = Materials in radius disolve; false = reverses the effect
    public float maxDist = 25f; //The maximum distance of the disolve effect;
    public float distLimitFac = 1f; //Also tweaks the maximum distance in a more flexible way

    public GameObject tracker; //Used as a test to set disolvePoint via mouse movement


	// Use this for initialization
	void Start () {
        //Applys values to shaders
        Shader.SetGlobalFloat("_DisolveFreq", disolveFreq);
        Shader.SetGlobalFloat("_IsoVal", disolveAmount);
        Shader.SetGlobalFloat("_MaxDist", maxDist);
        Shader.SetGlobalFloat("_DistanceLimitFac", distLimitFac);
    }
	
	// Update is called once per frame
	void Update () {
        //Toggles Disolve Effect
	    if(Input.GetKeyDown(KeyCode.Alpha1))
        {
            disolved = false;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            disolved = true;
        }

        //Lerps the disolveAmount and applys it as IsoValue to the Shader
        if(disolved == false)
        {
            if(disolveAmount > 0)
            {
                disolveAmount = Mathf.Lerp(disolveAmount, 0f, Time.fixedDeltaTime * disolveSpeed * 0.3f);
                Shader.SetGlobalFloat("_IsoVal", disolveAmount);
            }
        }
        else
        {
            if (disolveAmount < 2)
            {
                disolveAmount = Mathf.Lerp(disolveAmount, 2f, Time.fixedDeltaTime * disolveSpeed *0.3f);
                Shader.SetGlobalFloat("_IsoVal", disolveAmount);
            }
        }


        //Sends out a ray and returns the hit point as the DisolvePoint
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, 100))
        {
            tracker.transform.position = hit.point;
            disolvePoint = new Vector3(hit.point.x*0.2f, hit.point.y * 0.2f, hit.point.z * 0.2f);
            Shader.SetGlobalVector("_DisolvePoint", disolvePoint);
        }
    }


}
