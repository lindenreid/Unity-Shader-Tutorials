using UnityEngine;
using System.Collections;

public class lb_Bird : MonoBehaviour {
	enum birdBehaviors{
		sing,
		preen,
		ruffle,
		peck,
		hopForward,
		hopBackward,
		hopLeft,
		hopRight,
	}

	public AudioClip song1;
	public AudioClip song2;
	public AudioClip flyAway1;
	public AudioClip flyAway2;

	public bool fleeCrows = true;

	Animator anim;
	lb_BirdController controller;

	bool paused = false;
	bool idle = true;
	bool flying = false;
	bool landing = false;
	bool perched = false;
	bool onGround = true;
	bool dead = false;
	BoxCollider birdCollider;
	Vector3 bColCenter;
	Vector3 bColSize;
	SphereCollider solidCollider;
	float distanceToTarget = 0.0f;
	float agitationLevel = .5f;
	float originalAnimSpeed = 1.0f;
	Vector3 originalVelocity = Vector3.zero;

	//hash variables for the animation states and animation properties
	int idleAnimationHash;
	int singAnimationHash;
	int ruffleAnimationHash;
	int preenAnimationHash;
	int peckAnimationHash;
	int hopForwardAnimationHash;
	int hopBackwardAnimationHash;
	int hopLeftAnimationHash;
	int hopRightAnimationHash;
	int worriedAnimationHash;
	int landingAnimationHash;
	int flyAnimationHash;
	int hopIntHash;
	int flyingBoolHash;
	//int perchedBoolHash;
	int peckBoolHash;
	int ruffleBoolHash;
	int preenBoolHash;
	//int worriedBoolHash;
	int landingBoolHash;
	int singTriggerHash;
	int flyingDirectionHash;
	int dieTriggerHash;

	void OnEnable () {
		birdCollider = gameObject.GetComponent<BoxCollider>();
		bColCenter = birdCollider.center;
		bColSize = birdCollider.size;
		solidCollider = gameObject.GetComponent<SphereCollider>();
		anim = gameObject.GetComponent<Animator>();

		idleAnimationHash = Animator.StringToHash("Base Layer.Idle");
		//singAnimationHash = Animator.StringToHash ("Base Layer.sing");
		//ruffleAnimationHash = Animator.StringToHash ("Base Layer.ruffle");
		//preenAnimationHash = Animator.StringToHash ("Base Layer.preen");
		//peckAnimationHash = Animator.StringToHash ("Base Layer.peck");
		//hopForwardAnimationHash = Animator.StringToHash ("Base Layer.hopForward");
		//hopBackwardAnimationHash = Animator.StringToHash ("Base Layer.hopBack");
		//hopLeftAnimationHash = Animator.StringToHash ("Base Layer.hopLeft");
		//hopRightAnimationHash = Animator.StringToHash ("Base Layer.hopRight");
		//worriedAnimationHash = Animator.StringToHash ("Base Layer.worried");
		//landingAnimationHash = Animator.StringToHash ("Base Layer.landing");
		flyAnimationHash = Animator.StringToHash ("Base Layer.fly");
		hopIntHash = Animator.StringToHash ("hop");
		flyingBoolHash = Animator.StringToHash("flying");
		//perchedBoolHash = Animator.StringToHash("perched");
		peckBoolHash = Animator.StringToHash("peck");
		ruffleBoolHash = Animator.StringToHash("ruffle");
		preenBoolHash = Animator.StringToHash("preen");
		//worriedBoolHash = Animator.StringToHash("worried");
		landingBoolHash = Animator.StringToHash("landing");
		singTriggerHash = Animator.StringToHash ("sing");
		flyingDirectionHash = Animator.StringToHash("flyingDirectionX");
		dieTriggerHash = Animator.StringToHash ("die");
		anim.SetFloat ("IdleAgitated",agitationLevel);
		if (dead){
			Revive();
		}
	}

	void PauseBird(){
		if(!dead){
			originalAnimSpeed = anim.speed;
			anim.speed = 0;
			if(!GetComponent<Rigidbody>().isKinematic){originalVelocity = GetComponent<Rigidbody>().velocity;}
			GetComponent<Rigidbody>().isKinematic = true;
			GetComponent<AudioSource>().Stop ();
			paused = true;
		}
	}

