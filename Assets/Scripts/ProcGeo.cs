using UnityEngine;

public class ProcGeo : MonoBehaviour {

	public MeshFilter meshFilter;
	public float width = 1.0f;
	public float length = 1.0f;
	public float w = 1.0f;

	void Start () {
		CreateBox();
	}

	void CreatePlane ()
	{
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

	void CreateBox ()
	{
		// create a new mesh & assign it to our MeshFilter
		Mesh mesh = new Mesh();
		meshFilter.mesh = mesh;

		// create a new list of vertices
		Vector3[] vertices = new Vector3[8];
		
		// top
		vertices[0] = new Vector3(-1,  1,  1); // 0
		vertices[1] = new Vector3( 1,  1,  1); // 1
		vertices[2] = new Vector3( 1,  1, -1); // 2
		vertices[3] = new Vector3(-1,  1, -1); // 3
		// bottom
		vertices[4] = new Vector3(-1, -1,  1); // 4
		vertices[5] = new Vector3( 1, -1,  1); // 5
		vertices[6] = new Vector3( 1, -1, -1); // 6
		vertices[7] = new Vector3(-1, -1, -1); // 7
		
		mesh.vertices = vertices;

		// create a new list of triangles
		int[] tris = new int[36];
		
		// top
		tris[0] = 0;
		tris[1] = 1;
		tris[2] = 2;

		tris[3] = 0;
		tris[4] = 2;
		tris[5] = 3;

		//bottom
		tris[6] = 4;
		tris[7] = 7;
		tris[8] = 6;

		tris[9] = 4;
		tris[10] = 6;
		tris[11] = 5;

		// sides
		tris[12] = 3;
		tris[13] = 2;
		tris[14] = 6;

		tris[15] = 3;
		tris[16] = 6;
		tris[17] = 7;

		tris[18] = 2;
		tris[19] = 1;
		tris[20] = 5;

		tris[21] = 2;
		tris[22] = 5;
		tris[23] = 6;

		tris[24] = 1;
		tris[25] = 0;
		tris[26] = 4;

		tris[27] = 1;
		tris[28] = 4;
		tris[29] = 5;

		tris[30] = 0;
		tris[31] = 3;
		tris[32] = 7;

		tris[33] = 0;
		tris[34] = 7;
		tris[35] = 4;

		mesh.triangles = tris;

		// let Unity do the work for normals for now- we'll recalculate later!
		mesh.RecalculateNormals();
	}
}
