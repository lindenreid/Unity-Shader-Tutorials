using UnityEngine;

[ExecuteInEditMode]
public class DepthTexture : MonoBehaviour {

   private Camera cam;

   void Start () {
      cam = GetComponent<Camera>(); 
      cam.depthTextureMode = DepthTextureMode.Depth;
   }
}