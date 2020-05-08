#include "ruby.h"

#define ROUNDER 1000000

#define DENOM_1 1
#define DENOM_2 8
#define DENOM_3 10
#define DENOM_4 2
#define DENOM_5 2
#define DENOM_6 2

#define FACTOR_1 1
#define FACTOR_2 8
#define FACTOR_3 80
#define FACTOR_4 160
#define FACTOR_5 320
#define FACTOR_6 640

#define DX_1 1.0
#define DX_2 0.125
#define DX_3 0.0125
#define DX_4 0.00625
#define DX_5 0.003125
#define DX_6 0.0015625

#define divmod(var1, var2, denom) \
{ \
  var2 = var1 % denom; \
  var1 = var1 / denom; \
}

#define mesh2int(var, meshcode, offset, len) \
{ \
  char buf[3]; \
  strncpy(buf, &meshcode[offset], len); \
  buf[len] = '\0'; \
  var = atoi(buf); \
}

int
encode_mesh22 (int lat, int lon)
{
  if ( lat == 0 ) {
    return ( lon == 0 ) ? 1 : 2;
  }
  else if ( lat == 1 ) {
    return ( lon == 0 ) ? 3 : 4;
  }
  else {
    rb_raise(rb_eRuntimeError, "invalid inputls");    
  }
}

void
decode_mesh22 (int code, int *lat, int *lon)
{
  switch (code)
  {
    case 1:
      *lat = 0;
      *lon = 0;
      break;
    case 2:
      *lat = 0;
      *lon = 1;
      break;
    case 3:
      *lat = 1;
      *lon = 0;
      break;
    case 4:
      *lat = 1;
      *lon = 1;
      break;
    default:
      rb_raise(rb_eRuntimeError, "invalid meshcode");
  }
}

/*
Encodes the given (latitude, longitude, level) to meshcode.

@overload encode (lat, lon, level)
  @param lat [Numeric]
  @param lon [Numeric]
  @param level [Integer] meshlevel 1..6

@return [String] meshcode
*/

static VALUE
rb_meshcode_encode (VALUE self, VALUE vlat, VALUE vlon, VALUE vlevel)
{
  int level;
  char *mc;
  uint64_t lat1, lon1;
  int lat2, lat3, lat4, lat5, lat6;
  int lon2, lon3, lon4, lon5, lon6;
  int code4, code5, code6;
  double lat, lon;
  char buf[64];
  
  lat    = NUM2DBL(vlat);
  lon    = NUM2DBL(vlon);
  level  = NUM2INT(vlevel);
  
  if ( level <= 0 || level >= 7 ) {
    rb_raise(rb_eArgError, "level should be in 1..6");
  }
  
  lon  = lon - 100;

  if ( level == 1 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_1*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_1*lon))) / ROUNDER;                            
  }
  else if ( level == 2 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_2*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_2*lon))) / ROUNDER;                        
  }
  else if ( level == 3 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_3*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_3*lon))) / ROUNDER;                    
  }
  else if ( level == 4 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_4*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_4*lon))) / ROUNDER;                
  }
  else if ( level == 5 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_5*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_5*lon))) / ROUNDER;            
  }
  else if ( level == 6 ) {
    lat1 = ((uint64_t)round((ROUNDER*FACTOR_6*lat*3/2))) / ROUNDER;
    lon1 = ((uint64_t)round((ROUNDER*FACTOR_6*lon))) / ROUNDER;        
  }

  if ( level >= 6 ) {
    divmod(lat1, lat6, DENOM_6);
    divmod(lon1, lon6, DENOM_6);
    code6 = encode_mesh22(lat6, lon6);
  }
  if ( level >= 5 ) {
    divmod(lat1, lat5, DENOM_5);
    divmod(lon1, lon5, DENOM_5);
    code5 = encode_mesh22(lat5, lon5);
  }
  if ( level >= 4 ) {
    divmod(lat1, lat4, DENOM_4);
    divmod(lon1, lon4, DENOM_4);
    code4 = encode_mesh22(lat4, lon4);
  }
  if ( level >= 3 ) {
    divmod(lat1, lat3, DENOM_3);
    divmod(lon1, lon3, DENOM_3);
  }
  if ( level >= 2 ) {
    divmod(lat1, lat2, DENOM_2);
    divmod(lon1, lon2, DENOM_2);
  }
  
  if ( level == 1 ) {
    sprintf(buf, "%02i%02i\0", 
                 lat1, lon1);
  }
  else if ( level == 2 ) {
    sprintf(buf, "%02i%02i%1i%1i\0", 
                 lat1, lon1, lat2, lon2);
  }
  else if ( level == 3 ) {
    sprintf(buf, "%02i%02i%1i%1i%1i%1i\0", 
                 lat1, lon1, lat2, lon2, lat3, lon3);
  }
  else if ( level == 4 ) {
    sprintf(buf, "%02i%02i%1i%1i%1i%1i%1i\0", 
                 lat1, lon1, lat2, lon2, lat3, lon3, code4);
  }
  else if ( level == 5 ) {
    sprintf(buf, "%02i%02i%1i%1i%1i%1i%1i%1i\0", 
                 lat1, lon1, lat2, lon2, lat3, lon3, code4, code5);
  }
  else if ( level == 6 ) {
    sprintf(buf, "%02i%02i%1i%1i%1i%1i%1i%1i%1i\0", 
                 lat1, lon1, lat2, lon2, lat3, lon3, code4, code5, code6);
  }

  return rb_str_new2(buf);
}

