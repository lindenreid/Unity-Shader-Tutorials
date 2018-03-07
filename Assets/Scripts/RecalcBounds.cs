using UnityEngine;

public class RecalcBounds : MonoBehaviour {
    
    void Start() {
        // boundsTarget is the center of the camera's frustum, in world coordinates:
        Camera cam = Camera.main;
        Vector3 camPosition = cam.transform.position;
        Vector3 normCamForward = Vector3.Normalize(cam.transform.forward);
        float boundsDistance = (cam.farClipPlane - cam.nearClipPlane) / 2 + cam.nearClipPlane;
        Vector3 boundsTarget = camPosition + (normCamForward * boundsDistance);
        
        // The game object's transform will be applied to the mesh's bounds for frustum culling checking.
        // We need to "undo" this transform by making the boundsTarget relative to the game object's transform:
        Vector3 realtiveBoundsTarget = this.transform.InverseTransformPoint(boundsTarget);
        
        // Set the bounds of the mesh to be a 1x1x1 cube (actually doesn't matter what the size is)
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        mesh.bounds = new Bounds(realtiveBoundsTarget, Vector3.one);
    }
}