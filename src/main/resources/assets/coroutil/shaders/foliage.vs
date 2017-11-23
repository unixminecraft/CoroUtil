#version 120

in int gl_VertexID;
in int gl_InstanceID;
//seldom changing or 1 time use data - non instanced:
attribute vec3 position; //mesh pos
attribute vec2 texCoord;
attribute vec3 vertexNormal; //unused
//seldom - instanced
attribute mat4 modelMatrix; //used to be modelViewMatrix, separate from view matrix
attribute vec4 rgba; //4th entry, alpha not used here, might as well leave vec4 unless more efficient to separate things to per float/attrib entries
attribute vec3 meta;
//often changed data - instanced
attribute vec2 alphaBrightness;
//attribute float alpha;
//attribute float brightness;
//alpha?
//
//attribute vec4 rgbaTest;
//in vec2 texOffset;

varying vec2 outTexCoord;
varying float outBrightness;
varying vec4 outRGBA;

//uniform mat4 projectionMatrix;

uniform mat4 modelViewMatrixCamera;
//uniform mat4 modelViewMatrixClassic;

uniform int time;
uniform float partialTick;
uniform float windDir;
uniform float windSpeed;


//uniform int numCols;
//uniform int numRows;

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

void main()
{

    float radian = 0.0174533;
    int swayLag = 7;
    float index = meta.x;
    float animationID = meta.y;
    float heightIndex = meta.z;
    float rotation = rgba.w;

    if (heightIndex >= 0 && (gl_VertexID == 0 || gl_VertexID == 3)) {
        heightIndex += 1;
    }

    float timeSmooth = (time-1) + partialTick;
    //int timeMod = int(mod((timeSmooth + gl_InstanceID * 3) * 2, 360));
    //int timeMod = int(mod((timeSmooth + index * 3) * 10, 360));
    int timeMod = int(mod(((timeSmooth + ((heightIndex + 1) * swayLag)) * 4) + rotation, 360));

    float variance = 1;//windSpeed * 0.5;

    float rot = sin(timeMod * radian) * variance;
    float rot2 = cos(timeMod * radian) * variance;

    //baseyaw=atan2(R(2,1),R(1,1));
    float baseYaw=atan(modelMatrix[1][1],modelMatrix[2][1]);
    baseYaw = rotation;
    //rot = -sin(baseYaw * 0.0174533);
    //rot2 = cos(baseYaw * 0.0174533);

    //float adjDir = windDir - baseYaw;//(baseYaw / 0.0174533);// - (baseYaw + 180);
    float adjDir = 0;//-baseYaw;//(baseYaw / 0.0174533);// - (baseYaw + 180);

    float ampWind = 0.6;

    float ampIndex = heightIndex + 1;
    if (heightIndex >= 1 && !(gl_VertexID == 0 || gl_VertexID == 3)) {
        //ampIndex -= 1F;
    }

    float xAdj = rot;//(-sin(adjDir * 0.0174533) + rot) * ampWind * ampIndex;
    float yAdj = 1;//rot;//(-sin(adjDir * 0.0174533) + rot) * windSpeed * ampWind * ampIndex;
    float zAdj = rot2;//(cos(adjDir * 0.0174533) + rot2) * ampWind * ampIndex;
    //xAdj = 0;
    //yAdj = 0;
    //zAdj = 0;
    //vec3 sway = normalize(vec3(xAdj, yAdj, zAdj));
    vec3 sway = vec3(xAdj, yAdj, zAdj);
    sway = vec3(sway.x, 0, sway.z);

    //use or dont use, in pairs
    //sway = normalize(sway);
    //sway = sway * ampIndex;

    //float length = sqrt(sway.x * sway.x + sway.y * sway.y + sway.z * sway.z);
    //sway = vec3(sway.x / length, sway.y / length, sway.z / length);
    vec3 posSway = position + sway;
    //posSway = normalize(posSway);
    //vec3 posSway = vec3(position.x + sway.x, position.y + sway.y, position.z + sway.z);
    //rot = 0;
    //rot2 = 0;
    mat4 swayrotate = rotationMatrix(vec3(0, 1, 0), 0);//15 * index * radian);
    vec4 conv = vec4(1, 1, 1, 1);
    //mat4 swayrotate2 = rotationMatrix(vec3(0, 0, 1), rot2);

    //calc order needed?: cam, model, mesh with sway, 90 y axis ???

    //top parts
    if (heightIndex == 0) {
        if (gl_VertexID == 0 || gl_VertexID == 3) {
            //gl_Position = vec4(posSway.x, posSway.y, posSway.z, 1.0) * swayrotate * modelViewMatrixCamera * modelMatrix;
            gl_Position = modelViewMatrixCamera * modelMatrix * swayrotate * vec4(posSway.x, posSway.y, posSway.z, 1.0);
        } else {
            gl_Position = modelViewMatrixCamera * modelMatrix * swayrotate * vec4(position, 1.0);
            //gl_Position = modelViewMatrixCamera * modelMatrix * vec4(position.x + xAdj, position.y + yAdj, position.z + zAdj, 1.0);
        }
    } else {
        if (gl_VertexID == 0 || gl_VertexID == 3) {
            gl_Position = modelViewMatrixCamera * modelMatrix * swayrotate * vec4(posSway.x, posSway.y, posSway.z, 1.0);
            //gl_Position = modelViewMatrixCamera * modelMatrix * vec4(position, 1.0);
        } else {
            //gl_Position = modelViewMatrixCamera * modelMatrix * vec4(position, 1.0);
            gl_Position = modelViewMatrixCamera * modelMatrix * swayrotate * vec4(posSway.x, posSway.y, posSway.z, 1.0);
        }
    }

    //vec4
    //gl_Position

    //from example:
    //vec4 eyePos = gl_ModelViewMatrix * gl_Vertex;
    //gl_FogFragCoord = abs(eyePos.z/eyePos.w);

    //vec4 eyePos = gl_ModelViewMatrix * vec4(position, 1.0);
    //vec4 eyePos = modelViewMatrixCamera * modelMatrix * vec4(position, 1.0);
    //gl_FogFragCoord = abs(eyePos.z/eyePos.w);

    //this is for distance to camera
    //gl_FogFragCoord = alpha;

    //my math is bad and i should feel bad... but this works
    gl_FogFragCoord = abs(gl_Position.z);
    //gl_FogFragCoord = 6;

	// Support for texture atlas, update texture coordinates
    //float x = (texCoord.x / numCols + texOffset.x);
    //float y = (texCoord.y / numRows + texOffset.y);

	outTexCoord = texCoord;
	outBrightness = alphaBrightness.y;

	//temp
	//rgba.x = 1;
	//rgba.y = 1;
	//rgba.z = 1;
	//rgba.w = 1;

	outRGBA = vec4(rgba.x, rgba.y, rgba.z, alphaBrightness.x);
}