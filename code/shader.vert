//
// Vertex shader for the transformation assignment, GLSL 1.50
//
// Created by Warren R. Carithers 2021/10/24.
//
// Contributor:  Nicholas Shinn
//

#version 150

// attribute:  vertex position
in vec4 vPosition;

// add other global shader variables to hold the
// parameters your application code is providing

// Int to be used as boolean for selecting perspective type
uniform int type;

// Floats to hold the bounds of the window
uniform float left;
uniform float right;
uniform float bottom;
uniform float top;
uniform float near;
uniform float far;

// Vectors to hold the various transformations
uniform vec3 scale;
uniform vec3 rotate;
uniform vec3 translate;

// Vectors to hold the camera parameters
uniform vec3 eye;
uniform vec3 lookat;
uniform vec3 up;

void main()
{
	// Creates a scale matrix from the provided scale vector
	mat4 scl = mat4( scale.x, 0.0, 0.0, 0.0,
			 0.0, scale.y, 0.0, 0.0,
			 0.0, 0.0, scale.z, 0.0,
			 0.0, 0.0, 0.0, 1.0 );

	// Float defining the value of pi for radian conversion
	float pi = 3.141592654;

	// Converts the provided Z-angle to radians and finds cos, sin, and negative sin
	float radZ = ( rotate.z * pi) / 180.0; 
	float cosZ = cos( radZ );
	float sinZ = sin( radZ );
	float negsinZ = -sin( radZ );

	// Creates the Z-rotation matrix
	mat4 rtz = mat4( cosZ, negsinZ, 0.0, 0.0, 
			 sinZ, cosZ, 0.0, 0.0,
			 0.0, 0.0, 1.0, 0.0,
			 0.0, 0.0, 0.0, 1.0 );

	// Converts the provided Y-angle to radians and finds cos, sin, and negative sin
	float radY = ( rotate.y * pi) / 180.0;
	float cosY = cos( radY );
	float sinY = sin( radY );
	float negsinY = -sin( radY );

	// Creates the Y-rotation matrix
	mat4 rty = mat4( cosY, 0.0, sinY, 0.0, 
			 0.0, 1.0, 0.0, 0.0,
			 negsinY, 0.0, cosY, 0.0,
			 0.0, 0.0, 0.0, 1.0 );

	// Creates the translation matrix from the provided translate vector
	mat4 tlt = mat4( 1.0, 0.0, 0.0, 0.0,
			   0.0, 1.0, 0.0, 0.0,
			   0.0, 0.0, 1.0, 0.0,
			   translate.x, translate.y, translate.z, 1.0 );

	// Finds the normalized vectors to be used for the camera transformation
	vec3 n = normalize( eye - lookat );
	vec3 u = normalize( cross( normalize(up), n ) );
	vec3 v = normalize( cross( n, u ) );

	// Create the camera transformation matrix from provided camera vectors and calculated normalized vectors
	mat4 cam = mat4( u.x, u.y, u.z, -dot( u, eye ),
			 v.x, v.y, v.z, -dot( v, eye ),
			 n.x, n.y, n.z, -dot( n, eye ),
			 0.0, 0.0, 0.0, 1.0 );

	// Initializes a perspective transformation matrix
	mat4 per;

	// If type is 0, do the Frustum perspective transformation. Otherwise, do the Ortho perspective transformation
	if( type == 0 ){
		// Calculates the values for the matrix from the bounds data
		float fir1 = ( 2 * near ) / ( right - left );
		float fir3 = ( right + left ) / ( right - left );
		float sec2 = ( 2 * near ) / ( top - bottom );
		float sec3 = ( top + bottom) / ( top - bottom );
		float thi3 = -1 * ( ( far + near ) / ( far - near ) );
		float thi4 = ( -2 * far * near ) / ( far - near );
		
		// Creates the Frustum perspective transformation matrix, assigning it to per
		per = mat4( fir1, 0.0, fir3, 0.0,
			    0.0, sec2, sec3, 0.0,
			    0.0, 0.0, thi3, thi4,
			    0.0, 0.0, -1.0, 0.0 );
	} else {
		// Calculates the values of the matrix from the bounds data
		float fir1 = ( 2 / ( right - left ) );
		float fir4 = -1 * ( (right + left) / (right - left) );
		float sec2 = ( 2 / ( top - bottom ) );
		float sec4 = -1 * ( (top + bottom) / (top - bottom) );
		float thi3 = ( -2 / (far - near) );
		float thi4 = -1 * ( (far + near) / (far - near) );

		// Creates the Ortho perspective transformation matrix, assigning it to per
		per = mat4( fir1, 0.0, 0.0, fir4,
			    0.0, sec2, 0.0, sec4,
			    0.0, 0.0, thi3, thi4,
			    0.0, 0.0, 0.0, 1.0 );
	}

	// Calculates the new vector by multiplying the original vector, transformations, camera transformations, and perspective transformations
	vec4 newpos = vPosition * scl * rtz * rty * tlt * cam * per;

	// Returns the new vector
	gl_Position =  newpos;
}
