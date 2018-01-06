using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour {

    public float rotation = 1.0f;

	void Update()
	{
		transform.Rotate(Vector3.up * Time.deltaTime * rotation);
	}
}
