//vector.h
#ifndef VECTOR_H
#define VECTOR_H

#define v_element double

class Vector
{
 public:
  v_element x;
  v_element y;
  v_element z;

  Vector(void);
  Vector(v_element xi,v_element yi,v_element zi);
  ~Vector(){}

  v_element magnitude();             // RETURNS MAGNITUDE OF VECTOR
  void normalize();               // MAKE VECTOR UNIT VECTOR
  void reverse();                 // x = -x, y = - y,  z = -z
 
  Vector& operator+=(Vector u); //vector addition
  Vector& operator-=(Vector u); //vector subtraction
  Vector& operator*=(v_element s); //scaling
  Vector& operator/=(v_element s); //scaling

  Vector operator-(void);

};

Vector operator+(Vector u,Vector v); // vector addition u + v
Vector operator-(Vector u,Vector v); // vector subtraction u - v
Vector operator^(Vector u,Vector v); // vector cross product u ^ v
v_element operator*(Vector u,Vector v); // vector dot product u * v
Vector operator*(v_element s,Vector u);  // scalar multiplication s*u
Vector operator*(Vector u,v_element s);  // u*s
Vector operator/(Vector u,v_element s);  // u/s
v_element TripleScalarProduct(Vector u,Vector v,Vector w); // triple scalar product
 
#endif
