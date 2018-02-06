using UnityEngine;
using System.Collections;

public class lb_CrowProximity : MonoBehaviour {
	
	void OnTriggerEnter (Collider col) {
		if(col.tag == "lb_bird"){
			col.SendMessage("CrowIsClose");
		}
	}

}
