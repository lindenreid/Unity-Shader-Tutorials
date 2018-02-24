using UnityEngine;
using System.Collections.Generic;

public class Shape {

    public Vector3[] vertices;
    public int[] triangles;
    public Vector2[] uv;
    public Vector3[] normals;
    int triOffset = 0;
    int vertexOffset = 0;

    public Shape (int numVerts, int numTris)
    {
        vertices = new Vector3[numVerts];
        triangles = new int[numTris];
        uv = new Vector2[numVerts];
        normals = new Vector3[numVerts];
    }

    public void CreateQuad (Vector3 widthDir, Vector3 lengthDir, Vector3 pos)
    {
        // vertex indices
        int i1 = vertexOffset;
        int i2 = vertexOffset + 1;
        int i3 = vertexOffset + 2;
        int i4 = vertexOffset + 3;

        // vertices
        vertices[i1] = pos;
		vertices[i2] = pos + widthDir;
		vertices[i3] = pos + widthDir + lengthDir;
		vertices[i4] = pos + lengthDir;

        vertexOffset += 4;

        // triangles
        triangles[triOffset] = i1;
        triangles[triOffset + 1] = i2;
        triangles[triOffset + 2] = i3;

        triangles[triOffset + 3] = i1;
        triangles[triOffset + 4] = i3;
        triangles[triOffset + 5] = i4;

        triOffset += 6;

        // normals
		Vector3 normal = GetSurfaceNormal(vertices[i1], vertices[i2], vertices[i3]);
		normals[i1] = normal;
		normals[i2] = normal;
		normals[i3] = normal;
		normals[i4] = normal;

        // UVs
		uv[i1] = new Vector2(0, 1); // 0
		uv[i2] = new Vector2(1, 1); // 1
		uv[i3] = new Vector2(1, 0); // 2
		uv[i4] = new Vector2(0, 0); // 3 
    }

    Vector3 GetSurfaceNormal (Vector3 v1, Vector3 v2, Vector3 v3) {
		// get edge directions
	    Vector3 edge1 = v2 - v1;
	    Vector3 edge2 = v3 - v2;
		// get normalized cross product
		Vector3 normal = Vector3.Cross(edge1, edge2).normalized;
		return normal;
	}

}