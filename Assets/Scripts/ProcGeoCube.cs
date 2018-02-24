using UnityEngine;
using System.Collections.Generic;

public class ProcGeoCube : MonoBehaviour {

	public MeshFilter meshFilter;

	void Start () {
		CreateBox();
	}

	void CreateBox()
	{
		// create a new mesh & assign it to our MeshFilter
		Mesh mesh = new Mesh();
		meshFilter.mesh = mesh;

        // create shape builder
        Shape shape = new Shape(32, 36);
	
		// quads
        // top
		shape.CreateQuad(new Vector3(-2, 0, 0), new Vector3(0, 0, 2), new Vector3(0, 0, 0));
        // bottom
        shape.CreateQuad(new Vector3(2, 0, 0), new Vector3(0, 0, 2), new Vector3(-2, -2, 0));
        // sides
        shape.CreateQuad(new Vector3(0, -2, 0), new Vector3(-2, 0, 0), new Vector3(0, 0, 0));
        shape.CreateQuad(new Vector3(0, -2, 0), new Vector3(0, 0, 2), new Vector3(-2, 0, 0));
        shape.CreateQuad(new Vector3(0, -2, 0), new Vector3(0, 0, -2), new Vector3(0, 0, 2));
        shape.CreateQuad(new Vector3(0, -2, 0), new Vector3(2, 0, 0), new Vector3(-2, 0, 2));

        mesh.vertices = shape.vertices;
        mesh.triangles = shape.triangles;
		mesh.uv = shape.uv;
		mesh.normals = shape.normals;
	}

	
}