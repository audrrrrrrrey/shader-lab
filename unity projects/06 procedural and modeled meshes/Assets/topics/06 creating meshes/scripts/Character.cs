using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]         //component in unity that contains the mesh
[RequireComponent(typeof (MeshRenderer))]       //component in unity that renders the mesh

public class Character : MonoBehaviour {
    Mesh mesh;
    void Start() {
        MakeCube();
    }

    //two essential parts of defining mesh is 1 vertices and 2 index buffer (1D array that defines triangles)
    void MakeCube() {
        
        //vertices, in order from 0 to 7
        Vector3[] vertices = {
            //vertices, in order from 0 to 7
            new Vector3(0, 0, 0),   
            new Vector3(1, 0, 0),
            new Vector3(1, 1, 0),
            new Vector3(0, 1, 0),
            new Vector3(0, 1, 1),
            new Vector3(1, 1, 1),
            new Vector3(1, 0, 1),
            new Vector3(0, 0, 1)
        };

        //triangles, in 1D array (formatted in groups of 3 for clarity)
            //if you wanted to make a room where you always see the inside of the room, 
            //you would flip the winding order for the entire cube because the inside of the faces are always rendered, the outside never
        int[] triangles = {
            0, 3, 2,        //front face (-Z)
            0, 2, 1,
            3, 4, 5,        //up face (+Y)
            3, 5, 2,
            2, 5, 6,        //right face (+X)
            2, 6, 1,
            7, 4, 3,        //left face (-X)
            7, 3, 0,
            6, 5, 4,          //back face (+Z)
            6, 4, 7,          
            7, 0, 1,          //down face (-Y)
            7, 1, 6
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    void OnDestroy() {
        Destroy(mesh);
    }

}