int
meshcode_level(int length)
{
  int level;
  
  switch ( length ) {
    case 4:
      level = 1;
      break;
    case 6:
      level = 2;
      break;
    case 8:
      level = 3;
      break;
    case 9:
      level = 4;
      break;
    case 10:
      level = 5;
      break;
    case 11:
      level = 6;
      break;
    default: {
      level = 0;
    }
  }
  return level;
}

/*
Guesses level of mesh from meshcode.

@overload meshlevel (meshcode)
  @param meshcode [String]

@return [Integer] level
*/

static VALUE
rb_meshcode_meshlevel (VALUE self, VALUE vmeshcode)
{
  int length, level;
  
  length  = RSTRING_LEN(vmeshcode);  
  level   = meshcode_level(length);

  if ( ! level ) {
    rb_raise(rb_eArgError, "invalid meshcode length");
  }

  return INT2NUM(level);
}

/*
Caluculate point with meshcode and (yoffset, xoffset)

@overload meshpoint (meshcode, yoffset=nil, xoffset=nil)
  @param meshcode [String]
  @param yoffset [Numeric]
  @param xoffset [Numeric]

@return [Array] (lat, lon)
*/

static VALUE
rb_meshcode_meshpoint (int argc, VALUE *argv, VALUE self)
{
  volatile VALUE vmeshcode, vyoffset, vxoffset;
  int level, length;
  double xoffset, yoffset;
  char *mc;
  int code;
  int lat1, lat2, lat3, lat4, lat5, lat6;
  int lon1, lon2, lon3, lon4, lon5, lon6;
  double lat, lon;
  char buf[3];
  
  rb_scan_args(argc, argv, "12", &vmeshcode, &vyoffset, &vxoffset);

  Check_Type(vmeshcode, T_STRING);

  length  = RSTRING_LEN(vmeshcode);  
  mc      = StringValuePtr(vmeshcode);
  yoffset = ( NIL_P(vyoffset) ) ? 0.0 : NUM2DBL(vyoffset);
  xoffset = ( NIL_P(vxoffset) ) ? 0.0 : NUM2DBL(vxoffset);

  level   = meshcode_level(length);

  if ( ! level ) {
    rb_raise(rb_eArgError, "invalid meshcode length");
  }

  if ( level >= 1 ) {
    mesh2int(lat1, mc, 0, 2);
    mesh2int(lon1, mc, 2, 2);
  }
  if ( level >= 2 ) {
    mesh2int(lat2, mc, 4, 1);
    mesh2int(lon2, mc, 5, 1);    
  }
  if ( level >= 3 ) {
    mesh2int(lat3, mc, 6, 1);
    mesh2int(lon3, mc, 7, 1);
  }
  if ( level >= 4 ) {
    mesh2int(code, mc, 8, 1);
    decode_mesh22(code, &lat4, &lon4);
  }
  if ( level >= 5 ) {
    mesh2int(code, mc, 9, 1);
    decode_mesh22(code, &lat5, &lon5);
  }
  if ( level >= 6 ) {
    mesh2int(code, mc, 10, 1);
    decode_mesh22(code, &lat6, &lon6);
  }

  if ( level == 1 ) {
    lat  = (        lat1 + yoffset)/1.5;
    lon  =  100.0 + lon1 + xoffset;  
  }
  else if ( level == 2 ) {
    lat  = (        lat1 + DX_2*(lat2 + yoffset))/1.5;
    lon  =  100.0 + lon1 + DX_2*(lon2 + xoffset);    
  }
  else if ( level == 3 ) {
    lat  = (        lat1 + DX_2*lat2 + DX_3*(lat3 + yoffset))/1.5;
    lon  =  100.0 + lon1 + DX_2*lon2 + DX_3*(lon3 + xoffset);    
  }
  else if ( level == 4 ) {
    lat  = (        lat1 + DX_2*lat2 + DX_3*lat3 + DX_4*(lat4 + yoffset))/1.5;
    lon  =  100.0 + lon1 + DX_2*lon2 + DX_3*lon3 + DX_4*(lon4 + xoffset);    
  }
  else if ( level == 5 ) {
    lat  = (        lat1 + DX_2*lat2 + DX_3*lat3 + DX_4*lat4 + DX_5*(lat5 + yoffset))/1.5;
    lon  =  100.0 + lon1 + DX_2*lon2 + DX_3*lon3 + DX_4*lon4 + DX_5*(lon5 + xoffset);    
  }
  else if ( level == 6 ) {
    lat  = (        lat1 + DX_2*lat2 + DX_3*lat3 + DX_4*lat4 + DX_5*lat5 + DX_6*(lat6 + yoffset))/1.5;
    lon  =  100.0 + lon1 + DX_2*lon2 + DX_3*lon3 + DX_4*lon4 + DX_5*lon5 + DX_6*(lon6 + xoffset);    
  }
 
  return rb_ary_new3(2, rb_float_new(lat), rb_float_new(lon));
}

void
Init_simple_meshcode()
{
  VALUE rb_mMeshcode = rb_define_module("Meshcode");
  rb_define_singleton_method(rb_mMeshcode, "meshcode", rb_meshcode_encode, 3);
  rb_define_singleton_method(rb_mMeshcode, "meshlevel", rb_meshcode_meshlevel, 1);
  rb_define_singleton_method(rb_mMeshcode, "meshpoint", rb_meshcode_meshpoint, -1);
  
}