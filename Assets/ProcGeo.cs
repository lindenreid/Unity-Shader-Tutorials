using UnityEngine;
using System.Collections.Generic;

public class ProcGeo : MonoBehaviour {

	public MeshFilter meshFilter;
	public float width = 1.0f;
	public float length = 1.0f;
	public float w = 1.0f;

	void Start () {

		// create a new mesh & assign it to our MeshFilter
		Mesh mesh = new Mesh();
		meshFilter.mesh = mesh;

		// create a new list of vertices
		Vector3[] vertices = new Vector3[4];
		
		vertices[0] = new Vector3(0,		0,	0);
		vertices[1] = new Vector3(width,	0,	0);
		vertices[2] = new Vector3(0,		0,	length);
		vertices[3] = new Vector3(width,	0,	length);
		
		mesh.vertices = vertices;

		// create a new list of triangles
		int[] tris = new int[6];
		
		tris[0] = 0;
		tris[1] = 2;
		tris[2] = 1;

		tris[3] = 2;
		tris[4] = 3;
		tris[5] = 1;

		mesh.triangles = tris;

		// let Unity do the work for normals for now- we'll recalculate later!
		mesh.RecalculateNormals();
	}
}
