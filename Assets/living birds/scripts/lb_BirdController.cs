using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class lb_BirdController : MonoBehaviour {
	public int idealNumberOfBirds;
	public int maximumNumberOfBirds;
	public Camera currentCamera;
	public float unspawnDistance = 10.0f;
	public bool highQuality = true;
	public bool collideWithObjects = true;
	public LayerMask groundLayer;
	public float birdScale = 1.0f;

	public bool robin = true;
	public bool blueJay = true;
	public bool cardinal = true;
	public bool chickadee = true;
	public bool sparrow = true;
	public bool goldFinch = true;
	public bool crow = true;

	bool pause = false;
	GameObject[] myBirds;
	List<string> myBirdTypes = new List<string>();
	List<GameObject>  birdGroundTargets = new List<GameObject>();
	List<GameObject> birdPerchTargets = new List<GameObject>();
	int activeBirds = 0;
	int birdIndex = 0;
	GameObject[] featherEmitters = new GameObject[3];

	public void AllFlee(){
		if(!pause){
			for(int i=0;i<myBirds.Length;i++){
				if(myBirds[i].activeSelf){
					myBirds[i].SendMessage ("Flee");
				}
			}
		}
	}
	
	public void Pause(){
		if(pause){
			AllUnPause ();
		}else{
			AllPause ();
		}
	}
	
	public void AllPause(){
		pause = true;
		for(int i=0;i<myBirds.Length;i++){
			if(myBirds[i].activeSelf){
				myBirds[i].SendMessage ("PauseBird");
			}
		}
	}
	
	public void AllUnPause(){
		pause = false;
		for(int i=0;i<myBirds.Length;i++){
			if(myBirds[i].activeSelf){
				myBirds[i].SendMessage ("UnPauseBird");
			}
		}
	}

	public void SpawnAmount(int amt){
		for(int i=0;i<=amt;i++){
			SpawnBird ();
		}
	}

	public void ChangeCamera(Camera cam){
		currentCamera = cam;
	}

	void Start () {
		//find the camera
		if (currentCamera == null){
			currentCamera = GameObject.FindGameObjectWithTag("MainCamera").GetComponent<Camera>();
		}

		if(idealNumberOfBirds >= maximumNumberOfBirds){
			idealNumberOfBirds = maximumNumberOfBirds-1;
		}
		//set up the bird types to use
		if(robin){
			myBirdTypes.Add ("lb_robin");
		}
		if (blueJay){
			myBirdTypes.Add ("lb_blueJay");
		}
		if(cardinal){
			myBirdTypes.Add ("lb_cardinal");
		}
		if(chickadee){
			myBirdTypes.Add ("lb_chickadee");
		}
		if(sparrow){
			myBirdTypes.Add ("lb_sparrow");
		}
		if(goldFinch){
			myBirdTypes.Add ("lb_goldFinch");
		}
		if(crow){
			myBirdTypes.Add ("lb_crow");
		}
		//Instantiate birds based on amounts and bird types
		myBirds = new GameObject[maximumNumberOfBirds];
		GameObject bird;
		for(int i=0;i<myBirds.Length;i++){
			if(highQuality){
				bird = Resources.Load (myBirdTypes[Random.Range (0,myBirdTypes.Count)]+"HQ",typeof(GameObject)) as GameObject;
			}else{
				bird = Resources.Load (myBirdTypes[Random.Range (0,myBirdTypes.Count)],typeof(GameObject)) as GameObject;
			}
			myBirds[i] = Instantiate (bird,Vector3.zero,Quaternion.identity) as GameObject;
			myBirds[i].transform.localScale = myBirds[i].transform.localScale*birdScale;
			myBirds[i].transform.parent = transform;
			myBirds[i].SendMessage ("SetController",this);
			myBirds[i].SetActive (false);
		}

		//find all the targets
		GameObject[] groundTargets = GameObject.FindGameObjectsWithTag("lb_groundTarget");
		GameObject[] perchTargets = GameObject.FindGameObjectsWithTag("lb_perchTarget");

		for (int i=0;i<groundTargets.Length;i++){
			if(Vector3.Distance (groundTargets[i].transform.position,currentCamera.transform.position)<unspawnDistance){
				birdGroundTargets.Add(groundTargets[i]);
			}
		}
		for (int i=0;i<perchTargets.Length;i++){
			if(Vector3.Distance (perchTargets[i].transform.position,currentCamera.transform.position)<unspawnDistance){
				birdPerchTargets.Add(perchTargets[i]);
			}
		}

		//instantiate 3 feather emitters for killing the birds
		GameObject fEmitter = Resources.Load ("featherEmitter",typeof(GameObject)) as GameObject;
		for(int i=0;i<3;i++){
			featherEmitters[i] = Instantiate (fEmitter,Vector3.zero,Quaternion.identity) as GameObject;
			featherEmitters[i].transform.parent = transform;
			featherEmitters[i].SetActive (false);
		}
	}

	void OnEnable(){
		InvokeRepeating("UpdateBirds",1,1);
		StartCoroutine("UpdateTargets");
	}

	Vector3 FindPointInGroundTarget(GameObject target){
		//find a random point within the collider of a ground target that touches the ground
		Vector3 point;
		point.x = Random.Range (target.GetComponent<Collider>().bounds.max.x,target.GetComponent<Collider>().bounds.min.x);
		point.y = target.GetComponent<Collider>().bounds.max.y;
		point.z = Random.Range (target.GetComponent<Collider>().bounds.max.z,target.GetComponent<Collider>().bounds.min.z);
		//raycast down until it hits the ground
		RaycastHit hit;
		if (Physics.Raycast (point,-Vector3.up,out hit,target.GetComponent<Collider>().bounds.size.y,groundLayer)){
			return hit.point;
		}

		return point;
	}

	void UpdateBirds(){
		//this function is called once a second
		if(activeBirds < idealNumberOfBirds  && AreThereActiveTargets()){
			//if there are less than ideal birds active, spawn a bird
			SpawnBird();
		}else if(activeBirds < maximumNumberOfBirds && Random.value < .05 && AreThereActiveTargets()){
			//if there are less than maximum birds active spawn a bird every 20 seconds
			SpawnBird();
		}

		//check one bird every second to see if it should be unspawned
		if(myBirds[birdIndex].activeSelf && BirdOffCamera (myBirds[birdIndex].transform.position) && Vector3.Distance(myBirds[birdIndex].transform.position,currentCamera.transform.position) > unspawnDistance){
			//if the bird is off camera and at least unsapwnDistance units away lets unspawn
			Unspawn(myBirds[birdIndex]);
		}

		birdIndex = birdIndex == myBirds.Length-1 ? 0:birdIndex+1;
	}

	//this function will cycle through targets removing those outside of the unspawnDistance
	//it will also add any new targets that come into range
	IEnumerator UpdateTargets(){
		List<GameObject> gtRemove = new List<GameObject>();
		List<GameObject> ptRemove = new List<GameObject>();

		while(true){
			gtRemove.Clear();
			ptRemove.Clear();
			//check targets to see if they are out of range
			for(int i=0;i<birdGroundTargets.Count;i++){
				if (Vector3.Distance (birdGroundTargets[i].transform.position,currentCamera.transform.position)>unspawnDistance){
					gtRemove.Add (birdGroundTargets[i]);
				}
				yield return 0;
			}
			for (int i=0;i<birdPerchTargets.Count;i++){
				if (Vector3.Distance (birdPerchTargets[i].transform.position,currentCamera.transform.position)>unspawnDistance){
					ptRemove.Add (birdPerchTargets[i]);
				}
				yield return 0;
			}
			//remove any targets that have been found out of range
			foreach (GameObject entry in gtRemove){
				birdGroundTargets.Remove(entry);
			}
			foreach (GameObject entry in ptRemove){
				birdPerchTargets.Remove(entry);
			}
			yield return 0;
			//now check for any new Targets
			Collider[] hits = Physics.OverlapSphere(currentCamera.transform.position,unspawnDistance);
			foreach(Collider hit in hits){
				if (hit.tag == "lb_groundTarget" && !birdGroundTargets.Contains (hit.gameObject)){
					birdGroundTargets.Add (hit.gameObject);
				}
				if (hit.tag == "lb_perchTarget" && !birdPerchTargets.Contains (hit.gameObject)){
					birdPerchTargets.Add (hit.gameObject);
				}
			}
			yield return 0;
		}
	}

	bool BirdOffCamera(Vector3 birdPos){
		Vector3 screenPos = currentCamera.WorldToViewportPoint(birdPos);
		if (screenPos.x < 0 || screenPos.x > 1 || screenPos.y < 0 || screenPos.y > 1){
			return true;
		}else{
			return false;
		}
	}

	void Unspawn(GameObject bird){
		bird.transform.position = Vector3.zero;
		bird.SetActive (false);
		activeBirds --;
	}

	void SpawnBird(){
		if (!pause){
			GameObject bird = null;
			int randomBirdIndex = Mathf.FloorToInt (Random.Range (0,myBirds.Length));
			int loopCheck = 0;
			//find a random bird that is not active
			while(bird == null){
				if(myBirds[randomBirdIndex].activeSelf == false){
					bird = myBirds[randomBirdIndex];
				}
				randomBirdIndex = randomBirdIndex+1 >= myBirds.Length ? 0:randomBirdIndex+1;
				loopCheck ++;
				if (loopCheck >= myBirds.Length){
					//all birds are active
					return;
				}
			}
			//Find a point off camera to positon the bird and activate it
			bird.transform.position = FindPositionOffCamera();
			if(bird.transform.position == Vector3.zero){
				//couldnt find a suitable spawn point
				return;
			}else{
				bird.SetActive (true);
				activeBirds++;
				BirdFindTarget(bird);
			}
		}
	}

	bool AreThereActiveTargets(){
		if (birdGroundTargets.Count > 0 || birdPerchTargets.Count > 0){
			return true;
		}else{
			return false;
		}
	}

	Vector3 FindPositionOffCamera(){
		RaycastHit hit;
		float dist = Random.Range (2,10);
		Vector3 ray = -currentCamera.transform.forward;
		int loopCheck = 0;
		//find a random ray pointing away from the cameras field of view
		ray += new Vector3(Random.Range (-.5f,.5f),Random.Range (-.5f,.5f),Random.Range (-.5f,.5f));
		//cycle through random rays until we find one that doesnt hit anything
		while(Physics.Raycast(currentCamera.transform.position,ray,out hit,dist)){
			dist = Random.Range (2,10);
			loopCheck++;
			if (loopCheck > 35){
				//can't find any good spawn points so lets cancel
				return Vector3.zero;
			}
		}
		return currentCamera.transform.position+(ray*dist);
	}
	
	void BirdFindTarget(GameObject bird){
		//yield return new WaitForSeconds(1);
		GameObject target;
		if (birdGroundTargets.Count > 0 || birdPerchTargets.Count > 0){
			//pick a random target based on the number of available targets vs the area of ground targets
			//each perch target counts for .3 area, each ground target's area is calculated
			float gtArea=0.0f;
			float ptArea=birdPerchTargets.Count*0.3f;

			for (int i=0;i<birdGroundTargets.Count;i++){
				gtArea += birdGroundTargets[i].GetComponent<Collider>().bounds.size.x*birdGroundTargets[i].GetComponent<Collider>().bounds.size.z;
			}
			if (ptArea == 0.0f || Random.value < gtArea/(gtArea+ptArea)){
				target = birdGroundTargets[Mathf.FloorToInt (Random.Range (0,birdGroundTargets.Count))];
				bird.SendMessage ("FlyToTarget",FindPointInGroundTarget(target));
			}else{
				target = birdPerchTargets[Mathf.FloorToInt (Random.Range (0,birdPerchTargets.Count))];
				bird.SendMessage ("FlyToTarget",target.transform.position);
			}
		}else{
			bird.SendMessage ("FlyToTarget",currentCamera.transform.position+new Vector3(Random.Range (-100,100),Random.Range (5,10),Random.Range(-100,100)));
		}
	}

	void FeatherEmit(Vector3 pos){
		foreach (GameObject fEmit in featherEmitters){
			if(!fEmit.activeSelf){
				fEmit.transform.position = pos;
				fEmit.SetActive (true);
				StartCoroutine("DeactivateFeathers",fEmit);
				break;
			}
		}
	}

	IEnumerator DeactivateFeathers(GameObject featherEmit){
		yield return new WaitForSeconds(4.5f);
		featherEmit.SetActive (false);
	}
}
