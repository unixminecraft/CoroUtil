#version 120

//seldom changing or 1 time use data - non instanced:
attribute vec3 position; //mesh pos
attribute vec2 texCoord;
attribute vec3 vertexNormal; //unused
//seldom - instanced
attribute mat4 modelMatrix; //used to be modelViewMatrix, separate from view matrix
attribute vec4 rgba; //4th entry, alpha not used here, might as well leave vec4 unless more efficient to separate things to per float/attrib entries
//often changed data - instanced
attribute float alpha;
attribute float brightness;
//alpha?
//
//attribute vec4 rgbaTest;
//in vec2 texOffset;

varying vec2 outTexCoord;
varying float outBrightness;
varying vec4 outRGBA;

uniform mat4 modelViewMatrixCamera;

uniform int time;
//uniform mat4 projectionMatrix;

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

    int timeMod = int(mod(time * 4, 360));
    float rot = sin(timeMod * 0.0174533) * 0.25;
    float rot2 = cos(timeMod * 0.0174533) * 0.25;
    mat4 swayrotate = rotationMatrix(vec3(1, 0, 0), rot);
    mat4 swayrotate2 = rotationMatrix(vec3(0, 0, 1), rot2);

    mat4 test1 = mat4(
        1, 0, 0, 0,
        0, 1, 0, 7,
        0, 0, 1, 0,
        0, 0, 0, 1);

    mat4 test2 = mat4(
        1, 0, 0, 0,
        0, 1, 0, -7,
        0, 0, 1, 0,
        0, 0, 0, 1);

        gl_Position = modelViewMatrixCamera * modelMatrix * swayrotate * swayrotate2 * vec4(position, 1.0);

	// Support for texture atlas, update texture coordinates
    //float x = (texCoord.x / numCols + texOffset.x);
    //float y = (texCoord.y / numRows + texOffset.y);

	outTexCoord = texCoord;
	outBrightness = brightness;

	//temp
	//rgba.x = 1;
	//rgba.y = 1;
	//rgba.z = 1;
	//rgba.w = 1;

	outRGBA = new vec4(rgba.x, rgba.y, rgba.z, alpha);
}