	void UnPauseBird(){
		if(!dead){
			anim.speed = originalAnimSpeed;
			GetComponent<Rigidbody>().isKinematic = false;
			GetComponent<Rigidbody>().velocity = originalVelocity;
			paused = false;
		}
	}
	
	IEnumerator FlyToTarget(Vector3 target){
		if(Random.value < .5){
			GetComponent<AudioSource>().PlayOneShot (flyAway1,.1f);
		}else{
			GetComponent<AudioSource>().PlayOneShot (flyAway2,.1f);
		}
		flying = true;
		landing = false;
		onGround = false;
		GetComponent<Rigidbody>().isKinematic = false;
		GetComponent<Rigidbody>().velocity = Vector3.zero;
		GetComponent<Rigidbody>().drag = 0.5f;
		anim.applyRootMotion = false;
		anim.SetBool (flyingBoolHash,true);
		anim.SetBool(landingBoolHash, false);

		//Wait to apply velocity until the bird is entering the flying animation
		while(anim.GetCurrentAnimatorStateInfo(0).nameHash != flyAnimationHash){
			yield return 0;
		}

		//birds fly up and away from their perch for 1 second before orienting to the next target
		GetComponent<Rigidbody>().AddForce((transform.forward * 50.0f*controller.birdScale)+(transform.up * 100.0f*controller.birdScale));
		float t = 0.0f;
		while (t<1.0f){
			if(!paused){
				t+= Time.deltaTime;
				if(t>.2f && !solidCollider.enabled && controller.collideWithObjects){
					solidCollider.enabled = true;
				}
			}
			yield return 0;
		}
		//start to rotate toward target
		Vector3 vectorDirectionToTarget = (target-transform.position).normalized;
		Quaternion finalRotation = Quaternion.identity;
		Quaternion startingRotation = transform.rotation;
		distanceToTarget = Vector3.Distance (transform.position,target);
		Vector3 forwardStraight;//the forward vector on the xz plane
		RaycastHit hit;
		Vector3 tempTarget = target;
		t = 0.0f;

		//if the target is directly above the bird the bird needs to fly out before going up
		//this should stop them from taking off like a rocket upwards
		if(vectorDirectionToTarget.y>.5f){
			tempTarget = transform.position + (new Vector3(transform.forward.x,.5f,transform.forward.z)*distanceToTarget);

			while(vectorDirectionToTarget.y>.5f){
				//Debug.DrawLine (tempTarget,tempTarget+Vector3.up,Color.red);
				vectorDirectionToTarget = (tempTarget-transform.position).normalized;
				finalRotation = Quaternion.LookRotation(vectorDirectionToTarget);
				transform.rotation = Quaternion.Slerp (startingRotation,finalRotation,t);
				anim.SetFloat (flyingDirectionHash,FindBankingAngle(transform.forward,vectorDirectionToTarget));
				t += Time.deltaTime*0.5f;
				GetComponent<Rigidbody>().AddForce(transform.forward * 70.0f*controller.birdScale * Time.deltaTime);

				//Debug.DrawRay (transform.position,transform.forward,Color.green);

				vectorDirectionToTarget = (target-transform.position).normalized;//reset the variable to reflect the actual target and not the temptarget

				if (Physics.Raycast(transform.position,-Vector3.up,out hit,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y < 0){
					//if the bird is going to collide with the ground zero out vertical velocity
					if(!hit.collider.isTrigger){
						GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
					}
				}
				if (Physics.Raycast(transform.position,Vector3.up,out hit,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y > 0){
					//if the bird is going to collide with something overhead zero out vertical velocity
					if(!hit.collider.isTrigger){
						GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
					}
				}
				//check for collisions with non trigger colliders and abort flight if necessary
				if(controller.collideWithObjects){
					forwardStraight = transform.forward;
					forwardStraight.y = 0.0f;
					//Debug.DrawRay (transform.position+(transform.forward*.1f),forwardStraight*.75f,Color.green);
					if (Physics.Raycast (transform.position+(transform.forward*.15f*controller.birdScale),forwardStraight,out hit,.75f*controller.birdScale)){
						if(!hit.collider.isTrigger){
							AbortFlyToTarget();
						}
					}
				}
				yield return null;
			}
		}

		finalRotation = Quaternion.identity;
		startingRotation = transform.rotation;
		distanceToTarget = Vector3.Distance (transform.position,target);

		//rotate the bird toward the target over time
		while(transform.rotation != finalRotation || distanceToTarget >= 1.5f){
			if(!paused){
				distanceToTarget = Vector3.Distance (transform.position,target);
				vectorDirectionToTarget = (target-transform.position).normalized;
				if(vectorDirectionToTarget==Vector3.zero){
					vectorDirectionToTarget = new Vector3(0.0001f,0.00001f,0.00001f);
				}
				finalRotation = Quaternion.LookRotation(vectorDirectionToTarget);
				transform.rotation = Quaternion.Slerp (startingRotation,finalRotation,t);
				anim.SetFloat (flyingDirectionHash,FindBankingAngle(transform.forward,vectorDirectionToTarget));
				t += Time.deltaTime*0.5f;
				GetComponent<Rigidbody>().AddForce(transform.forward * 70.0f*controller.birdScale * Time.deltaTime);
				if (Physics.Raycast(transform.position,-Vector3.up,out hit,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y < 0){
					//if the bird is going to collide with the ground zero out vertical velocity
					if(!hit.collider.isTrigger){
						GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
					}
				}
				if (Physics.Raycast(transform.position,Vector3.up,out hit,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y > 0){
					//if the bird is going to collide with something overhead zero out vertical velocity
					if(!hit.collider.isTrigger){
						GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
					}
				}

				//check for collisions with non trigger colliders and abort flight if necessary
				if(controller.collideWithObjects){
					forwardStraight = transform.forward;
					forwardStraight.y = 0.0f;
					//Debug.DrawRay (transform.position+(transform.forward*.1f),forwardStraight*.75f,Color.green);
					if (Physics.Raycast (transform.position+(transform.forward*.15f*controller.birdScale),forwardStraight,out hit,.75f*controller.birdScale)){
						if(!hit.collider.isTrigger){
							AbortFlyToTarget();
						}
					}
				}
			}
			yield return 0;
		}

		//keep the bird pointing at the target and move toward it
		float flyingForce = 50.0f*controller.birdScale;
		while(true){
			if(!paused){
				//do a raycast to see if the bird is going to hit the ground
				if (Physics.Raycast(transform.position,-Vector3.up,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y < 0){
					GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
				}
				if (Physics.Raycast(transform.position,Vector3.up,out hit,0.15f*controller.birdScale) && GetComponent<Rigidbody>().velocity.y > 0){
					//if the bird is going to collide with something overhead zero out vertical velocity
					if(!hit.collider.isTrigger){
						GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.x, 0.0f,GetComponent<Rigidbody>().velocity.z);
					}
				}

				//check for collisions with non trigger colliders and abort flight if necessary
				if(controller.collideWithObjects){
					forwardStraight = transform.forward;
					forwardStraight.y = 0.0f;
					//Debug.DrawRay (transform.position+(transform.forward*.1f),forwardStraight*.75f,Color.green);
					if (Physics.Raycast (transform.position+(transform.forward*.15f*controller.birdScale),forwardStraight,out hit,.75f*controller.birdScale)){
						if(!hit.collider.isTrigger){
							AbortFlyToTarget();
						}
					}
				}

				vectorDirectionToTarget = (target-transform.position).normalized;
				finalRotation = Quaternion.LookRotation(vectorDirectionToTarget);
				anim.SetFloat (flyingDirectionHash,FindBankingAngle(transform.forward,vectorDirectionToTarget));
				transform.rotation = finalRotation;
				GetComponent<Rigidbody>().AddForce(transform.forward * flyingForce * Time.deltaTime);
				distanceToTarget = Vector3.Distance (transform.position,target);
				if(distanceToTarget <= 1.5f*controller.birdScale){
					solidCollider.enabled = false;
					if(distanceToTarget < 0.5f*controller.birdScale){
						break;	
					}else{
						GetComponent<Rigidbody>().drag = 2.0f;
						flyingForce = 50.0f*controller.birdScale;
					}
				}else if (distanceToTarget <= 5.0f*controller.birdScale){
					GetComponent<Rigidbody>().drag = 1.0f;
					flyingForce = 50.0f*controller.birdScale;
				}
			}
			yield return 0;
		}

		anim.SetFloat (flyingDirectionHash,0);
		//initiate the landing for the bird to finally reach the target
		Vector3 vel = Vector3.zero;
		flying = false;
		landing = true;
		solidCollider.enabled = false;
		anim.SetBool(landingBoolHash, true);
		anim.SetBool (flyingBoolHash,false);
		t = 0.0f;
		GetComponent<Rigidbody>().velocity = Vector3.zero;

		//tell any birds that are in the way to move their butts
		Collider[] hitColliders = Physics.OverlapSphere(target,0.05f*controller.birdScale);
		for(int i=0;i<hitColliders.Length;i++){
			if (hitColliders[i].tag == "lb_bird" && hitColliders[i].transform != transform){
				hitColliders[i].SendMessage ("FlyAway");
			}
		}

		//this while loop will reorient the rotation to vertical and translate the bird exactly to the target
		startingRotation = transform.rotation;
		transform.localEulerAngles = new Vector3(0.0f,transform.localEulerAngles.y,0.0f);
		finalRotation = transform.rotation;
		transform.rotation = startingRotation;
		while (distanceToTarget>0.05f*controller.birdScale){
			if(!paused){
				transform.rotation = Quaternion.Slerp (startingRotation,finalRotation,t*4.0f);
				transform.position = Vector3.SmoothDamp(transform.position,target,ref vel,0.5f);
				t += Time.deltaTime;
				distanceToTarget = Vector3.Distance (transform.position,target);
				if(t>2.0f){
					break;//failsafe to stop birds from getting stuck
				}
			}
			yield return 0;
		}
		GetComponent<Rigidbody>().drag = .5f;
		GetComponent<Rigidbody>().velocity = Vector3.zero;
		anim.SetBool(landingBoolHash, false);
		landing = false;
		transform.localEulerAngles = new Vector3(0.0f,transform.localEulerAngles.y,0.0f);
		transform.position = target;
		anim.applyRootMotion = true;
		onGround = true;
	}

	//Sets a variable between -1 and 1 to control the left and right banking animation
	float FindBankingAngle(Vector3 birdForward, Vector3 dirToTarget){
		Vector3 cr = Vector3.Cross (birdForward,dirToTarget);
		float ang = Vector3.Dot (cr,Vector3.up);
		return ang;
	}
	
	void OnGroundBehaviors(){
		idle = anim.GetCurrentAnimatorStateInfo(0).nameHash == idleAnimationHash;
		if(!GetComponent<Rigidbody>().isKinematic){
			GetComponent<Rigidbody>().isKinematic = true;
		}
		if(idle){
			//the bird is in the idle animation, lets randomly choose a behavior every 3 seconds
			if (Random.value < Time.deltaTime*.33){
				//bird will display a behavior
				//in the perched state the bird can only sing, preen, or ruffle
				float rand = Random.value;
				if (rand < .3){
					DisplayBehavior(birdBehaviors.sing);
				}else if (rand < .5){
					DisplayBehavior(birdBehaviors.peck);
				}else if (rand < .6){
					DisplayBehavior(birdBehaviors.preen);	
				}else if (!perched && rand<.7){
					DisplayBehavior(birdBehaviors.ruffle);	
				}else if (!perched && rand <.85){
					DisplayBehavior(birdBehaviors.hopForward);	
				}else if (!perched && rand < .9){
					DisplayBehavior(birdBehaviors.hopLeft);	
				}else if (!perched && rand <.95){
					DisplayBehavior(birdBehaviors.hopRight);
				}else if (!perched && rand <= 1){
					DisplayBehavior(birdBehaviors.hopBackward);	
				}else{
					DisplayBehavior(birdBehaviors.sing);	
				}
				//lets alter the agitation level of the brid so it uses a different mix of idle animation next time
				anim.SetFloat ("IdleAgitated",Random.value);
			}
			//birds should fly to a new target about every 10 seconds
			if (Random.value < Time.deltaTime*.1){
				FlyAway ();
			}
		}
	}
	
	void DisplayBehavior(birdBehaviors behavior){
		idle = false;
		switch (behavior){
		case birdBehaviors.sing:
			anim.SetTrigger(singTriggerHash);			
			break;
		case birdBehaviors.ruffle:
			anim.SetTrigger(ruffleBoolHash);
			break;
		case birdBehaviors.preen:
			anim.SetTrigger(preenBoolHash);			
			break;
		case birdBehaviors.peck:
			anim.SetTrigger(peckBoolHash);			
			break;
		case birdBehaviors.hopForward:
			anim.SetInteger (hopIntHash, 1);			
			break;
		case birdBehaviors.hopLeft:
			anim.SetInteger (hopIntHash, -2);			
			break;
		case birdBehaviors.hopRight:
			anim.SetInteger (hopIntHash, 2);
			break;
		case birdBehaviors.hopBackward:
			anim.SetInteger (hopIntHash, -1);			
			break;
		}
	}

	void OnTriggerEnter(Collider col){
		if (col.tag == "lb_bird"){
			FlyAway ();
		}
	}

	void OnTriggerExit(Collider col){
		//if bird has hopped out of the target area lets fly
		if (onGround && (col.tag == "lb_groundTarget" || col.tag == "lb_perchTarget")){
			FlyAway ();
		}
	}

	void AbortFlyToTarget(){
		StopCoroutine("FlyToTarget");
		solidCollider.enabled = false;
		anim.SetBool(landingBoolHash, false);
		anim.SetFloat (flyingDirectionHash,0);
		transform.localEulerAngles = new Vector3(
			0.0f,
			transform.localEulerAngles.y,
			0.0f);
		FlyAway ();
	}
	
	void FlyAway(){
		if(!dead){
			StopCoroutine("FlyToTarget");
			anim.SetBool(landingBoolHash, false);
			controller.SendMessage ("BirdFindTarget",gameObject);
		}
	}

	void Flee(){
		if(!dead){
			StopCoroutine("FlyToTarget");
			GetComponent<AudioSource>().Stop();
			anim.Play(flyAnimationHash);
			Vector3 farAwayTarget = transform.position;
			farAwayTarget += new Vector3(Random.Range (-100,100)*controller.birdScale,10*controller.birdScale,Random.Range (-100,100)*controller.birdScale);
			StartCoroutine("FlyToTarget",farAwayTarget);
		}
	}

	void CrowIsClose(){
		if (fleeCrows && !dead){
			Flee ();
		}
	}

	public void KillBird(){
		if(!dead){
			controller.SendMessage ("FeatherEmit",transform.position);
			anim.SetTrigger(dieTriggerHash);
			anim.applyRootMotion = false;
			dead = true;
			onGround = false;
			flying = false;
			landing = false;
			idle = false;
			perched = false;
			AbortFlyToTarget();
			StopAllCoroutines();
			GetComponent<Collider>().isTrigger = false;
			birdCollider.center = new Vector3(0.0f,0.0f,0.0f);
			birdCollider.size = new Vector3(0.1f,0.01f,0.1f)*controller.birdScale;
			GetComponent<Rigidbody>().isKinematic = false;
			GetComponent<Rigidbody>().useGravity = true;
		}
	}

	public void KillBirdWithForce(Vector3 force){
		if(!dead){
			controller.SendMessage ("FeatherEmit",transform.position);
			anim.SetTrigger(dieTriggerHash);
			anim.applyRootMotion = false;
			dead = true;
			onGround = false;
			flying = false;
			landing = false;
			idle = false;
			perched = false;
			AbortFlyToTarget();
			StopAllCoroutines();
			GetComponent<Collider>().isTrigger = false;
			birdCollider.center = new Vector3(0.0f,0.0f,0.0f);
			birdCollider.size = new Vector3(0.1f,0.01f,0.1f)*controller.birdScale;
			GetComponent<Rigidbody>().isKinematic = false;
			GetComponent<Rigidbody>().useGravity = true;
			GetComponent<Rigidbody>().AddForce (force);
		}
	}

	void Revive(){
		if(dead){
			birdCollider.center = bColCenter;
			birdCollider.size = bColSize;
			GetComponent<Collider>().isTrigger = true;
			dead = false;
			onGround = false;
			flying = false;
			landing = false;
			idle = true;
			perched = false;
			GetComponent<Rigidbody>().isKinematic = false;
			GetComponent<Rigidbody>().useGravity = false;
			anim.Play (idleAnimationHash);
			controller.SendMessage ("BirdFindTarget",gameObject);
		}
	}

	void SetController(lb_BirdController cont){
		controller = cont;
	}

	void ResetHopInt(){
		anim.SetInteger (hopIntHash, 0);
	}

	void ResetFlyingLandingVariables(){
		if (flying || landing){
			flying = false;
			landing = false;
		}
	}

	void PlaySong(){
		if (!dead){
			if(Random.value < .5){
				GetComponent<AudioSource>().PlayOneShot (song1,1);
			}else{
				GetComponent<AudioSource>().PlayOneShot (song2,1);
			}
		}
	}

	void Update () {
		if(onGround && !paused && !dead){
			OnGroundBehaviors();	
		}
	}
}
