using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour {

    Mesh mesh;
    List<Vector3> vertices;
    List<Vector3> normals;
    List<Vector2> uvs;
    List<int> triangles;        //lists are useful for being able to add to the number of quads as we go
    
    void Start() {
        //getting components
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        MeshRenderer MeshRenderer = GetComponent<MeshRenderer>();

        //setting up lists
        vertices = new List<Vector3>();
        normals = new List<Vector3>();
        uvs = new List<Vector2>();
        triangles = new List<int>();

        meshFilter.mesh = CreateCube();
    }

    Mesh CreateCube() {
        mesh = new Mesh();

        float hs = 0.5f;    //half size, useful when creating cube from middle

        //front face +z, so all Z values are positive
        CreateQuad(
            new Vector3( hs, -hs,  hs),       //bl
            new Vector3( hs,  hs,  hs),       //tl
            new Vector3(-hs,  hs,  hs),       //tr
            new Vector3(-hs, -hs,  hs),       //br
            new Vector3(0, 0, 1),             //normal, +z
            new Vector2Int(0, 0)              //back face is side of grass block, so use bottom left texture
        );
        
        // back face -z
        CreateQuad(
            new Vector3(-hs, -hs, -hs),
            new Vector3(-hs,  hs, -hs),
            new Vector3( hs,  hs, -hs),
            new Vector3( hs, -hs, -hs),
            new Vector3(0, 0, -1),
            new Vector2Int(0, 0)
        );
        
        // left face -x
        CreateQuad(
            new Vector3(-hs, -hs,  hs),
            new Vector3(-hs,  hs,  hs),
            new Vector3(-hs,  hs, -hs),
            new Vector3(-hs, -hs, -hs),
            new Vector3(-1, 0, 0),
            new Vector2Int(0, 0)
        );
        
        // right face +x
        CreateQuad(
            new Vector3( hs, -hs, -hs),
            new Vector3( hs,  hs, -hs),
            new Vector3( hs,  hs,  hs),
            new Vector3( hs, -hs,  hs),
            new Vector3(1, 0, 0),
            new Vector2Int(0, 0)
        );
        
        // top face +y
        CreateQuad(
            new Vector3(-hs,  hs, -hs),
            new Vector3(-hs,  hs,  hs),
            new Vector3( hs,  hs,  hs),
            new Vector3( hs,  hs, -hs),
            new Vector3(0, 1, 0),
            new Vector2Int(0, 1)
        );
        
        // bottom face -y
        CreateQuad(
            new Vector3( hs, -hs, -hs),
            new Vector3( hs, -hs,  hs),
            new Vector3(-hs, -hs,  hs),
            new Vector3(-hs, -hs, -hs),
            new Vector3(0, -1, 0),
            new Vector2Int(1, 0)
        );
        
        mesh.vertices = vertices.ToArray();
        mesh.normals = normals.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.triangles = triangles.ToArray();

        return mesh;
    }
    
    void CreateQuad (Vector3 bl, Vector3 tl, Vector3 tr, Vector3 br, Vector3 normal, Vector2Int uvTile) {      //Vector2Int is just a 2D int
        int startIndex = vertices.Count;

        //adding 4 vertices for quad
        vertices.Add(bl);   //0
        vertices.Add(tl);   //1
        vertices.Add(tr);   //2
        vertices.Add(br);   //3

        //adding corresponding normals
        Vector3[] _normals = { normal, normal, normal, normal };
        normals.AddRange(_normals);      //same as adding normals 4 times with .Add

        //splitting our texture into 4 uvs, 1 per adding to list 
        Vector2 tilePos = new Vector2(uvTile.x, uvTile.y) * 0.5f;

        //adding corresponding uvs
        uvs.Add(new Vector2(0.0f + tilePos.x, 0.0f + tilePos.y));   //uv for bl vertex
        uvs.Add(new Vector2(0.0f + tilePos.x, 0.5f + tilePos.y));   //uv for tl vertex
        uvs.Add(new Vector2(0.5f + tilePos.x, 0.5f + tilePos.y));   //uv for tr vertex
        uvs.Add(new Vector2(0.5f + tilePos.x, 0.0f + tilePos.y));   //uv for br vertex

        //having startIndex allows us to create unique quads
        triangles.Add(startIndex + 0);
        triangles.Add(startIndex + 1);
        triangles.Add(startIndex + 2);

        triangles.Add(startIndex + 0);
        triangles.Add(startIndex + 2);
        triangles.Add(startIndex + 3);
    }
}