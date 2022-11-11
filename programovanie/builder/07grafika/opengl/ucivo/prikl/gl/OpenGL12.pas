//    08/02/00 - Egg - Deactivated ClearXXXX procs (weren't useful)<br>
//                     Size-optimized LoadProcAddresses
//    06/02/00 - Egg - Added further checks to DestroyRenderingContext
//    05/02/00 - Egg - Fixed ActivateRenderingContext/DeactivateRenderingContext
//
//
unit OpenGL12;

//----------------------------------------------------------------------------------------------------------------------
//
//  This is an interface unit for the use of OpenGL from within Delphi and contains
//  the translations of gl.h, glu.h as well as some support functions.
//  OpenGL12.pas contains bug fixes and enhancements of Delphi's and other translations
//  as well as support for extensions.
//
//----------------------------------------------------------------------------------------------------------------------
//
// function InitOpenGL: Boolean;
//   Needed to load the OpenGL DLLs and all addresses of the standard functions.
//   In case OpenGL is already initialized this function does nothing. No error
//   is raised, if something goes wrong, but you need to inspect the result in order
//   to know if all went okay.
//   RESULT: True if successful or already loaded, False otherwise
//
// function InitOpenGLFromLibrary(GL_Name, GLU_Name: String): Boolean;
//   Same as InitOpenGL, but you can specify specific DLLs. Useful if you want to
//   use different DLLs then those of Windows. This function closes eventually
//   loaded DLLs before it tries to open the newly given.
//   RESULT: True if successful, false otherwise
//
// procedure CloseOpenGL;
//   Unloads the OpenGL DLLs and sets all function addresses to nil, including
//   extensions. You can load and unload the DLLs as often as you like.
//
// procedure ClearExtensions;
//   Sets all extension routines to nil. This is needed when you change the Pixelformat
//   of your OpenGL window, since the availability of these routines changes from
//   PixelFormat to Pixelformat (and also between various vendors).
//
// function  CreateRenderingContext(DC: HDC; Options: TRCOptions; ColorBits, StencilBits, AccumBits, AuxBuffers: Integer;
//   Layer: Integer): HGLRC;
//   Sets up a pixel format and creates a new rendering context depending of the
//   given parameters:
//     DC          - the device context for which the rc is to be created
//     Options     - options for the context, which the application would like to have
//                   (it is not guaranteed they will be available)
//     ColorBits   - the color depth of the device context (Note: Because of the internal DC handling of the VCL you
//                   should avoid using GetDeviceCaps for memory DCs which are members of a TBitmap class.
//                   Translate the Pixelformat member instead!)
//     StencilBits - wished size of the stencil buffer
//     AccumBits   - wished size of the accumulation buffer
//     AuxBuffers  - wished number of auxiliary buffers
//     Layer       - ID for the layer for which the RC will be created (-1..-15 for underlays, 0 for main plane,
//                   1..15 for overlay planes)
//                   Note: The layer handling is not yet complete as there is very few information
//                   available and (until now) no OpenGL implementation with layer support on the low budget market.
//                   Hence use 0 (for the main plane) as layer ID.
//   RESULT: the newly created context or 0 if setup failed
//
// procedure ActivateRenderingContext(DC: HDC; RC: HGLRC);
//   Makes RC in DC 'current' (wglMakeCurrent(..)) and loads all extension addresses
//   and flags if necessary.
//
// procedure DeactivateRenderingContext;
//   Counterpart to ActivateRenderingContext.
//
// procedure DestroyRenderingContext(RC: HGLRC);
//   RC will be destroyed and must be recreated if you want to use it again. No
//   additional functionality to wglDeleteContext yet.
//
// procedure ReadExtensions;
//   Determines which extensions for the current rendering context are available and
//   loads their addresses. This procedure is called from ActivateRenderingContext
//   if a new pixel format is used, but you can safely call it from where you want
//   to actualize those values (under the condition that a rendering context MUST be
//   active).
//
// procedure ReadImplementationProperties;
//   Determines other properties of the OpenGL DLL (version, availability of extensions).
//   Again, a valid rendering context must be active.
//
//----------------------------------------------------------------------------------------------------------------------
//
// This translation is based on different sources:
//
// - first translation from Artemis Alliance Inc.
// - previous versions from Mike Lischke
// - Alexander Staubo
// - Borland OpenGL.pas (from Delphi 3)
// - Microsoft and SGI OpenGL header files
// - www.opengl.org, www.sgi.com/OpenGL
// - NVidia extension reference as of December 1999
//
//  Contact: public@lischke-online.de
//
//  last change: 04. January 2000
//
//----------------------------------------------------------------------------------------------------------------------


{ ------ Original copyright notice by SGI -----

 Copyright 1996 Silicon Graphics, Inc.
 All Rights Reserved.

 This is UNPUBLISHED PROPRIETARY SOURCE CODE of Silicon Graphics, Inc.;
 the contents of this file may not be disclosed to third parties, copied or
 duplicated in any form, in whole or in part, without the prior written
 permission of Silicon Graphics, Inc.

 RESTRICTED RIGHTS LEGEND:
 Use, duplication or disclosure by the Government is subject to restrictions
 as set forth in subdivision (c)(1)(ii) of the Rights in Technical Data
 and Computer Software clause at DFARS 252.227-7013, and/or in similar or
 successor clauses in the FAR, DOD or NASA FAR Supplement. Unpublished -
 rights reserved under the Copyright Laws of the United States.}


interface

uses
  Windows, Geometry;

type

  TRCOptions = set of (opDoubleBuffered, opGDI, opStereo);

  TGLenum      = UINT;      PGLenum     = ^TGLenum;
  TGLboolean   = UCHAR;     PGLboolean  = ^TGLboolean;
  TGLbitfield  = UINT;      PGLbitfield = ^TGLbitfield;
  TGLbyte      = ShortInt;  PGLbyte     = ^TGLbyte;
  TGLshort     = SHORT;     PGLshort    = ^TGLshort;
  TGLint       = Integer;   PGLint      = ^TGLint;
  TGLsizei     = Integer;   PGLsizei    = ^TGLsizei;
  TGLubyte     = UCHAR;     PGLubyte    = ^TGLubyte;
  TGLushort    = Word;      PGLushort   = ^TGLushort;
  TGLuint      = UINT;      PGLuint     = ^TGLuint;
  TGLfloat     = Single;    PGLfloat    = ^TGLfloat;
  TGLclampf    = Single;    PGLclampf   = ^TGLclampf;
  TGLdouble    = Double;    PGLdouble   = ^TGLdouble;
  TGLclampd    = Double;    PGLclampd   = ^TGLclampd;

var
  GL_VERSION_1_0,
  GL_VERSION_1_1,
  GL_VERSION_1_2,
  GLU_VERSION_1_1,
  GLU_VERSION_1_2,
  GLU_VERSION_1_3: Boolean;

  // Extensions (gl)
  GL_EXT_abgr,
  GL_EXT_bgra,
  GL_EXT_packed_pixels,
  GL_EXT_paletted_texture,
  GL_EXT_vertex_array,
  GL_EXT_index_array_formats,
  GL_EXT_index_func,
  GL_EXT_index_material,
  GL_EXT_index_texture,
  GL_WIN_swap_hint,
  GL_EXT_blend_color,
  GL_EXT_blend_logic_op,
  GL_EXT_blend_minmax,
  GL_EXT_blend_subtract,
  GL_EXT_convolution,
  GL_EXT_copy_texture,
  GL_EXT_histogram,
  GL_EXT_polygon_offset,
  GL_EXT_subtexture,
  GL_EXT_texture_object,
  GL_EXT_texture3D,
  GL_EXT_cmyka,
  GL_EXT_rescale_normal,
  GL_SGI_color_matrix,
  GL_EXT_texture_color_table,
  GL_SGI_color_table,
  GL_EXT_clip_volume_hint,
  GL_EXT_compiled_vertex_array,
  GL_EXT_cull_vertex,
  GL_EXT_point_parameters,
  GL_EXT_texture_env_add,
  GL_EXT_misc_attribute,
  GL_EXT_scene_marker,
  GL_EXT_shared_texture_palette,
  GL_EXT_texture_env_combine,
  GL_NV_texgen_reflection,
  GL_NV_texture_env_combine4,
  GL_ARB_multitexture,
  GL_ARB_imaging,

  GL_EXT_fog_coord,
  GL_EXT_light_max_exponent,
  GL_EXT_secondary_color,
  GL_EXT_separate_specular_color,
  GL_EXT_stencil_wrap,
  GL_EXT_texture_cube_map,
  GL_EXT_texture_filter_anisotropic,
  GL_EXT_texture_lod_bias,
  GL_EXT_vertex_weighting,
  GL_KTX_buffer_region,
  GL_NV_blend_square,
  GL_NV_fog_distance,
  GL_NV_register_combiners,
  GL_NV_texgen_emboss,
  GL_NV_vertex_array_range,
  GL_SGIS_multitexture,
  GL_SGIS_texture_lod,
  WGL_EXT_swap_control,
  
  // Extensions (glu)
  GLU_EXT_Texture, 
  GLU_EXT_object_space_tess, 
  GLU_EXT_nurbs_tessellator: Boolean;

const
  // ********** GL generic constants **********

  // errors
  GL_NO_ERROR                                = 0;
  GL_INVALID_ENUM                            = $0500;
  GL_INVALID_VALUE                           = $0501;
  GL_INVALID_OPERATION                       = $0502;
  GL_STACK_OVERFLOW                          = $0503;
  GL_STACK_UNDERFLOW                         = $0504;
  GL_OUT_OF_MEMORY                           = $0505;

  // attribute bits
  GL_CURRENT_BIT                             = $00000001;
  GL_POINT_BIT                               = $00000002;
  GL_LINE_BIT                                = $00000004;
  GL_POLYGON_BIT                             = $00000008;
  GL_POLYGON_STIPPLE_BIT                     = $00000010;
  GL_PIXEL_MODE_BIT                          = $00000020;
  GL_LIGHTING_BIT                            = $00000040;
  GL_FOG_BIT                                 = $00000080;
  GL_DEPTH_BUFFER_BIT                        = $00000100;
  GL_ACCUM_BUFFER_BIT                        = $00000200;
  GL_STENCIL_BUFFER_BIT                      = $00000400;
  GL_VIEWPORT_BIT                            = $00000800;
  GL_TRANSFORM_BIT                           = $00001000;
  GL_ENABLE_BIT                              = $00002000;
  GL_COLOR_BUFFER_BIT                        = $00004000;
  GL_HINT_BIT                                = $00008000;
  GL_EVAL_BIT                                = $00010000;
  GL_LIST_BIT                                = $00020000;
  GL_TEXTURE_BIT                             = $00040000;
  GL_SCISSOR_BIT                             = $00080000;
  GL_ALL_ATTRIB_BITS                         = $000FFFFF;

  // client attribute bits
  GL_CLIENT_PIXEL_STORE_BIT                  = $00000001;
  GL_CLIENT_VERTEX_ARRAY_BIT                 = $00000002;
  GL_CLIENT_ALL_ATTRIB_BITS                  = $FFFFFFFF;

  // boolean values
  GL_FALSE                                   = 0;
  GL_TRUE                                    = 1;

  // primitives
  GL_POINTS                                  = $0000;
  GL_LINES                                   = $0001;
  GL_LINE_LOOP                               = $0002;
  GL_LINE_STRIP                              = $0003;
  GL_TRIANGLES                               = $0004;
  GL_TRIANGLE_STRIP                          = $0005;
  GL_TRIANGLE_FAN                            = $0006;
  GL_QUADS                                   = $0007;
  GL_QUAD_STRIP                              = $0008;
  GL_POLYGON                                 = $0009;

  // blending 
  GL_ZERO                                    = 0;
  GL_ONE                                     = 1;
  GL_SRC_COLOR                               = $0300;
  GL_ONE_MINUS_SRC_COLOR                     = $0301;
  GL_SRC_ALPHA                               = $0302;
  GL_ONE_MINUS_SRC_ALPHA                     = $0303;
  GL_DST_ALPHA                               = $0304;
  GL_ONE_MINUS_DST_ALPHA                     = $0305;
  GL_DST_COLOR                               = $0306;
  GL_ONE_MINUS_DST_COLOR                     = $0307;
  GL_SRC_ALPHA_SATURATE                      = $0308;
  GL_BLEND_DST                               = $0BE0;
  GL_BLEND_SRC                               = $0BE1;
  GL_BLEND                                   = $0BE2;

  // blending (GL 1.2 ARB imaging)
  GL_BLEND_COLOR                             = $8005;
  GL_CONSTANT_COLOR                          = $8001;
  GL_ONE_MINUS_CONSTANT_COLOR                = $8002;
  GL_CONSTANT_ALPHA                          = $8003;
  GL_ONE_MINUS_CONSTANT_ALPHA                = $8004;
  GL_FUNC_ADD                                = $8006;
  GL_MIN                                     = $8007;
  GL_MAX                                     = $8008;
  GL_FUNC_SUBTRACT                           = $800A;
  GL_FUNC_REVERSE_SUBTRACT                   = $800B;

  // color table GL 1.2 ARB imaging
  GL_COLOR_TABLE                             = $80D0;
  GL_POST_CONVOLUTION_COLOR_TABLE            = $80D1;
  GL_POST_COLOR_MATRIX_COLOR_TABLE           = $80D2;
  GL_PROXY_COLOR_TABLE                       = $80D3;
  GL_PROXY_POST_CONVOLUTION_COLOR_TABLE      = $80D4;
  GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE     = $80D5;
  GL_COLOR_TABLE_SCALE                       = $80D6;
  GL_COLOR_TABLE_BIAS                        = $80D7;
  GL_COLOR_TABLE_FORMAT                      = $80D8;
  GL_COLOR_TABLE_WIDTH                       = $80D9;
  GL_COLOR_TABLE_RED_SIZE                    = $80DA;
  GL_COLOR_TABLE_GREEN_SIZE                  = $80DB;
  GL_COLOR_TABLE_BLUE_SIZE                   = $80DC;
  GL_COLOR_TABLE_ALPHA_SIZE                  = $80DD;
  GL_COLOR_TABLE_LUMINANCE_SIZE              = $80DE;
  GL_COLOR_TABLE_INTENSITY_SIZE              = $80DF;

  // convolutions GL 1.2 ARB imaging
  GL_CONVOLUTION_1D                          = $8010;
  GL_CONVOLUTION_2D                          = $8011;
  GL_SEPARABLE_2D                            = $8012;
  GL_CONVOLUTION_BORDER_MODE                 = $8013;
  GL_CONVOLUTION_FILTER_SCALE                = $8014;
  GL_CONVOLUTION_FILTER_BIAS                 = $8015;
  GL_REDUCE                                  = $8016;
  GL_CONVOLUTION_FORMAT                      = $8017;
  GL_CONVOLUTION_WIDTH                       = $8018;
  GL_CONVOLUTION_HEIGHT                      = $8019;
  GL_MAX_CONVOLUTION_WIDTH                   = $801A;
  GL_MAX_CONVOLUTION_HEIGHT                  = $801B;
  GL_POST_CONVOLUTION_RED_SCALE              = $801C;
  GL_POST_CONVOLUTION_GREEN_SCALE            = $801D;
  GL_POST_CONVOLUTION_BLUE_SCALE             = $801E;
  GL_POST_CONVOLUTION_ALPHA_SCALE            = $801F;
  GL_POST_CONVOLUTION_RED_BIAS               = $8020;
  GL_POST_CONVOLUTION_GREEN_BIAS             = $8021;
  GL_POST_CONVOLUTION_BLUE_BIAS              = $8022;
  GL_POST_CONVOLUTION_ALPHA_BIAS             = $8023;

  // histogram GL 1.2 ARB imaging
  GL_HISTOGRAM                               = $8024;
  GL_PROXY_HISTOGRAM                         = $8025;
  GL_HISTOGRAM_WIDTH                         = $8026;
  GL_HISTOGRAM_FORMAT                        = $8027;
  GL_HISTOGRAM_RED_SIZE                      = $8028;
  GL_HISTOGRAM_GREEN_SIZE                    = $8029;
  GL_HISTOGRAM_BLUE_SIZE                     = $802A;
  GL_HISTOGRAM_ALPHA_SIZE                    = $802B;
  GL_HISTOGRAM_LUMINANCE_SIZE                = $802C;
  GL_HISTOGRAM_SINK                          = $802D;
  GL_MINMAX                                  = $802E;
  GL_MINMAX_FORMAT                           = $802F;
  GL_MINMAX_SINK                             = $8030;

  // buffers
  GL_NONE                                    = 0;
  GL_FRONT_LEFT                              = $0400;
  GL_FRONT_RIGHT                             = $0401;
  GL_BACK_LEFT                               = $0402;
  GL_BACK_RIGHT                              = $0403;
  GL_FRONT                                   = $0404;
  GL_BACK                                    = $0405;
  GL_LEFT                                    = $0406;
  GL_RIGHT                                   = $0407;
  GL_FRONT_AND_BACK                          = $0408;
  GL_AUX0                                    = $0409;
  GL_AUX1                                    = $040A;
  GL_AUX2                                    = $040B;
  GL_AUX3                                    = $040C;
  GL_AUX_BUFFERS                             = $0C00;
  GL_DRAW_BUFFER                             = $0C01;
  GL_READ_BUFFER                             = $0C02;
  GL_DOUBLEBUFFER                            = $0C32;
  GL_STEREO                                  = $0C33;

  // depth buffer
  GL_DEPTH_RANGE                             = $0B70;
  GL_DEPTH_TEST                              = $0B71;
  GL_DEPTH_WRITEMASK                         = $0B72;
  GL_DEPTH_CLEAR_VALUE                       = $0B73;
  GL_DEPTH_FUNC                              = $0B74;
  GL_NEVER                                   = $0200;
  GL_LESS                                    = $0201;
  GL_EQUAL                                   = $0202;
  GL_LEQUAL                                  = $0203;
  GL_GREATER                                 = $0204;
  GL_NOTEQUAL                                = $0205;
  GL_GEQUAL                                  = $0206;
  GL_ALWAYS                                  = $0207;

  // accumulation buffer
  GL_ACCUM                                   = $0100;
  GL_LOAD                                    = $0101;
  GL_RETURN                                  = $0102;
  GL_MULT                                    = $0103;
  GL_ADD                                     = $0104;
  GL_ACCUM_CLEAR_VALUE                       = $0B80;

  // feedback buffer
  GL_FEEDBACK_BUFFER_POINTER                 = $0DF0;
  GL_FEEDBACK_BUFFER_SIZE                    = $0DF1;
  GL_FEEDBACK_BUFFER_TYPE                    = $0DF2;

  // feedback types
  GL_2D                                      = $0600;
  GL_3D                                      = $0601;
  GL_3D_COLOR                                = $0602;
  GL_3D_COLOR_TEXTURE                        = $0603;
  GL_4D_COLOR_TEXTURE                        = $0604;

  // feedback tokens
  GL_PASS_THROUGH_TOKEN                      = $0700;
  GL_POINT_TOKEN                             = $0701;
  GL_LINE_TOKEN                              = $0702;
  GL_POLYGON_TOKEN                           = $0703;
  GL_BITMAP_TOKEN                            = $0704;
  GL_DRAW_PIXEL_TOKEN                        = $0705;
  GL_COPY_PIXEL_TOKEN                        = $0706;
  GL_LINE_RESET_TOKEN                        = $0707;

  // fog
  GL_EXP                                     = $0800;
  GL_EXP2                                    = $0801;
  GL_FOG                                     = $0B60;
  GL_FOG_INDEX                               = $0B61;
  GL_FOG_DENSITY                             = $0B62;
  GL_FOG_START                               = $0B63;
  GL_FOG_END                                 = $0B64;
  GL_FOG_MODE                                = $0B65;
  GL_FOG_COLOR                               = $0B66;

  // pixel mode, transfer
  GL_PIXEL_MAP_I_TO_I                        = $0C70;
  GL_PIXEL_MAP_S_TO_S                        = $0C71;
  GL_PIXEL_MAP_I_TO_R                        = $0C72;
  GL_PIXEL_MAP_I_TO_G                        = $0C73;
  GL_PIXEL_MAP_I_TO_B                        = $0C74;
  GL_PIXEL_MAP_I_TO_A                        = $0C75;
  GL_PIXEL_MAP_R_TO_R                        = $0C76;
  GL_PIXEL_MAP_G_TO_G                        = $0C77;
  GL_PIXEL_MAP_B_TO_B                        = $0C78;
  GL_PIXEL_MAP_A_TO_A                        = $0C79;

  // vertex arrays
  GL_VERTEX_ARRAY_POINTER                    = $808E;
  GL_NORMAL_ARRAY_POINTER                    = $808F;
  GL_COLOR_ARRAY_POINTER                     = $8090;
  GL_INDEX_ARRAY_POINTER                     = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER             = $8092;
  GL_EDGE_FLAG_ARRAY_POINTER                 = $8093;

  // stenciling
  GL_STENCIL_TEST                            = $0B90;
  GL_STENCIL_CLEAR_VALUE                     = $0B91;
  GL_STENCIL_FUNC                            = $0B92;
  GL_STENCIL_VALUE_MASK                      = $0B93;
  GL_STENCIL_FAIL                            = $0B94;
  GL_STENCIL_PASS_DEPTH_FAIL                 = $0B95;
  GL_STENCIL_PASS_DEPTH_PASS                 = $0B96;
  GL_STENCIL_REF                             = $0B97;
  GL_STENCIL_WRITEMASK                       = $0B98;
  GL_KEEP                                    = $1E00;
  GL_REPLACE                                 = $1E01;
  GL_INCR                                    = $1E02;
  GL_DECR                                    = $1E03;

  // color material
  GL_COLOR_MATERIAL_FACE                     = $0B55;
  GL_COLOR_MATERIAL_PARAMETER                = $0B56;
  GL_COLOR_MATERIAL                          = $0B57;

  // points
  GL_POINT_SMOOTH                            = $0B10;
  GL_POINT_SIZE                              = $0B11;
  GL_POINT_SIZE_RANGE                        = $0B12;
  GL_POINT_SIZE_GRANULARITY                  = $0B13;

  // lines
  GL_LINE_SMOOTH                             = $0B20;
  GL_LINE_WIDTH                              = $0B21;
  GL_LINE_WIDTH_RANGE                        = $0B22;
  GL_LINE_WIDTH_GRANULARITY                  = $0B23;
  GL_LINE_STIPPLE                            = $0B24;
  GL_LINE_STIPPLE_PATTERN                    = $0B25;
  GL_LINE_STIPPLE_REPEAT                     = $0B26;

  // polygons
  GL_POLYGON_MODE                            = $0B40;
  GL_POLYGON_SMOOTH                          = $0B41;
  GL_POLYGON_STIPPLE                         = $0B42;
  GL_EDGE_FLAG                               = $0B43;
  GL_CULL_FACE                               = $0B44;
  GL_CULL_FACE_MODE                          = $0B45;
  GL_FRONT_FACE                              = $0B46;
  GL_CW                                      = $0900;
  GL_CCW                                     = $0901;
  GL_POINT                                   = $1B00;
  GL_LINE                                    = $1B01;
  GL_FILL                                    = $1B02;

  // display lists
  GL_LIST_MODE                               = $0B30;
  GL_LIST_BASE                               = $0B32;
  GL_LIST_INDEX                              = $0B33;
  GL_COMPILE                                 = $1300;
  GL_COMPILE_AND_EXECUTE                     = $1301;

  // lighting
  GL_LIGHTING                                = $0B50;
  GL_LIGHT_MODEL_LOCAL_VIEWER                = $0B51;
  GL_LIGHT_MODEL_TWO_SIDE                    = $0B52;
  GL_LIGHT_MODEL_AMBIENT                     = $0B53;
  GL_LIGHT_MODEL_COLOR_CONTROL               = $81F8; // GL 1.2
  GL_SHADE_MODEL                             = $0B54;
  GL_NORMALIZE                               = $0BA1;
  GL_AMBIENT                                 = $1200;
  GL_DIFFUSE                                 = $1201;
  GL_SPECULAR                                = $1202;
  GL_POSITION                                = $1203;
  GL_SPOT_DIRECTION                          = $1204;
  GL_SPOT_EXPONENT                           = $1205;
  GL_SPOT_CUTOFF                             = $1206;
  GL_CONSTANT_ATTENUATION                    = $1207;
  GL_LINEAR_ATTENUATION                      = $1208;
  GL_QUADRATIC_ATTENUATION                   = $1209;
  GL_EMISSION                                = $1600;
  GL_SHININESS                               = $1601;
  GL_AMBIENT_AND_DIFFUSE                     = $1602;
  GL_COLOR_INDEXES                           = $1603;
  GL_FLAT                                    = $1D00;
  GL_SMOOTH                                  = $1D01;
  GL_LIGHT0                                  = $4000;
  GL_LIGHT1                                  = $4001;
  GL_LIGHT2                                  = $4002;
  GL_LIGHT3                                  = $4003;
  GL_LIGHT4                                  = $4004;
  GL_LIGHT5                                  = $4005;
  GL_LIGHT6                                  = $4006;
  GL_LIGHT7                                  = $4007;

  // matrix modes
  GL_MATRIX_MODE                             = $0BA0;
  GL_MODELVIEW                               = $1700;
  GL_PROJECTION                              = $1701;
  GL_TEXTURE                                 = $1702;

  // gets
  GL_CURRENT_COLOR                           = $0B00;
  GL_CURRENT_INDEX                           = $0B01;
  GL_CURRENT_NORMAL                          = $0B02;
  GL_CURRENT_TEXTURE_COORDS                  = $0B03;
  GL_CURRENT_RASTER_COLOR                    = $0B04;
  GL_CURRENT_RASTER_INDEX                    = $0B05;
  GL_CURRENT_RASTER_TEXTURE_COORDS           = $0B06;
  GL_CURRENT_RASTER_POSITION                 = $0B07;
  GL_CURRENT_RASTER_POSITION_VALID           = $0B08;
  GL_CURRENT_RASTER_DISTANCE                 = $0B09;
  GL_MAX_LIST_NESTING                        = $0B31;
  GL_VIEWPORT                                = $0BA2;
  GL_MODELVIEW_STACK_DEPTH                   = $0BA3;
  GL_PROJECTION_STACK_DEPTH                  = $0BA4;
  GL_TEXTURE_STACK_DEPTH                     = $0BA5;
  GL_MODELVIEW_MATRIX                        = $0BA6;
  GL_PROJECTION_MATRIX                       = $0BA7;
  GL_TEXTURE_MATRIX                          = $0BA8;
  GL_ATTRIB_STACK_DEPTH                      = $0BB0;
  GL_CLIENT_ATTRIB_STACK_DEPTH               = $0BB1;

  GL_SINGLE_COLOR                            = $81F9; // GL 1.2
  GL_SEPARATE_SPECULAR_COLOR                 = $81FA; // GL 1.2

  // alpha testing
  GL_ALPHA_TEST                              = $0BC0;
  GL_ALPHA_TEST_FUNC                         = $0BC1;
  GL_ALPHA_TEST_REF                          = $0BC2;

  GL_LOGIC_OP_MODE                           = $0BF0;
  GL_INDEX_LOGIC_OP                          = $0BF1;
  GL_LOGIC_OP                                = $0BF1;
  GL_COLOR_LOGIC_OP                          = $0BF2;
  GL_SCISSOR_BOX                             = $0C10;
  GL_SCISSOR_TEST                            = $0C11;
  GL_INDEX_CLEAR_VALUE                       = $0C20;
  GL_INDEX_WRITEMASK                         = $0C21;
  GL_COLOR_CLEAR_VALUE                       = $0C22;
  GL_COLOR_WRITEMASK                         = $0C23;
  GL_INDEX_MODE                              = $0C30;
  GL_RGBA_MODE                               = $0C31;
  GL_RENDER_MODE                             = $0C40;
  GL_PERSPECTIVE_CORRECTION_HINT             = $0C50;
  GL_POINT_SMOOTH_HINT                       = $0C51;
  GL_LINE_SMOOTH_HINT                        = $0C52;
  GL_POLYGON_SMOOTH_HINT                     = $0C53;
  GL_FOG_HINT                                = $0C54;
  GL_TEXTURE_GEN_S                           = $0C60;
  GL_TEXTURE_GEN_T                           = $0C61;
  GL_TEXTURE_GEN_R                           = $0C62;
  GL_TEXTURE_GEN_Q                           = $0C63;
  GL_PIXEL_MAP_I_TO_I_SIZE                   = $0CB0;
  GL_PIXEL_MAP_S_TO_S_SIZE                   = $0CB1;
  GL_PIXEL_MAP_I_TO_R_SIZE                   = $0CB2;
  GL_PIXEL_MAP_I_TO_G_SIZE                   = $0CB3;
  GL_PIXEL_MAP_I_TO_B_SIZE                   = $0CB4;
  GL_PIXEL_MAP_I_TO_A_SIZE                   = $0CB5;
  GL_PIXEL_MAP_R_TO_R_SIZE                   = $0CB6;
  GL_PIXEL_MAP_G_TO_G_SIZE                   = $0CB7;
  GL_PIXEL_MAP_B_TO_B_SIZE                   = $0CB8;
  GL_PIXEL_MAP_A_TO_A_SIZE                   = $0CB9;
  GL_UNPACK_SWAP_BYTES                       = $0CF0;
  GL_UNPACK_LSB_FIRST                        = $0CF1;
  GL_UNPACK_ROW_LENGTH                       = $0CF2;
  GL_UNPACK_SKIP_ROWS                        = $0CF3;
  GL_UNPACK_SKIP_PIXELS                      = $0CF4;
  GL_UNPACK_ALIGNMENT                        = $0CF5;
  GL_PACK_SWAP_BYTES                         = $0D00;
  GL_PACK_LSB_FIRST                          = $0D01;
  GL_PACK_ROW_LENGTH                         = $0D02;
  GL_PACK_SKIP_ROWS                          = $0D03;
  GL_PACK_SKIP_PIXELS                        = $0D04;
  GL_PACK_ALIGNMENT                          = $0D05;
  GL_PACK_SKIP_IMAGES                        = $806B; // GL 1.2
  GL_PACK_IMAGE_HEIGHT                       = $806C; // GL 1.2
  GL_UNPACK_SKIP_IMAGES                      = $806D; // GL 1.2
  GL_UNPACK_IMAGE_HEIGHT                     = $806E; // GL 1.2
  GL_MAP_COLOR                               = $0D10;
  GL_MAP_STENCIL                             = $0D11;
  GL_INDEX_SHIFT                             = $0D12;
  GL_INDEX_OFFSET                            = $0D13;
  GL_RED_SCALE                               = $0D14;
  GL_RED_BIAS                                = $0D15;
  GL_ZOOM_X                                  = $0D16;
  GL_ZOOM_Y                                  = $0D17;
  GL_GREEN_SCALE                             = $0D18;
  GL_GREEN_BIAS                              = $0D19;
  GL_BLUE_SCALE                              = $0D1A;
  GL_BLUE_BIAS                               = $0D1B;
  GL_ALPHA_SCALE                             = $0D1C;
  GL_ALPHA_BIAS                              = $0D1D;
  GL_DEPTH_SCALE                             = $0D1E;
  GL_DEPTH_BIAS                              = $0D1F;
  GL_MAX_EVAL_ORDER                          = $0D30;
  GL_MAX_LIGHTS                              = $0D31;
  GL_MAX_CLIP_PLANES                         = $0D32;
  GL_MAX_TEXTURE_SIZE                        = $0D33;
  GL_MAX_3D_TEXTURE_SIZE                     = $8073; // GL 1.2
  GL_MAX_PIXEL_MAP_TABLE                     = $0D34;
  GL_MAX_ATTRIB_STACK_DEPTH                  = $0D35;
  GL_MAX_MODELVIEW_STACK_DEPTH               = $0D36;
  GL_MAX_NAME_STACK_DEPTH                    = $0D37;
  GL_MAX_PROJECTION_STACK_DEPTH              = $0D38;
  GL_MAX_TEXTURE_STACK_DEPTH                 = $0D39;
  GL_MAX_VIEWPORT_DIMS                       = $0D3A;
  GL_MAX_CLIENT_ATTRIB_STACK_DEPTH           = $0D3B;
  GL_MAX_ELEMENTS_VERTICES                   = $F0E8; // GL 1.2
  GL_MAX_ELEMENTS_INDICES                    = $F0E9; // GL 1.2
  GL_RESCALE_NORMAL                          = $803A; // GL 1.2
  GL_SUBPIXEL_BITS                           = $0D50;
  GL_INDEX_BITS                              = $0D51;
  GL_RED_BITS                                = $0D52;
  GL_GREEN_BITS                              = $0D53;
  GL_BLUE_BITS                               = $0D54;
  GL_ALPHA_BITS                              = $0D55;
  GL_DEPTH_BITS                              = $0D56;
  GL_STENCIL_BITS                            = $0D57;
  GL_ACCUM_RED_BITS                          = $0D58;
  GL_ACCUM_GREEN_BITS                        = $0D59;
  GL_ACCUM_BLUE_BITS                         = $0D5A;
  GL_ACCUM_ALPHA_BITS                        = $0D5B;
  GL_NAME_STACK_DEPTH                        = $0D70;
  GL_AUTO_NORMAL                             = $0D80;
  GL_MAP1_COLOR_4                            = $0D90;
  GL_MAP1_INDEX                              = $0D91;
  GL_MAP1_NORMAL                             = $0D92;
  GL_MAP1_TEXTURE_COORD_1                    = $0D93;
  GL_MAP1_TEXTURE_COORD_2                    = $0D94;
  GL_MAP1_TEXTURE_COORD_3                    = $0D95;
  GL_MAP1_TEXTURE_COORD_4                    = $0D96;
  GL_MAP1_VERTEX_3                           = $0D97;
  GL_MAP1_VERTEX_4                           = $0D98;
  GL_MAP2_COLOR_4                            = $0DB0;
  GL_MAP2_INDEX                              = $0DB1;
  GL_MAP2_NORMAL                             = $0DB2;
  GL_MAP2_TEXTURE_COORD_1                    = $0DB3;
  GL_MAP2_TEXTURE_COORD_2                    = $0DB4;
  GL_MAP2_TEXTURE_COORD_3                    = $0DB5;
  GL_MAP2_TEXTURE_COORD_4                    = $0DB6;
  GL_MAP2_VERTEX_3                           = $0DB7;
  GL_MAP2_VERTEX_4                           = $0DB8;
  GL_MAP1_GRID_DOMAIN                        = $0DD0;
  GL_MAP1_GRID_SEGMENTS                      = $0DD1;
  GL_MAP2_GRID_DOMAIN                        = $0DD2;
  GL_MAP2_GRID_SEGMENTS                      = $0DD3;
  GL_TEXTURE_1D                              = $0DE0;
  GL_TEXTURE_2D                              = $0DE1;
  GL_TEXTURE_3D                              = $806F; // GL 1.2
  GL_SELECTION_BUFFER_POINTER                = $0DF3;
  GL_SELECTION_BUFFER_SIZE                   = $0DF4;
  GL_POLYGON_OFFSET_UNITS                    = $2A00;
  GL_POLYGON_OFFSET_POINT                    = $2A01;
  GL_POLYGON_OFFSET_LINE                     = $2A02;
  GL_POLYGON_OFFSET_FILL                     = $8037;
  GL_POLYGON_OFFSET_FACTOR                   = $8038;
  GL_TEXTURE_BINDING_1D                      = $8068;
  GL_TEXTURE_BINDING_2D                      = $8069;
  GL_VERTEX_ARRAY                            = $8074;
  GL_NORMAL_ARRAY                            = $8075;
  GL_COLOR_ARRAY                             = $8076;
  GL_INDEX_ARRAY                             = $8077;
  GL_TEXTURE_COORD_ARRAY                     = $8078;
  GL_EDGE_FLAG_ARRAY                         = $8079;
  GL_VERTEX_ARRAY_SIZE                       = $807A;
  GL_VERTEX_ARRAY_TYPE                       = $807B;
  GL_VERTEX_ARRAY_STRIDE                     = $807C;
  GL_NORMAL_ARRAY_TYPE                       = $807E;
  GL_NORMAL_ARRAY_STRIDE                     = $807F;
  GL_COLOR_ARRAY_SIZE                        = $8081;
  GL_COLOR_ARRAY_TYPE                        = $8082;
  GL_COLOR_ARRAY_STRIDE                      = $8083;
  GL_INDEX_ARRAY_TYPE                        = $8085;
  GL_INDEX_ARRAY_STRIDE                      = $8086;
  GL_TEXTURE_COORD_ARRAY_SIZE                = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE                = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE              = $808A;
  GL_EDGE_FLAG_ARRAY_STRIDE                  = $808C;
  GL_COLOR_MATRIX                            = $80B1; // GL 1.2 ARB imaging
  GL_COLOR_MATRIX_STACK_DEPTH                = $80B2; // GL 1.2 ARB imaging
  GL_MAX_COLOR_MATRIX_STACK_DEPTH            = $80B3; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_RED_SCALE             = $80B4; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_GREEN_SCALE           = $80B5; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_BLUE_SCALE            = $80B6; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_ALPHA_SCALE           = $80B7; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_RED_BIAS              = $80B8; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_GREEN_BIAS            = $80B9; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_BLUE_BIAS             = $80BA; // GL 1.2 ARB imaging
  GL_POST_COLOR_MATRIX_ALPHA_BIAS            = $80BB; // GL 1.2 ARB imaging

  // evaluators
  GL_COEFF                                   = $0A00;
  GL_ORDER                                   = $0A01;
  GL_DOMAIN                                  = $0A02;
  
  // texture mapping
  GL_TEXTURE_WIDTH                           = $1000;
  GL_TEXTURE_HEIGHT                          = $1001;
  GL_TEXTURE_INTERNAL_FORMAT                 = $1003;
  GL_TEXTURE_COMPONENTS                      = $1003;
  GL_TEXTURE_BORDER_COLOR                    = $1004;
  GL_TEXTURE_BORDER                          = $1005;
  GL_TEXTURE_RED_SIZE                        = $805C;
  GL_TEXTURE_GREEN_SIZE                      = $805D;
  GL_TEXTURE_BLUE_SIZE                       = $805E;
  GL_TEXTURE_ALPHA_SIZE                      = $805F;
  GL_TEXTURE_LUMINANCE_SIZE                  = $8060;
  GL_TEXTURE_INTENSITY_SIZE                  = $8061;
  GL_TEXTURE_PRIORITY                        = $8066;
  GL_TEXTURE_RESIDENT                        = $8067;
  GL_BGR                                     = $80E0; // v 1.2
  GL_BGRA                                    = $80E1; // v 1.2
  GL_S                                       = $2000;
  GL_T                                       = $2001;
  GL_R                                       = $2002;
  GL_Q                                       = $2003;
  GL_MODULATE                                = $2100;
  GL_DECAL                                   = $2101;
  GL_TEXTURE_ENV_MODE                        = $2200;
  GL_TEXTURE_ENV_COLOR                       = $2201;
  GL_TEXTURE_ENV                             = $2300;
  GL_EYE_LINEAR                              = $2400;
  GL_OBJECT_LINEAR                           = $2401;
  GL_SPHERE_MAP                              = $2402;
  GL_TEXTURE_GEN_MODE                        = $2500;
  GL_OBJECT_PLANE                            = $2501;
  GL_EYE_PLANE                               = $2502;
  GL_NEAREST                                 = $2600;
  GL_LINEAR                                  = $2601;
  GL_NEAREST_MIPMAP_NEAREST                  = $2700;
  GL_LINEAR_MIPMAP_NEAREST                   = $2701;
  GL_NEAREST_MIPMAP_LINEAR                   = $2702;
  GL_LINEAR_MIPMAP_LINEAR                    = $2703;
  GL_TEXTURE_MAG_FILTER                      = $2800;
  GL_TEXTURE_MIN_FILTER                      = $2801;
  GL_TEXTURE_WRAP_R                          = $8072; // GL 1.2
  GL_TEXTURE_WRAP_S                          = $2802;
  GL_TEXTURE_WRAP_T                          = $2803;
  GL_CLAMP_TO_EDGE                           = $812F; // GL 1.2
  GL_TEXTURE_MIN_LOD                         = $813A; // GL 1.2
  GL_TEXTURE_MAX_LOD                         = $813B; // GL 1.2
  GL_TEXTURE_BASE_LEVEL                      = $813C; // GL 1.2
  GL_TEXTURE_MAX_LEVEL                       = $813D; // GL 1.2
  GL_TEXTURE_DEPTH                           = $8071; // GL 1.2
  GL_PROXY_TEXTURE_1D                        = $8063;
  GL_PROXY_TEXTURE_2D                        = $8064;
  GL_PROXY_TEXTURE_3D                        = $8070; // GL 1.2
  GL_CLAMP                                   = $2900;
  GL_REPEAT                                  = $2901;

  // hints
  GL_DONT_CARE                               = $1100;
  GL_FASTEST                                 = $1101;
  GL_NICEST                                  = $1102;

  // data types
  GL_BYTE                                    = $1400;
  GL_UNSIGNED_BYTE                           = $1401;
  GL_SHORT                                   = $1402;
  GL_UNSIGNED_SHORT                          = $1403;
  GL_INT                                     = $1404;
  GL_UNSIGNED_INT                            = $1405;
  GL_FLOAT                                   = $1406;
  GL_2_BYTES                                 = $1407;
  GL_3_BYTES                                 = $1408;
  GL_4_BYTES                                 = $1409;
  GL_DOUBLE                                  = $140A;
  GL_DOUBLE_EXT                              = $140A;

  // logic operations
  GL_CLEAR                                   = $1500;
  GL_AND                                     = $1501;
  GL_AND_REVERSE                             = $1502;
  GL_COPY                                    = $1503;
  GL_AND_INVERTED                            = $1504;
  GL_NOOP                                    = $1505;
  GL_XOR                                     = $1506;
  GL_OR                                      = $1507;
  GL_NOR                                     = $1508;
  GL_EQUIV                                   = $1509;
  GL_INVERT                                  = $150A;
  GL_OR_REVERSE                              = $150B;
  GL_COPY_INVERTED                           = $150C;
  GL_OR_INVERTED                             = $150D;
  GL_NAND                                    = $150E;
  GL_SET                                     = $150F;

  // PixelCopyType
  GL_COLOR                                   = $1800;
  GL_DEPTH                                   = $1801;
  GL_STENCIL                                 = $1802;

  // pixel formats
  GL_COLOR_INDEX                             = $1900;
  GL_STENCIL_INDEX                           = $1901;
  GL_DEPTH_COMPONENT                         = $1902;
  GL_RED                                     = $1903;
  GL_GREEN                                   = $1904;
  GL_BLUE                                    = $1905;
  GL_ALPHA                                   = $1906;
  GL_RGB                                     = $1907;
  GL_RGBA                                    = $1908;
  GL_LUMINANCE                               = $1909;
  GL_LUMINANCE_ALPHA                         = $190A;

  // pixel type
  GL_BITMAP                                  = $1A00;

  // rendering modes
  GL_RENDER                                  = $1C00;
  GL_FEEDBACK                                = $1C01;
  GL_SELECT                                  = $1C02;

  // implementation strings
  GL_VENDOR                                  = $1F00;
  GL_RENDERER                                = $1F01;
  GL_VERSION                                 = $1F02;
  GL_EXTENSIONS                              = $1F03;

  // pixel formats
  GL_R3_G3_B2                                = $2A10;
  GL_ALPHA4                                  = $803B;
  GL_ALPHA8                                  = $803C;
  GL_ALPHA12                                 = $803D;
  GL_ALPHA16                                 = $803E;
  GL_LUMINANCE4                              = $803F;
  GL_LUMINANCE8                              = $8040;
  GL_LUMINANCE12                             = $8041;
  GL_LUMINANCE16                             = $8042;
  GL_LUMINANCE4_ALPHA4                       = $8043;
  GL_LUMINANCE6_ALPHA2                       = $8044;
  GL_LUMINANCE8_ALPHA8                       = $8045;
  GL_LUMINANCE12_ALPHA4                      = $8046;
  GL_LUMINANCE12_ALPHA12                     = $8047;
  GL_LUMINANCE16_ALPHA16                     = $8048;
  GL_INTENSITY                               = $8049;
  GL_INTENSITY4                              = $804A;
  GL_INTENSITY8                              = $804B;
  GL_INTENSITY12                             = $804C;
  GL_INTENSITY16                             = $804D;
  GL_RGB4                                    = $804F;
  GL_RGB5                                    = $8050;
  GL_RGB8                                    = $8051;
  GL_RGB10                                   = $8052;
  GL_RGB12                                   = $8053;
  GL_RGB16                                   = $8054;
  GL_RGBA2                                   = $8055;
  GL_RGBA4                                   = $8056;
  GL_RGB5_A1                                 = $8057;
  GL_RGBA8                                   = $8058;
  GL_RGB10_A2                                = $8059;
  GL_RGBA12                                  = $805A;
  GL_RGBA16                                  = $805B;
  UNSIGNED_BYTE_3_3_2                        = $8032; // GL 1.2
  UNSIGNED_BYTE_2_3_3_REV                    = $8362; // GL 1.2
  UNSIGNED_SHORT_5_6_5                       = $8363; // GL 1.2
  UNSIGNED_SHORT_5_6_5_REV                   = $8364; // GL 1.2
  UNSIGNED_SHORT_4_4_4_4                     = $8033; // GL 1.2
  UNSIGNED_SHORT_4_4_4_4_REV                 = $8365; // GL 1.2
  UNSIGNED_SHORT_5_5_5_1                     = $8034; // GL 1.2
  UNSIGNED_SHORT_1_5_5_5_REV                 = $8366; // GL 1.2
  UNSIGNED_INT_8_8_8_8                       = $8035; // GL 1.2
  UNSIGNED_INT_8_8_8_8_REV                   = $8367; // GL 1.2
  UNSIGNED_INT_10_10_10_2                    = $8036; // GL 1.2
  UNSIGNED_INT_2_10_10_10_REV                = $8368; // GL 1.2

  // interleaved arrays formats
  GL_V2F                                     = $2A20;
  GL_V3F                                     = $2A21;
  GL_C4UB_V2F                                = $2A22;
  GL_C4UB_V3F                                = $2A23;
  GL_C3F_V3F                                 = $2A24;
  GL_N3F_V3F                                 = $2A25;
  GL_C4F_N3F_V3F                             = $2A26;
  GL_T2F_V3F                                 = $2A27;
  GL_T4F_V4F                                 = $2A28;
  GL_T2F_C4UB_V3F                            = $2A29;
  GL_T2F_C3F_V3F                             = $2A2A;
  GL_T2F_N3F_V3F                             = $2A2B;
  GL_T2F_C4F_N3F_V3F                         = $2A2C;
  GL_T4F_C4F_N3F_V4F                         = $2A2D;

  // clip planes
  GL_CLIP_PLANE0                             = $3000;
  GL_CLIP_PLANE1                             = $3001;
  GL_CLIP_PLANE2                             = $3002;
  GL_CLIP_PLANE3                             = $3003;
  GL_CLIP_PLANE4                             = $3004;
  GL_CLIP_PLANE5                             = $3005;

  // miscellaneous
  GL_DITHER                                  = $0BD0;
  
  // ----- extensions enumerants -----
  // EXT_abgr
  GL_ABGR_EXT                                = $8000;

  // EXT_packed_pixels
  GL_UNSIGNED_BYTE_3_3_2_EXT                 = $8032;
  GL_UNSIGNED_SHORT_4_4_4_4_EXT              = $8033;
  GL_UNSIGNED_SHORT_5_5_5_1_EXT              = $8034;
  GL_UNSIGNED_INT_8_8_8_8_EXT                = $8035;
  GL_UNSIGNED_INT_10_10_10_2_EXT             = $8036;

  // EXT_vertex_array
  GL_VERTEX_ARRAY_EXT                        = $8074;
  GL_NORMAL_ARRAY_EXT                        = $8075;
  GL_COLOR_ARRAY_EXT                         = $8076;
  GL_INDEX_ARRAY_EXT                         = $8077;
  GL_TEXTURE_COORD_ARRAY_EXT                 = $8078;
  GL_EDGE_FLAG_ARRAY_EXT                     = $8079;
  GL_VERTEX_ARRAY_SIZE_EXT                   = $807A;
  GL_VERTEX_ARRAY_TYPE_EXT                   = $807B;
  GL_VERTEX_ARRAY_STRIDE_EXT                 = $807C;
  GL_VERTEX_ARRAY_COUNT_EXT                  = $807D;
  GL_NORMAL_ARRAY_TYPE_EXT                   = $807E;
  GL_NORMAL_ARRAY_STRIDE_EXT                 = $807F;
  GL_NORMAL_ARRAY_COUNT_EXT                  = $8080;
  GL_COLOR_ARRAY_SIZE_EXT                    = $8081;
  GL_COLOR_ARRAY_TYPE_EXT                    = $8082;
  GL_COLOR_ARRAY_STRIDE_EXT                  = $8083;
  GL_COLOR_ARRAY_COUNT_EXT                   = $8084;
  GL_INDEX_ARRAY_TYPE_EXT                    = $8085;
  GL_INDEX_ARRAY_STRIDE_EXT                  = $8086;
  GL_INDEX_ARRAY_COUNT_EXT                   = $8087;
  GL_TEXTURE_COORD_ARRAY_SIZE_EXT            = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE_EXT            = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE_EXT          = $808A;
  GL_TEXTURE_COORD_ARRAY_COUNT_EXT           = $808B;
  GL_EDGE_FLAG_ARRAY_STRIDE_EXT              = $808C;
  GL_EDGE_FLAG_ARRAY_COUNT_EXT               = $808D;
  GL_VERTEX_ARRAY_POINTER_EXT                = $808E;
  GL_NORMAL_ARRAY_POINTER_EXT                = $808F;
  GL_COLOR_ARRAY_POINTER_EXT                 = $8090;
  GL_INDEX_ARRAY_POINTER_EXT                 = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER_EXT         = $8092;
  GL_EDGE_FLAG_ARRAY_POINTER_EXT             = $8093;

  // EXT_color_table
  GL_TABLE_TOO_LARGE_EXT                     = $8031;
  GL_COLOR_TABLE_EXT                         = $80D0;
  GL_POST_CONVOLUTION_COLOR_TABLE_EXT        = $80D1;
  GL_POST_COLOR_MATRIX_COLOR_TABLE_EXT       = $80D2;
  GL_PROXY_COLOR_TABLE_EXT                   = $80D3;
  GL_PROXY_POST_CONVOLUTION_COLOR_TABLE_EXT  = $80D4;
  GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE_EXT = $80D5;
  GL_COLOR_TABLE_SCALE_EXT                   = $80D6;
  GL_COLOR_TABLE_BIAS_EXT                    = $80D7;
  GL_COLOR_TABLE_FORMAT_EXT                  = $80D8;
  GL_COLOR_TABLE_WIDTH_EXT                   = $80D9;
  GL_COLOR_TABLE_RED_SIZE_EXT                = $80DA;
  GL_COLOR_TABLE_GREEN_SIZE_EXT              = $80DB;
  GL_COLOR_TABLE_BLUE_SIZE_EXT               = $80DC;
  GL_COLOR_TABLE_ALPHA_SIZE_EXT              = $80DD;
  GL_COLOR_TABLE_LUMINANCE_SIZE_EXT          = $80DE;
  GL_COLOR_TABLE_INTENSITY_SIZE_EXT          = $80DF;

  // EXT_bgra
  GL_BGR_EXT                                 = $80E0;
  GL_BGRA_EXT                                = $80E1;

  // EXT_paletted_texture
  GL_COLOR_INDEX1_EXT                        = $80E2;
  GL_COLOR_INDEX2_EXT                        = $80E3;
  GL_COLOR_INDEX4_EXT                        = $80E4;
  GL_COLOR_INDEX8_EXT                        = $80E5;
  GL_COLOR_INDEX12_EXT                       = $80E6;
  GL_COLOR_INDEX16_EXT                       = $80E7;

  // EXT_blend_color
  GL_CONSTANT_COLOR_EXT                      = $8001;
  GL_ONE_MINUS_CONSTANT_COLOR_EXT            = $8002;
  GL_CONSTANT_ALPHA_EXT                      = $8003;
  GL_ONE_MINUS_CONSTANT_ALPHA_EXT            = $8004;
  GL_BLEND_COLOR_EXT                         = $8005;

  // EXT_blend_minmax
  GL_FUNC_ADD_EXT                            = $8006;
  GL_MIN_EXT                                 = $8007;
  GL_MAX_EXT                                 = $8008;
  GL_BLEND_EQUATION_EXT                      = $8009;

  // EXT_blend_subtract
  GL_FUNC_SUBTRACT_EXT                       = $800A;
  GL_FUNC_REVERSE_SUBTRACT_EXT               = $800B;

  // EXT_convolution
  GL_CONVOLUTION_1D_EXT                      = $8010;
  GL_CONVOLUTION_2D_EXT                      = $8011;
  GL_SEPARABLE_2D_EXT                        = $8012;
  GL_CONVOLUTION_BORDER_MODE_EXT             = $8013;
  GL_CONVOLUTION_FILTER_SCALE_EXT            = $8014;
  GL_CONVOLUTION_FILTER_BIAS_EXT             = $8015;
  GL_REDUCE_EXT                              = $8016;
  GL_CONVOLUTION_FORMAT_EXT                  = $8017;
  GL_CONVOLUTION_WIDTH_EXT                   = $8018;
  GL_CONVOLUTION_HEIGHT_EXT                  = $8019;
  GL_MAX_CONVOLUTION_WIDTH_EXT               = $801A;
  GL_MAX_CONVOLUTION_HEIGHT_EXT              = $801B;
  GL_POST_CONVOLUTION_RED_SCALE_EXT          = $801C;
  GL_POST_CONVOLUTION_GREEN_SCALE_EXT        = $801D;
  GL_POST_CONVOLUTION_BLUE_SCALE_EXT         = $801E;
  GL_POST_CONVOLUTION_ALPHA_SCALE_EXT        = $801F;
  GL_POST_CONVOLUTION_RED_BIAS_EXT           = $8020;
  GL_POST_CONVOLUTION_GREEN_BIAS_EXT         = $8021;
  GL_POST_CONVOLUTION_BLUE_BIAS_EXT          = $8022;
  GL_POST_CONVOLUTION_ALPHA_BIAS_EXT         = $8023;

  // EXT_histogram
  GL_HISTOGRAM_EXT                           = $8024;
  GL_PROXY_HISTOGRAM_EXT                     = $8025;
  GL_HISTOGRAM_WIDTH_EXT                     = $8026;
  GL_HISTOGRAM_FORMAT_EXT                    = $8027;
  GL_HISTOGRAM_RED_SIZE_EXT                  = $8028;
  GL_HISTOGRAM_GREEN_SIZE_EXT                = $8029;
  GL_HISTOGRAM_BLUE_SIZE_EXT                 = $802A;
  GL_HISTOGRAM_ALPHA_SIZE_EXT                = $802B;
  GL_HISTOGRAM_LUMINANCE_SIZE_EXT            = $802C;
  GL_HISTOGRAM_SINK_EXT                      = $802D;
  GL_MINMAX_EXT                              = $802E;
  GL_MINMAX_FORMAT_EXT                       = $802F;
  GL_MINMAX_SINK_EXT                         = $8030;

  // EXT_polygon_offset
  GL_POLYGON_OFFSET_EXT                      = $8037;
  GL_POLYGON_OFFSET_FACTOR_EXT               = $8038;
  GL_POLYGON_OFFSET_BIAS_EXT                 = $8039;

  // EXT_texture
  GL_ALPHA4_EXT                              = $803B;
  GL_ALPHA8_EXT                              = $803C;
  GL_ALPHA12_EXT                             = $803D;
  GL_ALPHA16_EXT                             = $803E;
  GL_LUMINANCE4_EXT                          = $803F;
  GL_LUMINANCE8_EXT                          = $8040;
  GL_LUMINANCE12_EXT                         = $8041;
  GL_LUMINANCE16_EXT                         = $8042;
  GL_LUMINANCE4_ALPHA4_EXT                   = $8043;
  GL_LUMINANCE6_ALPHA2_EXT                   = $8044;
  GL_LUMINANCE8_ALPHA8_EXT                   = $8045;
  GL_LUMINANCE12_ALPHA4_EXT                  = $8046;
  GL_LUMINANCE12_ALPHA12_EXT                 = $8047;
  GL_LUMINANCE16_ALPHA16_EXT                 = $8048;
  GL_INTENSITY_EXT                           = $8049;
  GL_INTENSITY4_EXT                          = $804A;
  GL_INTENSITY8_EXT                          = $804B;
  GL_INTENSITY12_EXT                         = $804C;
  GL_INTENSITY16_EXT                         = $804D;
  GL_RGB2_EXT                                = $804E;
  GL_RGB4_EXT                                = $804F;
  GL_RGB5_EXT                                = $8050;
  GL_RGB8_EXT                                = $8051;
  GL_RGB10_EXT                               = $8052;
  GL_RGB12_EXT                               = $8053;
  GL_RGB16_EXT                               = $8054;
  GL_RGBA2_EXT                               = $8055;
  GL_RGBA4_EXT                               = $8056;
  GL_RGB5_A1_EXT                             = $8057;
  GL_RGBA8_EXT                               = $8058;
  GL_RGB10_A2_EXT                            = $8059;
  GL_RGBA12_EXT                              = $805A;
  GL_RGBA16_EXT                              = $805B;
  GL_TEXTURE_RED_SIZE_EXT                    = $805C;
  GL_TEXTURE_GREEN_SIZE_EXT                  = $805D;
  GL_TEXTURE_BLUE_SIZE_EXT                   = $805E;
  GL_TEXTURE_ALPHA_SIZE_EXT                  = $805F;
  GL_TEXTURE_LUMINANCE_SIZE_EXT              = $8060;
  GL_TEXTURE_INTENSITY_SIZE_EXT              = $8061;
  GL_REPLACE_EXT                             = $8062;
  GL_PROXY_TEXTURE_1D_EXT                    = $8063;
  GL_PROXY_TEXTURE_2D_EXT                    = $8064;
  GL_TEXTURE_TOO_LARGE_EXT                   = $8065;

  // EXT_texture_object 
  GL_TEXTURE_PRIORITY_EXT                    = $8066;
  GL_TEXTURE_RESIDENT_EXT                    = $8067;
  GL_TEXTURE_1D_BINDING_EXT                  = $8068;
  GL_TEXTURE_2D_BINDING_EXT                  = $8069;
  GL_TEXTURE_3D_BINDING_EXT                  = $806A;

  // EXT_texture3D
  GL_PACK_SKIP_IMAGES_EXT                    = $806B;
  GL_PACK_IMAGE_HEIGHT_EXT                   = $806C;
  GL_UNPACK_SKIP_IMAGES_EXT                  = $806D;
  GL_UNPACK_IMAGE_HEIGHT_EXT                 = $806E;
  GL_TEXTURE_3D_EXT                          = $806F;
  GL_PROXY_TEXTURE_3D_EXT                    = $8070;
  GL_TEXTURE_DEPTH_EXT                       = $8071;
  GL_TEXTURE_WRAP_R_EXT                      = $8072;
  GL_MAX_3D_TEXTURE_SIZE_EXT                 = $8073;

  // SGI_color_matrix
  GL_COLOR_MATRIX_SGI                        = $80B1;
  GL_COLOR_MATRIX_STACK_DEPTH_SGI            = $80B2;
  GL_MAX_COLOR_MATRIX_STACK_DEPTH_SGI        = $80B3;
  GL_POST_COLOR_MATRIX_RED_SCALE_SGI         = $80B4;
  GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI       = $80B5;
  GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI        = $80B6;
  GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI       = $80B7;
  GL_POST_COLOR_MATRIX_RED_BIAS_SGI          = $80B8;
  GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI        = $80B9;
  GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI         = $80BA;
  GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI        = $80BB;

  // SGI_texture_color_table
  GL_TEXTURE_COLOR_TABLE_SGI                 = $80BC;
  GL_PROXY_TEXTURE_COLOR_TABLE_SGI           = $80BD;
  GL_TEXTURE_COLOR_TABLE_BIAS_SGI            = $80BE;
  GL_TEXTURE_COLOR_TABLE_SCALE_SGI           = $80BF;

  // SGI_color_table
  GL_COLOR_TABLE_SGI                         = $80D0;
  GL_POST_CONVOLUTION_COLOR_TABLE_SGI        = $80D1;
  GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI       = $80D2;
  GL_PROXY_COLOR_TABLE_SGI                   = $80D3;
  GL_PROXY_POST_CONVOLUTION_COLOR_TABLE_SGI  = $80D4;
  GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE_SGI = $80D5;
  GL_COLOR_TABLE_SCALE_SGI                   = $80D6;
  GL_COLOR_TABLE_BIAS_SGI                    = $80D7;
  GL_COLOR_TABLE_FORMAT_SGI                  = $80D8;
  GL_COLOR_TABLE_WIDTH_SGI                   = $80D9;
  GL_COLOR_TABLE_RED_SIZE_SGI                = $80DA;
  GL_COLOR_TABLE_GREEN_SIZE_SGI              = $80DB;
  GL_COLOR_TABLE_BLUE_SIZE_SGI               = $80DC;
  GL_COLOR_TABLE_ALPHA_SIZE_SGI              = $80DD;
  GL_COLOR_TABLE_LUMINANCE_SIZE_SGI          = $80DE;
  GL_COLOR_TABLE_INTENSITY_SIZE_SGI          = $80DF;

  // EXT_cmyka
  GL_CMYK_EXT                                = $800C;
  GL_CMYKA_EXT                               = $800D;
  GL_PACK_CMYK_HINT_EXT                      = $800E;
  GL_UNPACK_CMYK_HINT_EXT                    = $800F;

  // EXT_rescale_normal
  GL_RESCALE_NORMAL_EXT                      = $803A;

  // EXT_clip_volume_hint
  GL_CLIP_VOLUME_CLIPPING_HINT_EXT	     = $80F0;

  // EXT_cull_vertex
  GL_CULL_VERTEX_EXT                         = $81AA; 
  GL_CULL_VERTEX_EYE_POSITION_EXT            = $81AB;
  GL_CULL_VERTEX_OBJECT_POSITION_EXT         = $81AC;

  // EXT_index_array_formats
  GL_IUI_V2F_EXT                             = $81AD;
  GL_IUI_V3F_EXT                             = $81AE;
  GL_IUI_N3F_V2F_EXT                         = $81AF;
  GL_IUI_N3F_V3F_EXT                         = $81B0;
  GL_T2F_IUI_V2F_EXT                         = $81B1;
  GL_T2F_IUI_V3F_EXT                         = $81B2;
  GL_T2F_IUI_N3F_V2F_EXT                     = $81B3;
  GL_T2F_IUI_N3F_V3F_EXT                     = $81B4;

  // EXT_index_func
  GL_INDEX_TEST_EXT                          = $81B5;
  GL_INDEX_TEST_FUNC_EXT                     = $81B6;
  GL_INDEX_TEST_REF_EXT                      = $81B7;

  // EXT_index_material
  GL_INDEX_MATERIAL_EXT                      = $81B8;
  GL_INDEX_MATERIAL_PARAMETER_EXT            = $81B9;
  GL_INDEX_MATERIAL_FACE_EXT                 = $81BA;

  // EXT_misc_attribute
  GL_MISC_BIT_EXT                            = 0; // not yet defined

  // EXT_scene_marker
  GL_SCENE_REQUIRED_EXT                      = 0; // not yet defined

  // EXT_shared_texture_palette
  GL_SHARED_TEXTURE_PALETTE_EXT              = $81FB;

  // EXT_nurbs_tessellator
  GLU_NURBS_MODE_EXT                         = 100160;
  GLU_NURBS_TESSELLATOR_EXT                  = 100161;
  GLU_NURBS_RENDERER_EXT                     = 100162;
  GLU_NURBS_BEGIN_EXT                        = 100164;
  GLU_NURBS_VERTEX_EXT                       = 100165;
  GLU_NURBS_NORMAL_EXT                       = 100166;
  GLU_NURBS_COLOR_EXT                        = 100167;
  GLU_NURBS_TEX_COORD_EXT                    = 100168;
  GLU_NURBS_END_EXT                          = 100169;
  GLU_NURBS_BEGIN_DATA_EXT                   = 100170;
  GLU_NURBS_VERTEX_DATA_EXT                  = 100171;
  GLU_NURBS_NORMAL_DATA_EXT                  = 100172;
  GLU_NURBS_COLOR_DATA_EXT                   = 100173;
  GLU_NURBS_TEX_COORD_DATA_EXT               = 100174;
  GLU_NURBS_END_DATA_EXT                     = 100175;

  // EXT_object_space_tess
  GLU_OBJECT_PARAMETRIC_ERROR_EXT            = 100208;
  GLU_OBJECT_PATH_LENGTH_EXT                 = 100209;

  // EXT_point_parameters
  GL_POINT_SIZE_MIN_EXT                      = $8126;
  GL_POINT_SIZE_MAX_EXT                      = $8127;
  GL_POINT_FADE_THRESHOLD_SIZE_EXT           = $8128;
  GL_DISTANCE_ATTENUATION_EXT                = $8129;

  // EXT_compiled_vertex_array
  GL_ARRAY_ELEMENT_LOCK_FIRST_EXT            = $81A8;
  GL_ARRAY_ELEMENT_LOCK_COUNT_EXT            = $81A9;

  // ARB_multitexture
  GL_ACTIVE_TEXTURE_ARB                      = $84E0;
  GL_CLIENT_ACTIVE_TEXTURE_ARB               = $84E1;
  GL_MAX_TEXTURE_UNITS_ARB                   = $84E2;
  GL_TEXTURE0_ARB                            = $84C0;
  GL_TEXTURE1_ARB                            = $84C1;
  GL_TEXTURE2_ARB                            = $84C2;
  GL_TEXTURE3_ARB                            = $84C3;
  GL_TEXTURE4_ARB                            = $84C4;
  GL_TEXTURE5_ARB                            = $84C5;
  GL_TEXTURE6_ARB                            = $84C6;
  GL_TEXTURE7_ARB                            = $84C7;
  GL_TEXTURE8_ARB                            = $84C8;
  GL_TEXTURE9_ARB                            = $84C9;
  GL_TEXTURE10_ARB                           = $84CA;
  GL_TEXTURE11_ARB                           = $84CB;
  GL_TEXTURE12_ARB                           = $84CC;
  GL_TEXTURE13_ARB                           = $84CD;
  GL_TEXTURE14_ARB                           = $84CE;
  GL_TEXTURE15_ARB                           = $84CF;
  GL_TEXTURE16_ARB                           = $84D0;
  GL_TEXTURE17_ARB                           = $84D1;
  GL_TEXTURE18_ARB                           = $84D2;
  GL_TEXTURE19_ARB                           = $84D3;
  GL_TEXTURE20_ARB                           = $84D4;
  GL_TEXTURE21_ARB                           = $84D5;
  GL_TEXTURE22_ARB                           = $84D6;
  GL_TEXTURE23_ARB                           = $84D7;
  GL_TEXTURE24_ARB                           = $84D8;
  GL_TEXTURE25_ARB                           = $84D9;
  GL_TEXTURE26_ARB                           = $84DA;
  GL_TEXTURE27_ARB                           = $84DB;
  GL_TEXTURE28_ARB                           = $84DC;
  GL_TEXTURE29_ARB                           = $84DD;
  GL_TEXTURE30_ARB                           = $84DE;
  GL_TEXTURE31_ARB                           = $84DF;

  // EXT_stencil_wrap
  GL_INCR_WRAP_EXT                           = $8507;
  GL_DECR_WRAP_EXT                           = $8508;

  // NV_texgen_reflection
  GL_NORMAL_MAP_NV                           = $8511;
  GL_REFLECTION_MAP_NV                       = $8512;

  // EXT_texture_env_combine
  GL_COMBINE_EXT                             = $8570;
  GL_COMBINE_RGB_EXT                         = $8571;
  GL_COMBINE_ALPHA_EXT                       = $8572;
  GL_RGB_SCALE_EXT                           = $8573;
  GL_ADD_SIGNED_EXT                          = $8574;
  GL_INTERPOLATE_EXT                         = $8575;
  GL_CONSTANT_EXT                            = $8576;
  GL_PRIMARY_COLOR_EXT                       = $8577;
  GL_PREVIOUS_EXT                            = $8578;
  GL_SOURCE0_RGB_EXT                         = $8580;
  GL_SOURCE1_RGB_EXT                         = $8581;
  GL_SOURCE2_RGB_EXT                         = $8582;
  GL_SOURCE0_ALPHA_EXT                       = $8588;
  GL_SOURCE1_ALPHA_EXT                       = $8589;
  GL_SOURCE2_ALPHA_EXT                       = $858A;
  GL_OPERAND0_RGB_EXT                        = $8590;
  GL_OPERAND1_RGB_EXT                        = $8591;
  GL_OPERAND2_RGB_EXT                        = $8592;
  GL_OPERAND0_ALPHA_EXT                      = $8598;
  GL_OPERAND1_ALPHA_EXT                      = $8599;
  GL_OPERAND2_ALPHA_EXT                      = $859A;

  // NV_texture_env_combine4
  GL_COMBINE4_NV                             = $8503;
  GL_SOURCE3_RGB_NV                          = $8583;
  GL_SOURCE3_ALPHA_NV                        = $858B;
  GL_OPERAND3_RGB_NV                         = $8593;
  GL_OPERAND3_ALPHA_NV                       = $859B;
  
const
  // ********** GLU generic constants **********

  // Errors: (return value 0 = no error)
  GLU_INVALID_ENUM                           = 100900;
  GLU_INVALID_VALUE                          = 100901;
  GLU_OUT_OF_MEMORY                          = 100902;
  GLU_INCOMPATIBLE_GL_VERSION                = 100903;

  // StringName
  GLU_VERSION                                = 100800;
  GLU_EXTENSIONS                             = 100801;

  // Boolean
  GLU_TRUE                                   = GL_TRUE;
  GLU_FALSE                                  = GL_FALSE;

  // Quadric constants
  // QuadricNormal
  GLU_SMOOTH                                 = 100000;
  GLU_FLAT                                   = 100001;
  GLU_NONE                                   = 100002;

  // QuadricDrawStyle
  GLU_POINT                                  = 100010;
  GLU_LINE                                   = 100011;
  GLU_FILL                                   = 100012;
  GLU_SILHOUETTE                             = 100013;

  // QuadricOrientation
  GLU_OUTSIDE                                = 100020;
  GLU_INSIDE                                 = 100021;

  // Tesselation constants
  GLU_TESS_MAX_COORD                         = 1.0e150;

  // TessProperty
  GLU_TESS_WINDING_RULE                      = 100140;
  GLU_TESS_BOUNDARY_ONLY                     = 100141;
  GLU_TESS_TOLERANCE                         = 100142;

  // TessWinding
  GLU_TESS_WINDING_ODD                       = 100130;
  GLU_TESS_WINDING_NONZERO                   = 100131;
  GLU_TESS_WINDING_POSITIVE                  = 100132;
  GLU_TESS_WINDING_NEGATIVE                  = 100133;
  GLU_TESS_WINDING_ABS_GEQ_TWO               = 100134;

  // TessCallback
  GLU_TESS_BEGIN                             = 100100; // TGLUTessBeginProc
  GLU_TESS_VERTEX                            = 100101; // TGLUTessVertexProc
  GLU_TESS_END                               = 100102; // TGLUTessEndProc
  GLU_TESS_ERROR                             = 100103; // TGLUTessErrorProc
  GLU_TESS_EDGE_FLAG                         = 100104; // TGLUTessEdgeFlagProc
  GLU_TESS_COMBINE                           = 100105; // TGLUTessCombineProc
  GLU_TESS_BEGIN_DATA                        = 100106; // TGLUTessBeginDataProc
  GLU_TESS_VERTEX_DATA                       = 100107; // TGLUTessVertexDataProc
  GLU_TESS_END_DATA                          = 100108; // TGLUTessEndDataProc
  GLU_TESS_ERROR_DATA                        = 100109; // TGLUTessErrorDataProc
  GLU_TESS_EDGE_FLAG_DATA                    = 100110; // TGLUTessEdgeFlagDataProc
  GLU_TESS_COMBINE_DATA                      = 100111; // TGLUTessCombineDataProc

  // TessError
  GLU_TESS_ERROR1                            = 100151;
  GLU_TESS_ERROR2                            = 100152;
  GLU_TESS_ERROR3                            = 100153;
  GLU_TESS_ERROR4                            = 100154;
  GLU_TESS_ERROR5                            = 100155;
  GLU_TESS_ERROR6                            = 100156;
  GLU_TESS_ERROR7                            = 100157;
  GLU_TESS_ERROR8                            = 100158;

  GLU_TESS_MISSING_BEGIN_POLYGON             = GLU_TESS_ERROR1;
  GLU_TESS_MISSING_BEGIN_CONTOUR             = GLU_TESS_ERROR2;
  GLU_TESS_MISSING_END_POLYGON               = GLU_TESS_ERROR3;
  GLU_TESS_MISSING_END_CONTOUR               = GLU_TESS_ERROR4;
  GLU_TESS_COORD_TOO_LARGE                   = GLU_TESS_ERROR5;
  GLU_TESS_NEED_COMBINE_CALLBACK             = GLU_TESS_ERROR6;

  // NURBS constants

  // NurbsProperty
  GLU_AUTO_LOAD_MATRIX                       = 100200;
  GLU_CULLING                                = 100201;
  GLU_SAMPLING_TOLERANCE                     = 100203;
  GLU_DISPLAY_MODE                           = 100204;
  GLU_PARAMETRIC_TOLERANCE                   = 100202;
  GLU_SAMPLING_METHOD                        = 100205;
  GLU_U_STEP                                 = 100206;
  GLU_V_STEP                                 = 100207;

  // NurbsSampling
  GLU_PATH_LENGTH                            = 100215;
  GLU_PARAMETRIC_ERROR                       = 100216;
  GLU_DOMAIN_DISTANCE                        = 100217;

  // NurbsTrim
  GLU_MAP1_TRIM_2                            = 100210;
  GLU_MAP1_TRIM_3                            = 100211;

  // NurbsDisplay
  GLU_OUTLINE_POLYGON                        = 100240;
  GLU_OUTLINE_PATCH                          = 100241;

  // NurbsErrors
  GLU_NURBS_ERROR1                           = 100251;
  GLU_NURBS_ERROR2                           = 100252;
  GLU_NURBS_ERROR3                           = 100253;
  GLU_NURBS_ERROR4                           = 100254;
  GLU_NURBS_ERROR5                           = 100255;
  GLU_NURBS_ERROR6                           = 100256;
  GLU_NURBS_ERROR7                           = 100257;
  GLU_NURBS_ERROR8                           = 100258;
  GLU_NURBS_ERROR9                           = 100259;
  GLU_NURBS_ERROR10                          = 100260;
  GLU_NURBS_ERROR11                          = 100261;
  GLU_NURBS_ERROR12                          = 100262;
  GLU_NURBS_ERROR13                          = 100263;
  GLU_NURBS_ERROR14                          = 100264;
  GLU_NURBS_ERROR15                          = 100265;
  GLU_NURBS_ERROR16                          = 100266;
  GLU_NURBS_ERROR17                          = 100267;
  GLU_NURBS_ERROR18                          = 100268;
  GLU_NURBS_ERROR19                          = 100269;
  GLU_NURBS_ERROR20                          = 100270;
  GLU_NURBS_ERROR21                          = 100271;
  GLU_NURBS_ERROR22                          = 100272;
  GLU_NURBS_ERROR23                          = 100273;
  GLU_NURBS_ERROR24                          = 100274;
  GLU_NURBS_ERROR25                          = 100275;
  GLU_NURBS_ERROR26                          = 100276;
  GLU_NURBS_ERROR27                          = 100277;
  GLU_NURBS_ERROR28                          = 100278;
  GLU_NURBS_ERROR29                          = 100279;
  GLU_NURBS_ERROR30                          = 100280;
  GLU_NURBS_ERROR31                          = 100281;
  GLU_NURBS_ERROR32                          = 100282;
  GLU_NURBS_ERROR33                          = 100283;
  GLU_NURBS_ERROR34                          = 100284;
  GLU_NURBS_ERROR35                          = 100285;
  GLU_NURBS_ERROR36                          = 100286;
  GLU_NURBS_ERROR37                          = 100287;

  // Contours types -- obsolete!
  GLU_CW                                     = 100120;
  GLU_CCW                                    = 100121;
  GLU_INTERIOR                               = 100122;
  GLU_EXTERIOR                               = 100123;
  GLU_UNKNOWN                                = 100124;

  // Names without "TESS_" prefix
  GLU_BEGIN                                  = GLU_TESS_BEGIN;
  GLU_VERTEX                                 = GLU_TESS_VERTEX;
  GLU_END                                    = GLU_TESS_END;
  GLU_ERROR                                  = GLU_TESS_ERROR;
  GLU_EDGE_FLAG                              = GLU_TESS_EDGE_FLAG;

type
  // GLU types
  TGLUNurbs = record end;
  TGLUQuadric = record end;
  TGLUTesselator = record end;

  PGLUNurbs = ^TGLUNurbs;
  PGLUQuadric = ^TGLUQuadric;
  PGLUTesselator = ^TGLUTesselator;

  // backwards compatibility
  TGLUNurbsObj = TGLUNurbs;
  TGLUQuadricObj = TGLUQuadric;
  TGLUTesselatorObj = TGLUTesselator;
  TGLUTriangulatorObj = TGLUTesselator;

  PGLUNurbsObj = PGLUNurbs;
  PGLUQuadricObj = PGLUQuadric;
  PGLUTesselatorObj = PGLUTesselator;
  PGLUTriangulatorObj = PGLUTesselator;

  // Callback function prototypes
  // GLUQuadricCallback
  TGLUQuadricErrorProc = procedure(errorCode: TGLEnum); stdcall;

  // GLUTessCallback
  TGLUTessBeginProc = procedure(AType: TGLEnum); stdcall;
  TGLUTessEdgeFlagProc = procedure(Flag: TGLboolean); stdcall;
  TGLUTessVertexProc = procedure(VertexData: Pointer); stdcall;
  TGLUTessEndProc = procedure; stdcall;
  TGLUTessErrorProc = procedure(ErrNo: TGLEnum); stdcall;
  TGLUTessCombineProc = procedure(Coords: TVector3d; VertexData: TVector4p; Weight: TVector4f;
    OutData: PPointer); stdcall;
  TGLUTessBeginDataProc = procedure(AType: TGLEnum; UserData: Pointer); stdcall;
  TGLUTessEdgeFlagDataProc = procedure(Flag: TGLboolean; UserData: Pointer); stdcall;
  TGLUTessVertexDataProc = procedure(VertexData: Pointer; UserData: Pointer); stdcall;
  TGLUTessEndDataProc = procedure(UserData: Pointer); stdcall;
  TGLUTessErrorDataProc = procedure(ErrNo: TGLEnum; UserData: Pointer); stdcall;
  TGLUTessCombineDataProc = procedure(Coords: TVector3d; VertexData: TVector4p; Weight: TVector4f; OutData: PPointer;
    UserData: Pointer); stdcall;

  // GLUNurbsCallback
  TGLUNurbsErrorProc = procedure(ErrorCode: TGLEnum); stdcall;

var
  // GL functions and procedures
  glAccum: procedure(op: TGLuint; value: TGLfloat); stdcall;
  glAlphaFunc: procedure(func: TGLEnum; ref: TGLclampf); stdcall;
  glAreTexturesResident: function(n: TGLsizei; Textures: PGLuint; residences: PGLboolean): TGLboolean; stdcall;
  glArrayElement: procedure(i: TGLint); stdcall;
  glBegin: procedure(mode: TGLEnum); stdcall;
  glBindTexture: procedure(target: TGLEnum; texture: TGLuint); stdcall;
  glBitmap: procedure(width: TGLsizei; height: TGLsizei; xorig, yorig: TGLfloat; xmove: TGLfloat; ymove: TGLfloat;
    bitmap: Pointer); stdcall;
  glBlendFunc: procedure(sfactor: TGLEnum; dfactor: TGLEnum); stdcall;
  glCallList: procedure(list: TGLuint); stdcall;
  glCallLists: procedure(n: TGLsizei; atype: TGLEnum; lists: Pointer); stdcall;
  glClear: procedure(mask: TGLbitfield); stdcall;
  glClearAccum: procedure(red, green, blue, alpha: TGLfloat); stdcall;
  glClearColor: procedure(red, green, blue, alpha: TGLclampf); stdcall;
  glClearDepth: procedure(depth: TGLclampd); stdcall;
  glClearIndex: procedure(c: TGLfloat); stdcall;
  glClearStencil: procedure(s: TGLint ); stdcall;
  glClipPlane: procedure(plane: TGLEnum; equation: PGLdouble); stdcall;
  glColor3b: procedure(red, green, blue: TGLbyte); stdcall;
  glColor3bv: procedure(v: PGLbyte); stdcall;
  glColor3d: procedure(red, green, blue: TGLdouble); stdcall;
  glColor3dv: procedure(v: PGLdouble); stdcall;
  glColor3f: procedure(red, green, blue: TGLfloat); stdcall;
  glColor3fv: procedure(v: PGLfloat); stdcall;
  glColor3i: procedure(red, green, blue: TGLint); stdcall;
  glColor3iv: procedure(v: PGLint); stdcall;
  glColor3s: procedure(red, green, blue: TGLshort); stdcall;
  glColor3sv: procedure(v: PGLshort); stdcall;
  glColor3ub: procedure(red, green, blue: TGLubyte); stdcall;
  glColor3ubv: procedure(v: PGLubyte); stdcall;
  glColor3ui: procedure(red, green, blue: TGLuint); stdcall;
  glColor3uiv: procedure(v: PGLuint); stdcall;
  glColor3us: procedure(red, green, blue: TGLushort); stdcall;
  glColor3usv: procedure(v: PGLushort); stdcall;
  glColor4b: procedure(red, green, blue, alpha: TGLbyte); stdcall;
  glColor4bv: procedure(v: PGLbyte); stdcall;
  glColor4d: procedure(red, green, blue, alpha: TGLdouble ); stdcall;
  glColor4dv: procedure(v: PGLdouble); stdcall;
  glColor4f: procedure(red, green, blue, alpha: TGLfloat); stdcall;
  glColor4fv: procedure(v: PGLfloat); stdcall;
  glColor4i: procedure(red, green, blue, alpha: TGLint); stdcall;
  glColor4iv: procedure(v: PGLint); stdcall;
  glColor4s: procedure(red, green, blue, alpha: TGLshort); stdcall;
  glColor4sv: procedure(v: TGLshort); stdcall;
  glColor4ub: procedure(red, green, blue, alpha: TGLubyte); stdcall;
  glColor4ubv: procedure(v: PGLubyte); stdcall;
  glColor4ui: procedure(red, green, blue, alpha: TGLuint); stdcall;
  glColor4uiv: procedure(v: PGLuint); stdcall;
  glColor4us: procedure(red, green, blue, alpha: TGLushort); stdcall;
  glColor4usv: procedure(v: PGLushort); stdcall;
  glColorMask: procedure(red, green, blue, alpha: TGLboolean); stdcall;
  glColorMaterial: procedure(face: TGLEnum; mode: TGLEnum); stdcall;
  glColorPointer: procedure(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glCopyPixels: procedure(x, y: TGLint; width, height: TGLsizei; atype: TGLEnum); stdcall;
  glCopyTexImage1D: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width: TGLsizei;
    border: TGLint); stdcall;
  glCopyTexImage2D: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width,
    height: TGLsizei; border: TGLint); stdcall;
  glCopyTexSubImage1D: procedure(target: TGLEnum; level, xoffset, x, y: TGLint; width: TGLsizei); stdcall;
  glCopyTexSubImage2D: procedure(target: TGLEnum; level, xoffset, yoffset, x, y: TGLint; width,
    height: TGLsizei); stdcall;
  glCullFace: procedure(mode: TGLEnum); stdcall;
  glDeleteLists: procedure(list: TGLuint; range: TGLsizei); stdcall;
  glDeleteTextures: procedure(n: TGLsizei; textures: PGLuint); stdcall;
  glDepthFunc: procedure(func: TGLEnum); stdcall;
  glDepthMask: procedure(flag: TGLboolean); stdcall;
  glDepthRange: procedure(zNear, zFar: TGLclampd); stdcall;
  glDisable: procedure(cap: TGLEnum); stdcall;
  glDisableClientState: procedure(aarray: TGLEnum); stdcall;
  glDrawArrays: procedure(mode: TGLEnum; first: TGLint; count: TGLsizei); stdcall;
  glDrawBuffer: procedure(mode: TGLEnum); stdcall;
  glDrawElements: procedure(mode: TGLEnum; count: TGLsizei; atype: TGLEnum; indices: Pointer); stdcall;
  glDrawPixels: procedure(width, height: TGLsizei; format, atype: TGLEnum; pixels: Pointer); stdcall;
  glEdgeFlag: procedure(flag: TGLboolean); stdcall;
  glEdgeFlagPointer: procedure(stride: TGLsizei; data: pointer); stdcall;
  glEdgeFlagv: procedure(flag: PGLboolean); stdcall;
  glEnable: procedure(cap: TGLEnum); stdcall;
  glEnableClientState: procedure(aarray: TGLEnum); stdcall;
  glEnd: procedure; stdcall;
  glEndList: procedure; stdcall;
  glEvalCoord1d: procedure(u: TGLdouble); stdcall;
  glEvalCoord1dv: procedure(u: PGLdouble); stdcall;
  glEvalCoord1f: procedure(u: TGLfloat); stdcall;
  glEvalCoord1fv: procedure(u: PGLfloat); stdcall;
  glEvalCoord2d: procedure(u: TGLdouble; v: TGLdouble); stdcall;
  glEvalCoord2dv: procedure(u: PGLdouble); stdcall;
  glEvalCoord2f: procedure(u, v: TGLfloat); stdcall;
  glEvalCoord2fv: procedure(u: PGLfloat); stdcall;
  glEvalMesh1: procedure(mode: TGLEnum; i1, i2: TGLint); stdcall;
  glEvalMesh2: procedure(mode: TGLEnum; i1, i2, j1, j2: TGLint); stdcall;
  glEvalPoint1: procedure(i: TGLint); stdcall;
  glEvalPoint2: procedure(i, j: TGLint); stdcall;
  glFeedbackBuffer: procedure(size: TGLsizei; atype: TGLEnum; buffer: PGLfloat); stdcall;
  glFinish: procedure; stdcall;
  glFlush: procedure; stdcall;
  glFogf: procedure(pname: TGLEnum; param: TGLfloat); stdcall;
  glFogfv: procedure(pname: TGLEnum; params: PGLfloat); stdcall;
  glFogi: procedure(pname: TGLEnum; param: TGLint); stdcall;
  glFogiv: procedure(pname: TGLEnum; params: PGLint); stdcall;
  glFrontFace: procedure(mode: TGLEnum); stdcall;
  glFrustum: procedure(left, right, bottom, top, zNear, zFar: TGLdouble); stdcall;
  glGenLists: function(range: TGLsizei): TGLuint; stdcall;
  glGenTextures: procedure(n: TGLsizei; textures: PGLuint); stdcall;
  glGetBooleanv: procedure(pname: TGLEnum; params: PGLboolean); stdcall;
  glGetClipPlane: procedure(plane: TGLEnum; equation: PGLdouble); stdcall;
  glGetDoublev: procedure(pname: TGLEnum; params: PGLdouble); stdcall;
  glGetError: function : TGLuint; stdcall;
  glGetFloatv: procedure(pname: TGLEnum; params: PGLfloat); stdcall;
  glGetIntegerv: procedure(pname: TGLEnum; params: PGLint); stdcall;
  glGetLightfv: procedure(light, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetLightiv: procedure(light, pname: TGLEnum; params: PGLint); stdcall;
  glGetMapdv: procedure(target, query: TGLEnum; v: PGLdouble); stdcall;
  glGetMapfv: procedure(target, query: TGLEnum; v: PGLfloat); stdcall;
  glGetMapiv: procedure(target, query: TGLEnum; v: PGLint); stdcall;
  glGetMaterialfv: procedure(face, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetMaterialiv: procedure(face, pname: TGLEnum; params: PGLint); stdcall;
  glGetPixelMapfv: procedure(map: TGLEnum; values: PGLfloat); stdcall;
  glGetPixelMapuiv: procedure(map: TGLEnum; values: PGLuint); stdcall;
  glGetPixelMapusv: procedure(map: TGLEnum; values: PGLushort); stdcall;
  glGetPointerv: procedure(pname: TGLEnum; var params); stdcall;
  glGetPolygonStipple: procedure(mask: PGLubyte); stdcall;
  glGetString: function(name: TGLEnum): PChar; stdcall;
  glGetTexEnvfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetTexEnviv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glGetTexGendv: procedure(coord, pname: TGLEnum; params: PGLdouble); stdcall;
  glGetTexGenfv: procedure(coord, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetTexGeniv: procedure(coord, pname: TGLEnum; params: PGLint); stdcall;
  glGetTexImage: procedure(target: TGLEnum; level: TGLint; format, atype: TGLEnum; pixels: Pointer); stdcall;
  glGetTexLevelParameterfv: procedure(target: TGLEnum; level: TGLint; pname: TGLEnum; params: PGLfloat); stdcall;
  glGetTexLevelParameteriv: procedure(target: TGLEnum; level: TGLint; pname: TGLEnum; params: PGLint); stdcall;
  glGetTexParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetTexParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glHint: procedure(target, mode: TGLEnum); stdcall;
  glIndexMask: procedure(mask: TGLuint); stdcall;
  glIndexPointer: procedure(atype: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glIndexd: procedure(c: TGLdouble); stdcall;
  glIndexdv: procedure(c: PGLdouble); stdcall;
  glIndexf: procedure(c: TGLfloat); stdcall;
  glIndexfv: procedure(c: PGLfloat); stdcall;
  glIndexi: procedure(c: TGLint); stdcall;
  glIndexiv: procedure(c: PGLint); stdcall;
  glIndexs: procedure(c: TGLshort); stdcall;
  glIndexsv: procedure(c: PGLshort); stdcall;
  glIndexub: procedure(c: TGLubyte); stdcall;
  glIndexubv: procedure(c: PGLubyte); stdcall;
  glInitNames: procedure; stdcall;
  glInterleavedArrays: procedure(format: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glIsEnabled: function(cap: TGLEnum): TGLboolean; stdcall;
  glIsList: function(list: TGLuint): TGLboolean; stdcall;
  glIsTexture: function(texture: TGLuint): TGLboolean; stdcall;
  glLightModelf: procedure(pname: TGLEnum; param: TGLfloat); stdcall;
  glLightModelfv: procedure(pname: TGLEnum; params: PGLfloat); stdcall;
  glLightModeli: procedure(pname: TGLEnum; param: TGLint); stdcall;
  glLightModeliv: procedure(pname: TGLEnum; params: PGLint); stdcall;
  glLightf: procedure(light, pname: TGLEnum; param: TGLfloat); stdcall;
  glLightfv: procedure(light, pname: TGLEnum; params: PGLfloat); stdcall;
  glLighti: procedure(light, pname: TGLEnum; param: TGLint); stdcall;
  glLightiv: procedure(light, pname: TGLEnum; params: PGLint); stdcall;
  glLineStipple: procedure(factor: TGLint; pattern: TGLushort); stdcall;
  glLineWidth: procedure(width: TGLfloat); stdcall;
  glListBase: procedure(base: TGLuint); stdcall;
  glLoadIdentity: procedure; stdcall;
  glLoadMatrixd: procedure(m: PGLdouble); stdcall;
  glLoadMatrixf: procedure(m: PGLfloat); stdcall;
  glLoadName: procedure(name: TGLuint); stdcall;
  glLogicOp: procedure(opcode: TGLEnum); stdcall;
  glMap1d: procedure(target: TGLEnum; u1, u2: TGLdouble; stride, order: TGLint; points: PGLdouble); stdcall;
  glMap1f: procedure(target: TGLEnum; u1, u2: TGLfloat; stride, order: TGLint; points: PGLfloat);   stdcall;
  glMap2d: procedure(target: TGLEnum; u1, u2: TGLdouble; ustride, uorder: TGLint; v1, v2: TGLdouble; vstride,
    vorder: TGLint; points: PGLdouble); stdcall;
  glMap2f: procedure(target: TGLEnum; u1, u2: TGLfloat; ustride, uorder: TGLint; v1, v2: TGLfloat; vstride,
    vorder: TGLint; points: PGLfloat); stdcall;
  glMapGrid1d: procedure(un: TGLint; u1, u2: TGLdouble); stdcall;
  glMapGrid1f: procedure(un: TGLint; u1, u2: TGLfloat); stdcall;
  glMapGrid2d: procedure(un: TGLint; u1, u2: TGLdouble; vn: TGLint; v1, v2: TGLdouble); stdcall;
  glMapGrid2f: procedure(un: TGLint; u1, u2: TGLfloat; vn: TGLint; v1, v2: TGLfloat); stdcall;
  glMaterialf: procedure(face, pname: TGLEnum; param: TGLfloat); stdcall;
  glMaterialfv: procedure(face, pname: TGLEnum; params: PGLfloat); stdcall;
  glMateriali: procedure(face, pname: TGLEnum; param: TGLint); stdcall;
  glMaterialiv: procedure(face, pname: TGLEnum; params: PGLint); stdcall;
  glMatrixMode: procedure(mode: TGLEnum); stdcall;
  glMultMatrixd: procedure(m: PGLdouble); stdcall;
  glMultMatrixf: procedure(m: PGLfloat); stdcall;
  glNewList: procedure(list: TGLuint; mode: TGLEnum); stdcall;
  glNormal3b: procedure(nx, ny, nz: TGLbyte); stdcall;
  glNormal3bv: procedure(v: PGLbyte); stdcall;
  glNormal3d: procedure(nx, ny, nz: TGLdouble); stdcall;
  glNormal3dv: procedure(v: PGLdouble); stdcall;
  glNormal3f: procedure(nx, ny, nz: TGLfloat); stdcall;
  glNormal3fv: procedure(v: PGLfloat); stdcall;
  glNormal3i: procedure(nx, ny, nz: TGLint); stdcall;
  glNormal3iv: procedure(v: PGLint); stdcall;
  glNormal3s: procedure(nx, ny, nz: TGLshort); stdcall;
  glNormal3sv: procedure(v: PGLshort); stdcall;
  glNormalPointer: procedure(atype: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glOrtho: procedure(left, right, bottom, top, zNear, zFar: TGLdouble); stdcall;
  glPassThrough: procedure(token: TGLfloat); stdcall;
  glPixelMapfv: procedure(map: TGLEnum; mapsize: TGLsizei; values: PGLfloat); stdcall;
  glPixelMapuiv: procedure(map: TGLEnum; mapsize: TGLsizei; values: PGLuint); stdcall;
  glPixelMapusv: procedure(map: TGLEnum; mapsize: TGLsizei; values: PGLushort); stdcall;
  glPixelStoref: procedure(pname: TGLEnum; param: TGLfloat); stdcall;
  glPixelStorei: procedure(pname: TGLEnum; param: TGLint); stdcall;
  glPixelTransferf: procedure(pname: TGLEnum; param: TGLfloat); stdcall;
  glPixelTransferi: procedure(pname: TGLEnum; param: TGLint); stdcall;
  glPixelZoom: procedure(xfactor, yfactor: TGLfloat); stdcall;
  glPointSize: procedure(size: TGLfloat); stdcall;
  glPolygonMode: procedure(face, mode: TGLEnum); stdcall;
  glPolygonOffset: procedure(factor, units: TGLfloat); stdcall;
  glPolygonStipple: procedure(mask: PGLubyte); stdcall;
  glPopAttrib: procedure; stdcall;
  glPopClientAttrib: procedure; stdcall;
  glPopMatrix: procedure; stdcall;
  glPopName: procedure; stdcall;
  glPrioritizeTextures: procedure(n: TGLsizei; textures: PGLuint; priorities: PGLclampf); stdcall;
  glPushAttrib: procedure(mask: TGLbitfield); stdcall;
  glPushClientAttrib: procedure(mask: TGLbitfield); stdcall;
  glPushMatrix: procedure; stdcall;
  glPushName: procedure(name: TGLuint); stdcall;
  glRasterPos2d: procedure(x, y: TGLdouble); stdcall;
  glRasterPos2dv: procedure(v: PGLdouble); stdcall;
  glRasterPos2f: procedure(x, y: TGLfloat); stdcall;
  glRasterPos2fv: procedure(v: PGLfloat); stdcall;
  glRasterPos2i: procedure(x, y: TGLint); stdcall;
  glRasterPos2iv: procedure(v: PGLint); stdcall;
  glRasterPos2s: procedure(x, y: PGLshort); stdcall;
  glRasterPos2sv: procedure(v: PGLshort); stdcall;
  glRasterPos3d: procedure(x, y, z: TGLdouble); stdcall;
  glRasterPos3dv: procedure(v: PGLdouble); stdcall;
  glRasterPos3f: procedure(x, y, z: TGLfloat); stdcall;
  glRasterPos3fv: procedure(v: PGLfloat); stdcall;
  glRasterPos3i: procedure(x, y, z: TGLint); stdcall;
  glRasterPos3iv: procedure(v: PGLint); stdcall;
  glRasterPos3s: procedure(x, y, z: TGLshort); stdcall;
  glRasterPos3sv: procedure(v: PGLshort); stdcall;
  glRasterPos4d: procedure(x, y, z, w: TGLdouble); stdcall;
  glRasterPos4dv: procedure(v: PGLdouble); stdcall;
  glRasterPos4f: procedure(x, y, z, w: TGLfloat); stdcall;
  glRasterPos4fv: procedure(v: PGLfloat); stdcall;
  glRasterPos4i: procedure(x, y, z, w: TGLint); stdcall;
  glRasterPos4iv: procedure(v: PGLint); stdcall;
  glRasterPos4s: procedure(x, y, z, w: TGLshort); stdcall;
  glRasterPos4sv: procedure(v: PGLshort); stdcall;
  glReadBuffer: procedure(mode: TGLEnum); stdcall;
  glReadPixels: procedure(x, y: TGLint; width, height: TGLsizei; format, atype: TGLEnum; pixels: Pointer); stdcall;
  glRectd: procedure(x1, y1, x2, y2: TGLdouble); stdcall;
  glRectdv: procedure(v1, v2: PGLdouble); stdcall;
  glRectf: procedure(x1, y1, x2, y2: TGLfloat); stdcall;
  glRectfv: procedure(v1, v2: PGLfloat); stdcall;
  glRecti: procedure(x1, y1, x2, y2: TGLint); stdcall;
  glRectiv: procedure(v1, v2: PGLint); stdcall;
  glRects: procedure(x1, y1, x2, y2: TGLshort); stdcall;
  glRectsv: procedure(v1, v2: PGLshort); stdcall;
  glRenderMode: function(mode: TGLEnum): TGLint; stdcall;
  glRotated: procedure(angle, x, y, z: TGLdouble); stdcall;
  glRotatef: procedure(angle, x, y, z: TGLfloat); stdcall;
  glScaled: procedure(x, y, z: TGLdouble); stdcall;
  glScalef: procedure(x, y, z: TGLfloat); stdcall;
  glScissor: procedure(x, y: TGLint; width, height: TGLsizei); stdcall;
  glSelectBuffer: procedure(size: TGLsizei; buffer: PGLuint); stdcall;
  glShadeModel: procedure(mode: TGLEnum); stdcall;
  glStencilFunc: procedure(func: TGLEnum; ref: TGLint; mask: TGLuint); stdcall;
  glStencilMask: procedure(mask: TGLuint); stdcall;
  glStencilOp: procedure(fail, zfail, zpass: TGLEnum); stdcall;
  glTexCoord1d: procedure(s: TGLdouble); stdcall;
  glTexCoord1dv: procedure(v: PGLdouble); stdcall;
  glTexCoord1f: procedure(s: TGLfloat); stdcall;
  glTexCoord1fv: procedure(v: PGLfloat); stdcall;
  glTexCoord1i: procedure(s: TGLint); stdcall;
  glTexCoord1iv: procedure(v: PGLint); stdcall;
  glTexCoord1s: procedure(s: TGLshort); stdcall;
  glTexCoord1sv: procedure(v: PGLshort); stdcall;
  glTexCoord2d: procedure(s, t: TGLdouble); stdcall;
  glTexCoord2dv: procedure(v: PGLdouble); stdcall;
  glTexCoord2f: procedure(s, t: TGLfloat); stdcall;
  glTexCoord2fv: procedure(v: PGLfloat); stdcall;
  glTexCoord2i: procedure(s, t: TGLint); stdcall;
  glTexCoord2iv: procedure(v: PGLint); stdcall;
  glTexCoord2s: procedure(s, t: TGLshort); stdcall;
  glTexCoord2sv: procedure(v: PGLshort); stdcall;
  glTexCoord3d: procedure(s, t, r: TGLdouble); stdcall;
  glTexCoord3dv: procedure(v: PGLdouble); stdcall;
  glTexCoord3f: procedure(s, t, r: TGLfloat); stdcall;
  glTexCoord3fv: procedure(v: PGLfloat); stdcall;
  glTexCoord3i: procedure(s, t, r: TGLint); stdcall;
  glTexCoord3iv: procedure(v: PGLint); stdcall;
  glTexCoord3s: procedure(s, t, r: TGLshort); stdcall;
  glTexCoord3sv: procedure(v: PGLshort); stdcall;
  glTexCoord4d: procedure(s, t, r, q: TGLdouble); stdcall;
  glTexCoord4dv: procedure(v: PGLdouble); stdcall;
  glTexCoord4f: procedure(s, t, r, q: TGLfloat); stdcall;
  glTexCoord4fv: procedure(v: PGLfloat); stdcall;
  glTexCoord4i: procedure(s, t, r, q: TGLint); stdcall;
  glTexCoord4iv: procedure(v: PGLint); stdcall;
  glTexCoord4s: procedure(s, t, r, q: TGLshort); stdcall;
  glTexCoord4sv: procedure(v: PGLshort); stdcall;
  glTexCoordPointer: procedure(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glTexEnvf: procedure(target, pname: TGLEnum; param: TGLfloat); stdcall;
  glTexEnvfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glTexEnvi: procedure(target, pname: TGLEnum; param: TGLint); stdcall;
  glTexEnviv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glTexGend: procedure(coord, pname: TGLEnum; param: TGLdouble); stdcall;
  glTexGendv: procedure(coord, pname: TGLEnum; params: PGLdouble); stdcall;
  glTexGenf: procedure(coord, pname: TGLEnum; param: TGLfloat); stdcall;
  glTexGenfv: procedure(coord, pname: TGLEnum; params: PGLfloat); stdcall;
  glTexGeni: procedure(coord, pname: TGLEnum; param: TGLint); stdcall;
  glTexGeniv: procedure(coord, pname: TGLEnum; params: PGLint); stdcall;
  glTexImage1D: procedure(target: TGLEnum; level, internalformat: TGLint; width: TGLsizei; border: TGLint; format,
    atype: TGLEnum; pixels: Pointer); stdcall;
  glTexImage2D: procedure(target: TGLEnum; level, internalformat: TGLint; width, height: TGLsizei; border: TGLint;
    format, atype: TGLEnum; Pixels:Pointer); stdcall;
  glTexParameterf: procedure(target, pname: TGLEnum; param: TGLfloat); stdcall;
  glTexParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glTexParameteri: procedure(target, pname: TGLEnum; param: TGLint); stdcall;
  glTexParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glTexSubImage1D: procedure(target: TGLEnum; level, xoffset: TGLint; width: TGLsizei; format, atype: TGLEnum;
    pixels: Pointer); stdcall;
  glTexSubImage2D: procedure(target: TGLEnum; level, xoffset, yoffset: TGLint; width, height: TGLsizei; format,
    atype: TGLEnum; pixels: Pointer); stdcall;
  glTranslated: procedure(x, y, z: TGLdouble); stdcall;
  glTranslatef: procedure(x, y, z: TGLfloat); stdcall;
  glVertex2d: procedure(x, y: TGLdouble); stdcall;
  glVertex2dv: procedure(v: PGLdouble); stdcall;
  glVertex2f: procedure(x, y: TGLfloat); stdcall;
  glVertex2fv: procedure(v: PGLfloat); stdcall;
  glVertex2i: procedure(x, y: TGLint); stdcall;
  glVertex2iv: procedure(v: PGLint); stdcall;
  glVertex2s: procedure(x, y: TGLshort); stdcall;
  glVertex2sv: procedure(v: PGLshort); stdcall;
  glVertex3d: procedure(x, y, z: TGLdouble); stdcall;
  glVertex3dv: procedure(v: PGLdouble); stdcall;
  glVertex3f: procedure(x, y, z: TGLfloat); stdcall;
  glVertex3fv: procedure(v: PGLfloat); stdcall;
  glVertex3i: procedure(x, y, z: TGLint); stdcall;
  glVertex3iv: procedure(v: PGLint); stdcall;
  glVertex3s: procedure(x, y, z: TGLshort); stdcall;
  glVertex3sv: procedure(v: PGLshort); stdcall;
  glVertex4d: procedure(x, y, z, w: TGLdouble); stdcall;
  glVertex4dv: procedure(v: PGLdouble); stdcall;
  glVertex4f: procedure(x, y, z, w: TGLfloat); stdcall;
  glVertex4fv: procedure(v: PGLfloat); stdcall;
  glVertex4i: procedure(x, y, z, w: TGLint); stdcall;
  glVertex4iv: procedure(v: PGLint); stdcall;
  glVertex4s: procedure(x, y, z, w: TGLshort); stdcall;
  glVertex4sv: procedure(v: PGLshort); stdcall;
  glVertexPointer: procedure(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); stdcall;
  glViewport: procedure(x, y: TGLint; width, height: TGLsizei); stdcall;

  // GL 1.2
  glDrawRangeElements: procedure(mode: TGLEnum; Astart, Aend: TGLuint; count: TGLsizei; Atype: TGLEnum;
    indices: Pointer); stdcall;
  glTexImage3D: procedure(target: TGLEnum; level: TGLint; internalformat: TGLEnum; width, height, depth: TGLsizei;
    border: TGLint; format: TGLEnum; Atype: TGLEnum; pixels: Pointer); stdcall;

  // GL 1.2 ARB imaging
  glBlendColor: procedure(red, green, blue, alpha: TGLclampf); stdcall;
  glBlendEquation: procedure(mode: TGLEnum); stdcall;
  glColorSubTable: procedure(target: TGLEnum; start, count: TGLsizei; format, Atype: TGLEnum; data: Pointer); stdcall;
  glCopyColorSubTable: procedure(target: TGLEnum; start: TGLsizei; x, y: TGLint; width: TGLsizei); stdcall;
  glColorTable: procedure(target, internalformat: TGLEnum; width: TGLsizei; format, Atype: TGLEnum;
    table: Pointer); stdcall;
  glCopyColorTable: procedure(target, internalformat: TGLEnum; x, y: TGLint; width: TGLsizei); stdcall;
  glColorTableParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glColorTableParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetColorTable: procedure(target, format, Atype: TGLEnum; table: Pointer); stdcall;
  glGetColorTableParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glGetColorTableParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glConvolutionFilter1D: procedure(target, internalformat: TGLEnum; width: TGLsizei; format, Atype: TGLEnum;
    image: Pointer); stdcall;
  glConvolutionFilter2D: procedure(target, internalformat: TGLEnum; width, height: TGLsizei; format, Atype: TGLEnum;
    image: Pointer); stdcall;
  glCopyConvolutionFilter1D: procedure(target, internalformat: TGLEnum; x, y: TGLint; width: TGLsizei); stdcall;
  glCopyConvolutionFilter2D: procedure(target, internalformat: TGLEnum; x, y: TGLint; width, height: TGLsizei); stdcall;
  glGetConvolutionFilter: procedure(target, internalformat, Atype: TGLEnum; image: Pointer); stdcall;
  glSeparableFilter2D: procedure(target, internalformat: TGLEnum; width, height: TGLsizei; format, Atype: TGLEnum; row,
    column: Pointer); stdcall;
  glGetSeparableFilter: procedure(target, format, Atype: TGLEnum; row, column, span: Pointer); stdcall;
  glConvolutionParameteri: procedure(target, pname: TGLEnum; param: TGLint); stdcall;
  glConvolutionParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glConvolutionParameterf: procedure(target, pname: TGLEnum; param: TGLfloat); stdcall;
  glConvolutionParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glGetConvolutionParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glGetConvolutionParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glHistogram: procedure(target: TGLEnum; width: TGLsizei; internalformat: TGLEnum; sink: TGLboolean); stdcall;
  glResetHistogram: procedure(target: TGLEnum); stdcall;
  glGetHistogram: procedure(target: TGLEnum; reset: TGLboolean; format, Atype: TGLEnum; values: Pointer); stdcall;
  glGetHistogramParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glGetHistogramParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;
  glMinmax: procedure(target, internalformat: TGLEnum; sink: TGLboolean); stdcall;
  glResetMinmax: procedure(target: TGLEnum); stdcall;
  glGetMinmax: procedure(target: TGLEnum; reset: TGLboolean; format, Atype: TGLEnum; values: Pointer); stdcall;
  glGetMinmaxParameteriv: procedure(target, pname: TGLEnum; params: PGLint); stdcall;
  glGetMinmaxParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); stdcall;

  // GL utility functions and procedures
  gluErrorString: function(errCode: TGLEnum): PChar; stdcall;
  gluGetString: function(name: TGLEnum): PChar; stdcall;
  gluOrtho2D: procedure(left, right, bottom, top: TGLdouble); stdcall;
  gluPerspective: procedure(fovy, aspect, zNear, zFar: TGLdouble); stdcall;
  gluPickMatrix: procedure(x, y, width, height: TGLdouble; viewport: TVector4i); stdcall;
  gluLookAt: procedure(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: TGLdouble); stdcall;
  gluProject: function(objx, objy, objz: TGLdouble; modelMatrix: TMatrix4d; projMatrix: TMatrix4d; viewport: TVector4i;
    winx, winy, winz: PGLdouble): TGLint; stdcall;
  gluUnProject: function(winx, winy, winz: TGLdouble; modelMatrix: TMatrix4d; projMatrix: TMatrix4d; viewport: TVector4i;
    objx, objy, objz: PGLdouble): TGLint; stdcall;
  gluScaleImage: function(format: TGLEnum; widthin, heightin: TGLint; typein: TGLEnum; datain: Pointer; widthout,
    heightout: TGLint; typeout: TGLEnum; dataout: Pointer): TGLint; stdcall;
  gluBuild1DMipmaps: function(target: TGLEnum; components, width: TGLint; format, atype: TGLEnum;
    data: Pointer): TGLint; stdcall;
  gluBuild2DMipmaps: function(target: TGLEnum; components, width, height: TGLint; format, atype: TGLEnum;
    Data: Pointer): TGLint; stdcall;
  gluNewQuadric: function : PGLUquadric; stdcall;
  gluDeleteQuadric: procedure(state: PGLUquadric); stdcall;
  gluQuadricNormals: procedure(quadObject: PGLUquadric; normals: TGLEnum); stdcall;
  gluQuadricTexture: procedure(quadObject: PGLUquadric; textureCoords: TGLboolean); stdcall;
  gluQuadricOrientation: procedure(quadObject: PGLUquadric; orientation: TGLEnum); stdcall;
  gluQuadricDrawStyle: procedure(quadObject: PGLUquadric; drawStyle: TGLEnum); stdcall;
  gluCylinder: procedure(quadObject: PGLUquadric; baseRadius, topRadius, height: TGLdouble; slices,
    stacks: TGLint); stdcall;
  gluDisk: procedure(quadObject: PGLUquadric; innerRadius, outerRadius: TGLdouble; slices, loops: TGLint); stdcall;
  gluPartialDisk: procedure(quadObject: PGLUquadric; innerRadius, outerRadius: TGLdouble; slices, loops: TGLint;
    startAngle, sweepAngle: TGLdouble); stdcall;
  gluSphere: procedure(quadObject: PGLUquadric; radius: TGLdouble; slices, stacks: TGLint); stdcall;
  gluQuadricCallback: procedure(quadObject: PGLUquadric; which: TGLEnum; fn: TGLUQuadricErrorProc); stdcall;
  gluNewTess: function : PGLUtesselator; stdcall;
  gluDeleteTess: procedure(tess: PGLUtesselator); stdcall;
  gluTessBeginPolygon: procedure(tess: PGLUtesselator; polygon_data: Pointer); stdcall;
  gluTessBeginContour: procedure(tess: PGLUtesselator); stdcall;
  gluTessVertex: procedure(tess: PGLUtesselator; coords: TVector3d; data: Pointer); stdcall;
  gluTessEndContour: procedure(tess: PGLUtesselator); stdcall;
  gluTessEndPolygon: procedure(tess: PGLUtesselator); stdcall;
  gluTessProperty: procedure(tess: PGLUtesselator; which: TGLEnum; value: TGLdouble); stdcall;
  gluTessNormal: procedure(tess: PGLUtesselator; x, y, z: TGLdouble); stdcall;
  gluTessCallback: procedure(tess: PGLUtesselator; which: TGLEnum; fn: Pointer); stdcall;
  gluGetTessProperty: procedure(tess: PGLUtesselator; which: TGLEnum; value: PGLdouble); stdcall;
  gluNewNurbsRenderer: function : PGLUnurbs; stdcall;
  gluDeleteNurbsRenderer: procedure(nobj: PGLUnurbs); stdcall;
  gluBeginSurface: procedure(nobj: PGLUnurbs); stdcall;
  gluBeginCurve: procedure(nobj: PGLUnurbs); stdcall;
  gluEndCurve: procedure(nobj: PGLUnurbs); stdcall;
  gluEndSurface: procedure(nobj: PGLUnurbs); stdcall;
  gluBeginTrim: procedure(nobj: PGLUnurbs); stdcall;
  gluEndTrim: procedure(nobj: PGLUnurbs); stdcall;
  gluPwlCurve: procedure(nobj: PGLUnurbs; count: TGLint; points: PGLfloat; stride: TGLint; atype: TGLEnum); stdcall;
  gluNurbsCurve: procedure(nobj: PGLUnurbs; nknots: TGLint; knot: PGLfloat; stride: TGLint; ctlarray: PGLfloat;
    order: TGLint; atype: TGLEnum); stdcall;
  gluNurbsSurface: procedure(nobj: PGLUnurbs; sknot_count: TGLint; sknot: PGLfloat; tknot_count: TGLint;
    tknot: PGLfloat; s_stride, t_stride: TGLint; ctlarray: PGLfloat; sorder, torder: TGLint; atype: TGLEnum); stdcall;
  gluLoadSamplingMatrices: procedure(nobj: PGLUnurbs; modelMatrix, projMatrix: TMatrix4f; viewport: TVector4i); stdcall;
  gluNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: TGLEnum; value: TGLfloat); stdcall;
  gluGetNurbsProperty: procedure(nobj: PGLUnurbs; aproperty: TGLEnum; value: PGLfloat); stdcall;
  gluNurbsCallback: procedure(nobj: PGLUnurbs; which: TGLEnum; fn: TGLUNurbsErrorProc); stdcall;
  gluBeginPolygon: procedure(tess: PGLUtesselator); stdcall;
  gluNextContour: procedure(tess: PGLUtesselator; atype: TGLEnum); stdcall;
  gluEndPolygon: procedure(tess: PGLUtesselator); stdcall;

  // window support functions
  wglGetProcAddress: function(ProcName: PChar): Pointer; stdcall;

  // ARB_multitexture
  glMultiTexCoord1dARB: procedure(target: TGLenum; s: TGLdouble); stdcall;
  glMultiTexCoord1dVARB: procedure(target: TGLenum; v: PGLdouble); stdcall;
  glMultiTexCoord1fARBP: procedure(target: TGLenum; s: TGLfloat); stdcall;
  glMultiTexCoord1fVARB: procedure(target: TGLenum; v: TGLfloat); stdcall;
  glMultiTexCoord1iARB: procedure(target: TGLenum; s: TGLint); stdcall;
  glMultiTexCoord1iVARB: procedure(target: TGLenum; v: PGLInt); stdcall;
  glMultiTexCoord1sARBP: procedure(target: TGLenum; s: TGLshort); stdcall;
  glMultiTexCoord1sVARB: procedure(target: TGLenum; v: PGLshort); stdcall;
  glMultiTexCoord2dARB: procedure(target: TGLenum; s, t: TGLdouble); stdcall;
  glMultiTexCoord2dvARB: procedure(target: TGLenum; v: PGLdouble); stdcall;
  glMultiTexCoord2fARB: procedure(target: TGLenum; s, t: TGLfloat); stdcall;
  glMultiTexCoord2fvARB: procedure(target: TGLenum; v: PGLfloat); stdcall;
  glMultiTexCoord2iARB: procedure(target: TGLenum; s, t: TGLint); stdcall;
  glMultiTexCoord2ivARB: procedure(target: TGLenum; v: PGLint); stdcall;
  glMultiTexCoord2sARB: procedure(target: TGLenum; s, t: TGLshort); stdcall;
  glMultiTexCoord2svARB: procedure(target: TGLenum; v: PGLshort); stdcall;
  glMultiTexCoord3dARB: procedure(target: TGLenum; s, t, r: TGLdouble); stdcall;
  glMultiTexCoord3dvARB: procedure(target: TGLenum; v: PGLdouble); stdcall;
  glMultiTexCoord3fARB: procedure(target: TGLenum; s, t, r: TGLfloat); stdcall;
  glMultiTexCoord3fvARB: procedure(target: TGLenum; v: PGLfloat); stdcall;
  glMultiTexCoord3iARB: procedure(target: TGLenum; s, t, r: TGLint); stdcall;
  glMultiTexCoord3ivARB: procedure(target: TGLenum; v: PGLint); stdcall;
  glMultiTexCoord3sARB: procedure(target: TGLenum; s, t, r: TGLshort); stdcall;
  glMultiTexCoord3svARB: procedure(target: TGLenum; v: PGLshort); stdcall;
  glMultiTexCoord4dARB: procedure(target: TGLenum; s, t, r, q: TGLdouble); stdcall;
  glMultiTexCoord4dvARB: procedure(target: TGLenum; v: PGLdouble); stdcall;
  glMultiTexCoord4fARB: procedure(target: TGLenum; s, t, r, q: TGLfloat); stdcall;
  glMultiTexCoord4fvARB: procedure(target: TGLenum; v: PGLfloat); stdcall;
  glMultiTexCoord4iARB: procedure(target: TGLenum; s, t, r, q: TGLint); stdcall;
  glMultiTexCoord4ivARB: procedure(target: TGLenum; v: PGLint); stdcall;
  glMultiTexCoord4sARB: procedure(target: TGLenum; s, t, r, q: TGLshort); stdcall;
  glMultiTexCoord4svARB: procedure(target: TGLenum; v: PGLshort); stdcall;
  glActiveTextureARB: procedure(target: TGLenum); stdcall;
  glClientActiveTextureARB: procedure(target: TGLenum); stdcall;

  // GLU extensions
  gluNurbsCallbackDataEXT: procedure(nurb: PGLUnurbs; userData: Pointer); stdcall;
  gluNewNurbsTessellatorEXT: function: PGLUnurbs; stdcall;
  gluDeleteNurbsTessellatorEXT: procedure(nurb: PGLUnurbs); stdcall;

  // Extension functions
  glAreTexturesResidentEXT: function(n: TGLsizei; textures: PGLuint; residences: PGLBoolean): TGLboolean; stdcall;
  glArrayElementArrayEXT: procedure(mode: TGLEnum; count: TGLsizei; pi: Pointer); stdcall;
  glBeginSceneEXT: procedure; stdcall;
  glBindTextureEXT: procedure(target: TGLEnum; texture: TGLuint); stdcall;
  glColorTableEXT: procedure(target, internalFormat: TGLEnum; width: TGLsizei; format, atype: TGLEnum;
    data: Pointer); stdcall;
  glColorSubTableExt: procedure(target: TGLEnum; start, count: TGLsizei; format, atype: TGLEnum; data: Pointer); stdcall;
  glCopyTexImage1DEXT: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint;
    width: TGLsizei; border: TGLint); stdcall;
  glCopyTexSubImage1DEXT: procedure(target: TGLEnum; level, xoffset, x, y: TGLint; width: TGLsizei); stdcall;
  glCopyTexImage2DEXT: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width,
    height: TGLsizei; border: TGLint); stdcall;
  glCopyTexSubImage2DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, x, y: TGLint; width,
    height: TGLsizei); stdcall;
  glCopyTexSubImage3DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, zoffset, x, y: TGLint; width,
    height: TGLsizei); stdcall;
  glDeleteTexturesEXT: procedure(n: TGLsizei; textures: PGLuint); stdcall;
  glEndSceneEXT: procedure; stdcall;
  glGenTexturesEXT: procedure(n: TGLsizei; textures: PGLuint); stdcall;
  glGetColorTableEXT: procedure(target, format, atype: TGLEnum; data: Pointer); stdcall;
  glGetColorTablePameterfvEXT: procedure(target, pname: TGLEnum; params: Pointer); stdcall;
  glGetColorTablePameterivEXT: procedure(target, pname: TGLEnum; params: Pointer); stdcall;
  glIndexFuncEXT: procedure(func: TGLEnum; ref: TGLfloat); stdcall;
  glIndexMaterialEXT: procedure(face: TGLEnum; mode: TGLEnum); stdcall;
  glIsTextureEXT: function(texture: TGLuint): TGLboolean; stdcall;
  glLockArraysEXT: procedure(first: TGLint; count: TGLsizei); stdcall;
  glPolygonOffsetEXT: procedure(factor, bias: TGLfloat); stdcall;
  glPrioritizeTexturesEXT: procedure(n: TGLsizei; textures: PGLuint; priorities: PGLclampf); stdcall;
  glTexSubImage1DEXT: procedure(target: TGLEnum; level, xoffset: TGLint; width: TGLsizei; format, Atype: TGLEnum;
    pixels: Pointer); stdcall;
  glTexSubImage2DEXT: procedure(target: TGLEnum; level, xoffset, yoffset: TGLint; width, height: TGLsizei; format,
    Atype: TGLEnum; pixels: Pointer); stdcall;
  glTexSubImage3DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, zoffset: TGLint; width, height,
    depth: TGLsizei; format, Atype: TGLEnum; pixels: Pointer); stdcall;
  glUnlockArraysEXT: procedure; stdcall;

  // EXT_vertex_array
  glArrayElementEXT: procedure(I: TGLint); stdcall;
  glColorPointerEXT: procedure(size: TGLInt; atype: TGLenum; stride, count: TGLsizei; data: Pointer); stdcall;
  glDrawArraysEXT: procedure(mode: TGLenum; first: TGLInt; count: TGLsizei); stdcall;
  glEdgeFlagPointerEXT: procedure(stride, count: TGLsizei; data: PGLboolean); stdcall;
  glGetPointervEXT: procedure(pname: TGLEnum; var params); stdcall;
  glIndexPointerEXT: procedure(AType: TGLEnum; stride, count: TGLsizei; P: Pointer); stdcall;
  glNormalPointerEXT: procedure(AType: TGLsizei; stride, count: TGLsizei; P: Pointer); stdcall;
  glTexCoordPointerEXT: procedure(size: TGLint; AType: TGLenum;  stride, count: TGLsizei; P: Pointer); stdcall;
  glVertexPointerEXT: procedure(size: TGLint; AType: TGLenum; stride, count: TGLsizei; P: Pointer); stdcall;

  // EXT_compiled_vertex_array
  glLockArrayEXT: procedure(first: TGLint; count: TGLsizei); stdcall;
  glUnlockArrayEXT: procedure; stdcall;

  // EXT_cull_vertex
  glCullParameterdvEXT: procedure(pname: TGLenum; params: PGLdouble); stdcall;
  glCullParameterfvEXT: procedure(pname: TGLenum; params: PGLfloat); stdcall;

  // WIN_swap_hint
  glAddSwapHintRectWIN: procedure(x, y: TGLint; width, height: TGLsizei); stdcall;

  // EXT_point_parameter
  glPointParameterfEXT: procedure(pname: TGLenum; param: TGLfloat); stdcall;
  glPointParameterfvEXT: procedure(pname: TGLenum; params: PGLfloat); stdcall;

//----------------------------------------------------------------------------------------------------------------------

procedure CloseOpenGL;
function InitOpenGL: Boolean;
function InitOpenGLFromLibrary(GL_Name, GLU_Name: String): Boolean;

procedure ClearExtensions;
procedure ActivateRenderingContext(DC: HDC; RC: HGLRC);
function  CreateRenderingContext(DC: HDC; Options: TRCOptions; ColorBits, StencilBits, AccumBits, AuxBuffers: Integer;
  Layer: Integer): HGLRC;
procedure DeactivateRenderingContext;
procedure DestroyRenderingContext(RC: HGLRC);
procedure ReadExtensions;
procedure ReadImplementationProperties;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  SysUtils;

threadvar
  LastPixelFormat: Integer;

var
  GLHandle, GLUHandle: HINST;

//----------------------------------------------------------------------------------------------------------------------

procedure ClearProcAddresses;

begin
{  glAccum:=nil;
  glAlphaFunc:=nil;
  glAreTexturesResident:=nil;
  glArrayElement:=nil;
  glBegin:=nil;
  glBindTexture:=nil;
  glBitmap:=nil;
  glBlendFunc:=nil;
  glCallList:=nil;
  glCallLists:=nil;
  glClear:=nil;
  glClearAccum:=nil;
  glClearColor:=nil;
  glClearDepth:=nil;
  glClearIndex:=nil;
  glClearStencil:=nil;
  glClipPlane:=nil;
  glColor3b:=nil;
  glColor3bv:=nil;
  glColor3d:=nil;
  glColor3dv:=nil;
  glColor3f:=nil;
  glColor3fv:=nil;
  glColor3i:=nil;
  glColor3iv:=nil;
  glColor3s:=nil;
  glColor3sv:=nil;
  glColor3ub:=nil;
  glColor3ubv:=nil;
  glColor3ui:=nil;
  glColor3uiv:=nil;
  glColor3us:=nil;
  glColor3usv:=nil;
  glColor4b:=nil;
  glColor4bv:=nil;
  glColor4d:=nil;
  glColor4dv:=nil;
  glColor4f:=nil;
  glColor4fv:=nil;
  glColor4i:=nil;
  glColor4iv:=nil;
  glColor4s:=nil;
  glColor4sv:=nil;
  glColor4ub:=nil;
  glColor4ubv:=nil;
  glColor4ui:=nil;
  glColor4uiv:=nil;
  glColor4us:=nil;
  glColor4usv:=nil;
  glColorMask:=nil;
  glColorMaterial:=nil;
  glColorPointer:=nil;
  glCopyPixels:=nil;                   
  glCopyTexImage1D:=nil;               
  glCopyTexImage2D:=nil;               
  glCopyTexSubImage1D:=nil;            
  glCopyTexSubImage2D:=nil;            
  glCullFace:=nil;                     
  glDeleteLists:=nil;                  
  glDeleteTextures:=nil;               
  glDepthFunc:=nil;                    
  glDepthMask:=nil;                    
  glDepthRange:=nil;                   
  glDisable:=nil;                      
  glDisableClientState:=nil;           
  glDrawArrays:=nil;                   
  glDrawBuffer:=nil;                   
  glDrawElements:=nil;                 
  glDrawPixels:=nil;
  glEdgeFlag:=nil;                     
  glEdgeFlagPointer:=nil;              
  glEdgeFlagv:=nil;                    
  glEnable:=nil;                       
  glEnableClientState:=nil;
  glEnd:=nil;                          
  glEndList:=nil;                      
  glEvalCoord1d:=nil;                  
  glEvalCoord1dv:=nil;
  glEvalCoord1f:=nil;                  
  glEvalCoord1fv:=nil;                 
  glEvalCoord2d:=nil;                  
  glEvalCoord2dv:=nil;                 
  glEvalCoord2f:=nil;                  
  glEvalCoord2fv:=nil;
  glEvalMesh1:=nil;                    
  glEvalMesh2:=nil;                    
  glEvalPoint1:=nil;                   
  glEvalPoint2:=nil;                   
  glFeedbackBuffer:=nil;               
  glFinish:=nil;
  glFlush:=nil;                        
  glFogf:=nil;                         
  glFogfv:=nil;                        
  glFogi:=nil;                         
  glFogiv:=nil;                        
  glFrontFace:=nil;
  glFrustum:=nil;                      
  glGenLists:=nil;                     
  glGenTextures:=nil;                  
  glGetBooleanv:=nil;                  
  glGetClipPlane:=nil;                 
  glGetDoublev:=nil;                   
  glGetError:=nil;                     
  glGetFloatv:=nil;                    
  glGetIntegerv:=nil;                  
  glGetLightfv:=nil;                   
  glGetLightiv:=nil;                   
  glGetMapdv:=nil;                     
  glGetMapfv:=nil;                     
  glGetMapiv:=nil;
  glGetMaterialfv:=nil;
  glGetMaterialiv:=nil;                
  glGetPixelMapfv:=nil;                
  glGetPixelMapuiv:=nil;
  glGetPixelMapusv:=nil;               
  glGetPointerv:=nil;                  
  glGetPolygonStipple:=nil;
  glGetString:=nil;                    
  glGetTexEnvfv:=nil;                  
  glGetTexEnviv:=nil;                  
  glGetTexGendv:=nil;                  
  glGetTexGenfv:=nil;                  
  glGetTexGeniv:=nil;                  
  glGetTexImage:=nil;                  
  glGetTexLevelParameterfv:=nil;       
  glGetTexLevelParameteriv:=nil;       
  glGetTexParameterfv:=nil;            
  glGetTexParameteriv:=nil;            
  glHint:=nil;                         
  glIndexMask:=nil;                    
  glIndexPointer:=nil;                 
  glIndexd:=nil;
  glIndexdv:=nil;                      
  glIndexf:=nil;                       
  glIndexfv:=nil;                      
  glIndexi:=nil;                       
  glIndexiv:=nil;                      
  glIndexs:=nil;                       
  glIndexsv:=nil;                      
  glIndexub:=nil;                      
  glIndexubv:=nil;                     
  glInitNames:=nil;                    
  glInterleavedArrays:=nil;            
  glIsEnabled:=nil;                    
  glIsList:=nil;
  glIsTexture:=nil;
  glLightModelf:=nil;                  
  glLightModelfv:=nil;                 
  glLightModeli:=nil;                  
  glLightModeliv:=nil;
  glLightf:=nil;                       
  glLightfv:=nil;                      
  glLighti:=nil;
  glLightiv:=nil;                      
  glLineStipple:=nil;                  
  glLineWidth:=nil;                    
  glListBase:=nil;                     
  glLoadIdentity:=nil;                 
  glLoadMatrixd:=nil;                  
  glLoadMatrixf:=nil;                  
  glLoadName:=nil;                     
  glLogicOp:=nil;                      
  glMap1d:=nil;                        
  glMap1f:=nil;                        
  glMap2d:=nil;                        
  glMap2f:=nil;                        
  glMapGrid1d:=nil;                    
  glMapGrid1f:=nil;                    
  glMapGrid2d:=nil;                    
  glMapGrid2f:=nil;                    
  glMaterialf:=nil;                    
  glMaterialfv:=nil;                   
  glMateriali:=nil;                    
  glMaterialiv:=nil;
  glMatrixMode:=nil;                   
  glMultMatrixd:=nil;                  
  glMultMatrixf:=nil;                  
  glNewList:=nil;                      
  glNormal3b:=nil;                     
  glNormal3bv:=nil;                    
  glNormal3d:=nil;                     
  glNormal3dv:=nil;
  glNormal3f:=nil;
  glNormal3fv:=nil;                    
  glNormal3i:=nil;                     
  glNormal3iv:=nil;
  glNormal3s:=nil;                     
  glNormal3sv:=nil;                    
  glNormalPointer:=nil;                
  glOrtho:=nil;                        
  glPassThrough:=nil;                  
  glPixelMapfv:=nil;                   
  glPixelMapuiv:=nil;                  
  glPixelMapusv:=nil;
  glPixelStoref:=nil;
  glPixelStorei:=nil;                  
  glPixelTransferf:=nil;               
  glPixelTransferi:=nil;               
  glPixelZoom:=nil;                    
  glPointSize:=nil;                    
  glPolygonMode:=nil;                  
  glPolygonOffset:=nil;                
  glPolygonStipple:=nil;               
  glPopAttrib:=nil;                    
  glPopClientAttrib:=nil;              
  glPopMatrix:=nil;                    
  glPopName:=nil;                      
  glPrioritizeTextures:=nil;           
  glPushAttrib:=nil;                   
  glPushClientAttrib:=nil;             
  glPushMatrix:=nil;                   
  glPushName:=nil;                     
  glRasterPos2d:=nil;                  
  glRasterPos2dv:=nil;                 
  glRasterPos2f:=nil;                  
  glRasterPos2fv:=nil;
  glRasterPos2i:=nil;                  
  glRasterPos2iv:=nil;
  glRasterPos2s:=nil;                  
  glRasterPos2sv:=nil;                 
  glRasterPos3d:=nil;                  
  glRasterPos3dv:=nil;
  glRasterPos3f:=nil;                  
  glRasterPos3fv:=nil;                 
  glRasterPos3i:=nil;                  
  glRasterPos3iv:=nil;                 
  glRasterPos3s:=nil;                  
  glRasterPos3sv:=nil;                 
  glRasterPos4d:=nil;                  
  glRasterPos4dv:=nil;                 
  glRasterPos4f:=nil;                  
  glRasterPos4fv:=nil;                 
  glRasterPos4i:=nil;                  
  glRasterPos4iv:=nil;                 
  glRasterPos4s:=nil;                  
  glRasterPos4sv:=nil;                 
  glReadBuffer:=nil;
  glReadPixels:=nil;                   
  glRectd:=nil;                        
  glRectdv:=nil;                       
  glRectf:=nil;                        
  glRectfv:=nil;                       
  glRecti:=nil;
  glRectiv:=nil;                       
  glRects:=nil;                        
  glRectsv:=nil;                       
  glRenderMode:=nil;                   
  glRotated:=nil;                      
  glRotatef:=nil;
  glScaled:=nil;                       
  glScalef:=nil;                       
  glScissor:=nil;                      
  glSelectBuffer:=nil;                 
  glShadeModel:=nil;
  glStencilFunc:=nil;                  
  glStencilMask:=nil;                  
  glStencilOp:=nil;                    
  glTexCoord1d:=nil;
  glTexCoord1dv:=nil;                  
  glTexCoord1f:=nil;                   
  glTexCoord1fv:=nil;                  
  glTexCoord1i:=nil;                   
  glTexCoord1iv:=nil;                  
  glTexCoord1s:=nil;                   
  glTexCoord1sv:=nil;                  
  glTexCoord2d:=nil;                   
  glTexCoord2dv:=nil;                  
  glTexCoord2f:=nil;                   
  glTexCoord2fv:=nil;                  
  glTexCoord2i:=nil;                   
  glTexCoord2iv:=nil;                  
  glTexCoord2s:=nil;                   
  glTexCoord2sv:=nil;                  
  glTexCoord3d:=nil;                   
  glTexCoord3dv:=nil;                  
  glTexCoord3f:=nil;                   
  glTexCoord3fv:=nil;                  
  glTexCoord3i:=nil;                   
  glTexCoord3iv:=nil;
  glTexCoord3s:=nil;                   
  glTexCoord3sv:=nil;                  
  glTexCoord4d:=nil;
  glTexCoord4dv:=nil;                  
  glTexCoord4f:=nil;                   
  glTexCoord4fv:=nil;                  
  glTexCoord4i:=nil;                   
  glTexCoord4iv:=nil;                  
  glTexCoord4s:=nil;                   
  glTexCoord4sv:=nil;                  
  glTexCoordPointer:=nil;
  glTexEnvf:=nil;                      
  glTexEnvfv:=nil;
  glTexEnvi:=nil;                      
  glTexEnviv:=nil;
  glTexGend:=nil;                      
  glTexGendv:=nil;                     
  glTexGenf:=nil;                      
  glTexGenfv:=nil;                     
  glTexGeni:=nil;                      
  glTexGeniv:=nil;
  glTexImage1D:=nil;                   
  glTexImage2D:=nil;                   
  glTexParameterf:=nil;                
  glTexParameterfv:=nil;               
  glTexParameteri:=nil;                
  glTexParameteriv:=nil;               
  glTexSubImage1D:=nil;                
  glTexSubImage2D:=nil;                
  glTranslated:=nil;                   
  glTranslatef:=nil;
  glVertex2d:=nil;                     
  glVertex2dv:=nil;                    
  glVertex2f:=nil;                     
  glVertex2fv:=nil;                    
  glVertex2i:=nil;
  glVertex2iv:=nil;                    
  glVertex2s:=nil;                     
  glVertex2sv:=nil;                    
  glVertex3d:=nil;
  glVertex3dv:=nil;                    
  glVertex3f:=nil;
  glVertex3fv:=nil;                    
  glVertex3i:=nil;                     
  glVertex3iv:=nil;
  glVertex3s:=nil;
  glVertex3sv:=nil;
  glVertex4d:=nil;
  glVertex4dv:=nil;
  glVertex4f:=nil;
  glVertex4fv:=nil;
  glVertex4i:=nil;
  glVertex4iv:=nil;
  glVertex4s:=nil;
  glVertex4sv:=nil;
  glVertexPointer:=nil;
  glViewport:=nil;

  wglGetProcAddress:=nil;

  // GL 1.2
  glDrawRangeElements:=nil;
  glTexImage3D:=nil;
  // GL 1.2 ARB imaging
  glBlendColor:=nil;
  glBlendEquation:=nil;
  glColorSubTable:=nil;
  glCopyColorSubTable:=nil;
  glColorTable:=nil;
  glCopyColorTable:=nil;
  glColorTableParameteriv:=nil;
  glColorTableParameterfv:=nil;
  glGetColorTable:=nil;
  glGetColorTableParameteriv:=nil;
  glGetColorTableParameterfv:=nil;
  glConvolutionFilter1D:=nil;
  glConvolutionFilter2D:=nil;
  glCopyConvolutionFilter1D:=nil;
  glCopyConvolutionFilter2D:=nil;
  glGetConvolutionFilter:=nil;
  glSeparableFilter2D:=nil;
  glGetSeparableFilter:=nil;
  glConvolutionParameteri:=nil;
  glConvolutionParameteriv:=nil;
  glConvolutionParameterf:=nil;
  glConvolutionParameterfv:=nil;
  glGetConvolutionParameteriv:=nil;
  glGetConvolutionParameterfv:=nil;
  glHistogram:=nil;
  glResetHistogram:=nil;
  glGetHistogram:=nil;
  glGetHistogramParameteriv:=nil;
  glGetHistogramParameterfv:=nil;
  glMinmax:=nil;
  glResetMinmax:=nil;
  glGetMinmax:=nil;
  glGetMinmaxParameteriv:=nil;
  glGetMinmaxParameterfv:=nil;}
end;

//----------------------------------------------------------------------------------------------------------------------

procedure LoadProcAddresses;

   function GetGLProcAddress(const procName : String) : FARPROC;
   begin
      Result:=GetProcAddress(GLHandle, PChar('gl'+procName));
   end;

   function GetGLUProcAddress(const procName : String) : FARPROC;
   begin
      Result:=GetProcAddress(GLUHandle, PChar('glu'+procName));
   end;

begin
  if GLHandle > 0 then
  begin
    glAccum:=GetGLProcAddress('Accum');
    glAlphaFunc:=GetGLProcAddress('AlphaFunc');
    glAreTexturesResident:=GetGLProcAddress('AreTexturesResident');
    glArrayElement:=GetGLProcAddress('ArrayElement');
    glBegin:=GetGLProcAddress('Begin');
    glBindTexture:=GetGLProcAddress('BindTexture');
    glBitmap:=GetGLProcAddress('Bitmap');
    glBlendFunc:=GetGLProcAddress('BlendFunc');
    glCallList:=GetGLProcAddress('CallList');
    glCallLists:=GetGLProcAddress('CallLists');
    glClear:=GetGLProcAddress('Clear');
    glClearAccum:=GetGLProcAddress('ClearAccum');
    glClearColor:=GetGLProcAddress('ClearColor');
    glClearDepth:=GetGLProcAddress('ClearDepth');
    glClearIndex:=GetGLProcAddress('ClearIndex');
    glClearStencil:=GetGLProcAddress('ClearStencil');
    glClipPlane:=GetGLProcAddress('ClipPlane');
    glColor3b:=GetGLProcAddress('Color3b');
    glColor3bv:=GetGLProcAddress('Color3bv');
    glColor3d:=GetGLProcAddress('Color3d');
    glColor3dv:=GetGLProcAddress('Color3dv');
    glColor3f:=GetGLProcAddress('Color3f');
    glColor3fv:=GetGLProcAddress('Color3fv');
    glColor3i:=GetGLProcAddress('Color3i');
    glColor3iv:=GetGLProcAddress('Color3iv');
    glColor3s:=GetGLProcAddress('Color3s');
    glColor3sv:=GetGLProcAddress('Color3sv');
    glColor3ub:=GetGLProcAddress('Color3ub');
    glColor3ubv:=GetGLProcAddress('Color3ubv');
    glColor3ui:=GetGLProcAddress('Color3ui');
    glColor3uiv:=GetGLProcAddress('Color3uiv');
    glColor3us:=GetGLProcAddress('Color3us');
    glColor3usv:=GetGLProcAddress('Color3usv');
    glColor4b:=GetGLProcAddress('Color4b');
    glColor4bv:=GetGLProcAddress('Color4bv');
    glColor4d:=GetGLProcAddress('Color4d');
    glColor4dv:=GetGLProcAddress('Color4dv');
    glColor4f:=GetGLProcAddress('Color4f');
    glColor4fv:=GetGLProcAddress('Color4fv');
    glColor4i:=GetGLProcAddress('Color4i');
    glColor4iv:=GetGLProcAddress('Color4iv');
    glColor4s:=GetGLProcAddress('Color4s');
    glColor4sv:=GetGLProcAddress('Color4sv');
    glColor4ub:=GetGLProcAddress('Color4ub');
    glColor4ubv:=GetGLProcAddress('Color4ubv');
    glColor4ui:=GetGLProcAddress('Color4ui');
    glColor4uiv:=GetGLProcAddress('Color4uiv');
    glColor4us:=GetGLProcAddress('Color4us');
    glColor4usv:=GetGLProcAddress('Color4usv');
    glColorMask:=GetGLProcAddress('ColorMask');
    glColorMaterial:=GetGLProcAddress('ColorMaterial');
    glColorPointer:=GetGLProcAddress('ColorPointer');
    glCopyPixels:=GetGLProcAddress('CopyPixels');
    glCopyTexImage1D:=GetGLProcAddress('CopyTexImage1D');
    glCopyTexImage2D:=GetGLProcAddress('CopyTexImage2D');
    glCopyTexSubImage1D:=GetGLProcAddress('CopyTexSubImage1D');
    glCopyTexSubImage2D:=GetGLProcAddress('CopyTexSubImage2D');
    glCullFace:=GetGLProcAddress('CullFace');
    glDeleteLists:=GetGLProcAddress('DeleteLists');
    glDeleteTextures:=GetGLProcAddress('DeleteTextures');
    glDepthFunc:=GetGLProcAddress('DepthFunc');
    glDepthMask:=GetGLProcAddress('DepthMask');
    glDepthRange:=GetGLProcAddress('DepthRange');
    glDisable:=GetGLProcAddress('Disable');
    glDisableClientState:=GetGLProcAddress('DisableClientState');
    glDrawArrays:=GetGLProcAddress('DrawArrays');
    glDrawBuffer:=GetGLProcAddress('DrawBuffer');
    glDrawElements:=GetGLProcAddress('DrawElements');
    glDrawPixels:=GetGLProcAddress('DrawPixels');
    glEdgeFlag:=GetGLProcAddress('EdgeFlag');
    glEdgeFlagPointer:=GetGLProcAddress('EdgeFlagPointer');
    glEdgeFlagv:=GetGLProcAddress('EdgeFlagv');
    glEnable:=GetGLProcAddress('Enable');
    glEnableClientState:=GetGLProcAddress('EnableClientState');
    glEnd:=GetGLProcAddress('End');
    glEndList:=GetGLProcAddress('EndList');
    glEvalCoord1d:=GetGLProcAddress('EvalCoord1d');
    glEvalCoord1dv:=GetGLProcAddress('EvalCoord1dv');
    glEvalCoord1f:=GetGLProcAddress('EvalCoord1f');
    glEvalCoord1fv:=GetGLProcAddress('EvalCoord1fv');
    glEvalCoord2d:=GetGLProcAddress('EvalCoord2d');
    glEvalCoord2dv:=GetGLProcAddress('EvalCoord2dv');
    glEvalCoord2f:=GetGLProcAddress('EvalCoord2f');
    glEvalCoord2fv:=GetGLProcAddress('EvalCoord2fv');
    glEvalMesh1:=GetGLProcAddress('EvalMesh1');
    glEvalMesh2:=GetGLProcAddress('EvalMesh2');
    glEvalPoint1:=GetGLProcAddress('EvalPoint1');
    glEvalPoint2:=GetGLProcAddress('EvalPoint2');
    glFeedbackBuffer:=GetGLProcAddress('FeedbackBuffer');
    glFinish:=GetGLProcAddress('Finish');
    glFlush:=GetGLProcAddress('Flush');
    glFogf:=GetGLProcAddress('Fogf');
    glFogfv:=GetGLProcAddress('Fogfv');
    glFogi:=GetGLProcAddress('Fogi');
    glFogiv:=GetGLProcAddress('Fogiv');
    glFrontFace:=GetGLProcAddress('FrontFace');
    glFrustum:=GetGLProcAddress('Frustum');
    glGenLists:=GetGLProcAddress('GenLists');
    glGenTextures:=GetGLProcAddress('GenTextures');
    glGetBooleanv:=GetGLProcAddress('GetBooleanv');
    glGetClipPlane:=GetGLProcAddress('GetClipPlane');
    glGetDoublev:=GetGLProcAddress('GetDoublev');
    glGetError:=GetGLProcAddress('GetError');
    glGetFloatv:=GetGLProcAddress('GetFloatv');
    glGetIntegerv:=GetGLProcAddress('GetIntegerv');
    glGetLightfv:=GetGLProcAddress('GetLightfv');
    glGetLightiv:=GetGLProcAddress('GetLightiv');
    glGetMapdv:=GetGLProcAddress('GetMapdv');
    glGetMapfv:=GetGLProcAddress('GetMapfv');
    glGetMapiv:=GetGLProcAddress('GetMapiv');
    glGetMaterialfv:=GetGLProcAddress('GetMaterialfv');
    glGetMaterialiv:=GetGLProcAddress('GetMaterialiv');
    glGetPixelMapfv:=GetGLProcAddress('GetPixelMapfv');
    glGetPixelMapuiv:=GetGLProcAddress('GetPixelMapuiv');
    glGetPixelMapusv:=GetGLProcAddress('GetPixelMapusv');
    glGetPointerv:=GetGLProcAddress('GetPointerv');
    glGetPolygonStipple:=GetGLProcAddress('GetPolygonStipple');
    glGetString:=GetGLProcAddress('GetString');
    glGetTexEnvfv:=GetGLProcAddress('GetTexEnvfv');
    glGetTexEnviv:=GetGLProcAddress('GetTexEnviv');
    glGetTexGendv:=GetGLProcAddress('GetTexGendv');
    glGetTexGenfv:=GetGLProcAddress('GetTexGenfv');
    glGetTexGeniv:=GetGLProcAddress('GetTexGeniv');
    glGetTexImage:=GetGLProcAddress('GetTexImage');
    glGetTexLevelParameterfv:=GetGLProcAddress('GetTexLevelParameterfv');
    glGetTexLevelParameteriv:=GetGLProcAddress('GetTexLevelParameteriv');
    glGetTexParameterfv:=GetGLProcAddress('GetTexParameterfv');
    glGetTexParameteriv:=GetGLProcAddress('GetTexParameteriv');
    glHint:=GetGLProcAddress('Hint');
    glIndexMask:=GetGLProcAddress('IndexMask');
    glIndexPointer:=GetGLProcAddress('IndexPointer');
    glIndexd:=GetGLProcAddress('Indexd');
    glIndexdv:=GetGLProcAddress('Indexdv');
    glIndexf:=GetGLProcAddress('Indexf');
    glIndexfv:=GetGLProcAddress('Indexfv');
    glIndexi:=GetGLProcAddress('Indexi');
    glIndexiv:=GetGLProcAddress('Indexiv');
    glIndexs:=GetGLProcAddress('Indexs');
    glIndexsv:=GetGLProcAddress('Indexsv');
    glIndexub:=GetGLProcAddress('Indexub');
    glIndexubv:=GetGLProcAddress('Indexubv');
    glInitNames:=GetGLProcAddress('InitNames');
    glInterleavedArrays:=GetGLProcAddress('InterleavedArrays');
    glIsEnabled:=GetGLProcAddress('IsEnabled');
    glIsList:=GetGLProcAddress('IsList');
    glIsTexture:=GetGLProcAddress('IsTexture');
    glLightModelf:=GetGLProcAddress('LightModelf');
    glLightModelfv:=GetGLProcAddress('LightModelfv');
    glLightModeli:=GetGLProcAddress('LightModeli');
    glLightModeliv:=GetGLProcAddress('LightModeliv');
    glLightf:=GetGLProcAddress('Lightf');
    glLightfv:=GetGLProcAddress('Lightfv');
    glLighti:=GetGLProcAddress('Lighti');
    glLightiv:=GetGLProcAddress('Lightiv');
    glLineStipple:=GetGLProcAddress('LineStipple');
    glLineWidth:=GetGLProcAddress('LineWidth');
    glListBase:=GetGLProcAddress('ListBase');
    glLoadIdentity:=GetGLProcAddress('LoadIdentity');
    glLoadMatrixd:=GetGLProcAddress('LoadMatrixd');
    glLoadMatrixf:=GetGLProcAddress('LoadMatrixf');
    glLoadName:=GetGLProcAddress('LoadName');
    glLogicOp:=GetGLProcAddress('LogicOp');
    glMap1d:=GetGLProcAddress('Map1d');
    glMap1f:=GetGLProcAddress('Map1f');
    glMap2d:=GetGLProcAddress('Map2d');
    glMap2f:=GetGLProcAddress('Map2f');
    glMapGrid1d:=GetGLProcAddress('MapGrid1d');
    glMapGrid1f:=GetGLProcAddress('MapGrid1f');
    glMapGrid2d:=GetGLProcAddress('MapGrid2d');
    glMapGrid2f:=GetGLProcAddress('MapGrid2f');
    glMaterialf:=GetGLProcAddress('Materialf');
    glMaterialfv:=GetGLProcAddress('Materialfv');
    glMateriali:=GetGLProcAddress('Materiali');
    glMaterialiv:=GetGLProcAddress('Materialiv');
    glMatrixMode:=GetGLProcAddress('MatrixMode');
    glMultMatrixd:=GetGLProcAddress('MultMatrixd');
    glMultMatrixf:=GetGLProcAddress('MultMatrixf');
    glNewList:=GetGLProcAddress('NewList');
    glNormal3b:=GetGLProcAddress('Normal3b');
    glNormal3bv:=GetGLProcAddress('Normal3bv');
    glNormal3d:=GetGLProcAddress('Normal3d');
    glNormal3dv:=GetGLProcAddress('Normal3dv');
    glNormal3f:=GetGLProcAddress('Normal3f');
    glNormal3fv:=GetGLProcAddress('Normal3fv');
    glNormal3i:=GetGLProcAddress('Normal3i');
    glNormal3iv:=GetGLProcAddress('Normal3iv');
    glNormal3s:=GetGLProcAddress('Normal3s');
    glNormal3sv:=GetGLProcAddress('Normal3sv');
    glNormalPointer:=GetGLProcAddress('NormalPointer');
    glOrtho:=GetGLProcAddress('Ortho');
    glPassThrough:=GetGLProcAddress('PassThrough');
    glPixelMapfv:=GetGLProcAddress('PixelMapfv');
    glPixelMapuiv:=GetGLProcAddress('PixelMapuiv');
    glPixelMapusv:=GetGLProcAddress('PixelMapusv');
    glPixelStoref:=GetGLProcAddress('PixelStoref');
    glPixelStorei:=GetGLProcAddress('PixelStorei');
    glPixelTransferf:=GetGLProcAddress('PixelTransferf');
    glPixelTransferi:=GetGLProcAddress('PixelTransferi');
    glPixelZoom:=GetGLProcAddress('PixelZoom');
    glPointSize:=GetGLProcAddress('PointSize');
    glPolygonMode:=GetGLProcAddress('PolygonMode');
    glPolygonOffset:=GetGLProcAddress('PolygonOffset');
    glPolygonStipple:=GetGLProcAddress('PolygonStipple');
    glPopAttrib:=GetGLProcAddress('PopAttrib');
    glPopClientAttrib:=GetGLProcAddress('PopClientAttrib');
    glPopMatrix:=GetGLProcAddress('PopMatrix');
    glPopName:=GetGLProcAddress('PopName');
    glPrioritizeTextures:=GetGLProcAddress('PrioritizeTextures');
    glPushAttrib:=GetGLProcAddress('PushAttrib');
    glPushClientAttrib:=GetGLProcAddress('PushClientAttrib');
    glPushMatrix:=GetGLProcAddress('PushMatrix');
    glPushName:=GetGLProcAddress('PushName');
    glRasterPos2d:=GetGLProcAddress('RasterPos2d');
    glRasterPos2dv:=GetGLProcAddress('RasterPos2dv');
    glRasterPos2f:=GetGLProcAddress('RasterPos2f');
    glRasterPos2fv:=GetGLProcAddress('RasterPos2fv');
    glRasterPos2i:=GetGLProcAddress('RasterPos2i');
    glRasterPos2iv:=GetGLProcAddress('RasterPos2iv');
    glRasterPos2s:=GetGLProcAddress('RasterPos2s');
    glRasterPos2sv:=GetGLProcAddress('RasterPos2sv');
    glRasterPos3d:=GetGLProcAddress('RasterPos3d');
    glRasterPos3dv:=GetGLProcAddress('RasterPos3dv');
    glRasterPos3f:=GetGLProcAddress('RasterPos3f');
    glRasterPos3fv:=GetGLProcAddress('RasterPos3fv');
    glRasterPos3i:=GetGLProcAddress('RasterPos3i');
    glRasterPos3iv:=GetGLProcAddress('RasterPos3iv');
    glRasterPos3s:=GetGLProcAddress('RasterPos3s');
    glRasterPos3sv:=GetGLProcAddress('RasterPos3sv');
    glRasterPos4d:=GetGLProcAddress('RasterPos4d');
    glRasterPos4dv:=GetGLProcAddress('RasterPos4dv');
    glRasterPos4f:=GetGLProcAddress('RasterPos4f');
    glRasterPos4fv:=GetGLProcAddress('RasterPos4fv');
    glRasterPos4i:=GetGLProcAddress('RasterPos4i');
    glRasterPos4iv:=GetGLProcAddress('RasterPos4iv');
    glRasterPos4s:=GetGLProcAddress('RasterPos4s');
    glRasterPos4sv:=GetGLProcAddress('RasterPos4sv');
    glReadBuffer:=GetGLProcAddress('ReadBuffer');
    glReadPixels:=GetGLProcAddress('ReadPixels');
    glRectd:=GetGLProcAddress('Rectd');
    glRectdv:=GetGLProcAddress('Rectdv');
    glRectf:=GetGLProcAddress('Rectf');
    glRectfv:=GetGLProcAddress('Rectfv');
    glRecti:=GetGLProcAddress('Recti');
    glRectiv:=GetGLProcAddress('Rectiv');
    glRects:=GetGLProcAddress('Rects');
    glRectsv:=GetGLProcAddress('Rectsv');
    glRenderMode:=GetGLProcAddress('RenderMode');
    glRotated:=GetGLProcAddress('Rotated');
    glRotatef:=GetGLProcAddress('Rotatef');
    glScaled:=GetGLProcAddress('Scaled');
    glScalef:=GetGLProcAddress('Scalef');
    glScissor:=GetGLProcAddress('Scissor');
    glSelectBuffer:=GetGLProcAddress('SelectBuffer');
    glShadeModel:=GetGLProcAddress('ShadeModel');
    glStencilFunc:=GetGLProcAddress('StencilFunc');
    glStencilMask:=GetGLProcAddress('StencilMask');
    glStencilOp:=GetGLProcAddress('StencilOp');
    glTexCoord1d:=GetGLProcAddress('TexCoord1d');
    glTexCoord1dv:=GetGLProcAddress('TexCoord1dv');
    glTexCoord1f:=GetGLProcAddress('TexCoord1f');
    glTexCoord1fv:=GetGLProcAddress('TexCoord1fv');
    glTexCoord1i:=GetGLProcAddress('TexCoord1i');
    glTexCoord1iv:=GetGLProcAddress('TexCoord1iv');
    glTexCoord1s:=GetGLProcAddress('TexCoord1s');
    glTexCoord1sv:=GetGLProcAddress('TexCoord1sv');
    glTexCoord2d:=GetGLProcAddress('TexCoord2d');
    glTexCoord2dv:=GetGLProcAddress('TexCoord2dv');
    glTexCoord2f:=GetGLProcAddress('TexCoord2f');
    glTexCoord2fv:=GetGLProcAddress('TexCoord2fv');
    glTexCoord2i:=GetGLProcAddress('TexCoord2i');
    glTexCoord2iv:=GetGLProcAddress('TexCoord2iv');
    glTexCoord2s:=GetGLProcAddress('TexCoord2s');
    glTexCoord2sv:=GetGLProcAddress('TexCoord2sv');
    glTexCoord3d:=GetGLProcAddress('TexCoord3d');
    glTexCoord3dv:=GetGLProcAddress('TexCoord3dv');
    glTexCoord3f:=GetGLProcAddress('TexCoord3f');
    glTexCoord3fv:=GetGLProcAddress('TexCoord3fv');
    glTexCoord3i:=GetGLProcAddress('TexCoord3i');
    glTexCoord3iv:=GetGLProcAddress('TexCoord3iv');
    glTexCoord3s:=GetGLProcAddress('TexCoord3s');
    glTexCoord3sv:=GetGLProcAddress('TexCoord3sv');
    glTexCoord4d:=GetGLProcAddress('TexCoord4d');
    glTexCoord4dv:=GetGLProcAddress('TexCoord4dv');
    glTexCoord4f:=GetGLProcAddress('TexCoord4f');
    glTexCoord4fv:=GetGLProcAddress('TexCoord4fv');
    glTexCoord4i:=GetGLProcAddress('TexCoord4i');
    glTexCoord4iv:=GetGLProcAddress('TexCoord4iv');
    glTexCoord4s:=GetGLProcAddress('TexCoord4s');
    glTexCoord4sv:=GetGLProcAddress('TexCoord4sv');
    glTexCoordPointer:=GetGLProcAddress('TexCoordPointer');
    glTexEnvf:=GetGLProcAddress('TexEnvf');
    glTexEnvfv:=GetGLProcAddress('TexEnvfv');
    glTexEnvi:=GetGLProcAddress('TexEnvi');
    glTexEnviv:=GetGLProcAddress('TexEnviv');
    glTexGend:=GetGLProcAddress('TexGend');
    glTexGendv:=GetGLProcAddress('TexGendv');
    glTexGenf:=GetGLProcAddress('TexGenf');
    glTexGenfv:=GetGLProcAddress('TexGenfv');
    glTexGeni:=GetGLProcAddress('TexGeni');
    glTexGeniv:=GetGLProcAddress('TexGeniv');
    glTexImage1D:=GetGLProcAddress('TexImage1D');
    glTexImage2D:=GetGLProcAddress('TexImage2D');
    glTexParameterf:=GetGLProcAddress('TexParameterf');
    glTexParameterfv:=GetGLProcAddress('TexParameterfv');
    glTexParameteri:=GetGLProcAddress('TexParameteri');
    glTexParameteriv:=GetGLProcAddress('TexParameteriv');
    glTexSubImage1D:=GetGLProcAddress('TexSubImage1D');
    glTexSubImage2D:=GetGLProcAddress('TexSubImage2D');
    glTranslated:=GetGLProcAddress('Translated');
    glTranslatef:=GetGLProcAddress('Translatef');
    glVertex2d:=GetGLProcAddress('Vertex2d');
    glVertex2dv:=GetGLProcAddress('Vertex2dv');
    glVertex2f:=GetGLProcAddress('Vertex2f');
    glVertex2fv:=GetGLProcAddress('Vertex2fv');
    glVertex2i:=GetGLProcAddress('Vertex2i');
    glVertex2iv:=GetGLProcAddress('Vertex2iv');
    glVertex2s:=GetGLProcAddress('Vertex2s');
    glVertex2sv:=GetGLProcAddress('Vertex2sv');
    glVertex3d:=GetGLProcAddress('Vertex3d');
    glVertex3dv:=GetGLProcAddress('Vertex3dv');
    glVertex3f:=GetGLProcAddress('Vertex3f');
    glVertex3fv:=GetGLProcAddress('Vertex3fv');
    glVertex3i:=GetGLProcAddress('Vertex3i');
    glVertex3iv:=GetGLProcAddress('Vertex3iv');
    glVertex3s:=GetGLProcAddress('Vertex3s');
    glVertex3sv:=GetGLProcAddress('Vertex3sv');
    glVertex4d:=GetGLProcAddress('Vertex4d');
    glVertex4dv:=GetGLProcAddress('Vertex4dv');
    glVertex4f:=GetGLProcAddress('Vertex4f');
    glVertex4fv:=GetGLProcAddress('Vertex4fv');
    glVertex4i:=GetGLProcAddress('Vertex4i');
    glVertex4iv:=GetGLProcAddress('Vertex4iv');
    glVertex4s:=GetGLProcAddress('Vertex4s');
    glVertex4sv:=GetGLProcAddress('Vertex4sv');
    glVertexPointer:=GetGLProcAddress('VertexPointer');
    glViewport:=GetGLProcAddress('Viewport');
    wglGetProcAddress:=GetProcAddress(GLHandle, 'wglGetProcAddress');
    // GL 1.2
    glDrawRangeElements:=GetGLProcAddress('DrawRangeElements');
    glTexImage3D:=GetGLProcAddress('TexImage3D');
    // GL 1.2 ARB imaging
    glBlendColor:=GetGLProcAddress('BlendColor');
    glBlendEquation:=GetGLProcAddress('BlendEquation');
    glColorSubTable:=GetGLProcAddress('ColorSubTable');
    glCopyColorSubTable:=GetGLProcAddress('CopyColorSubTable');
    glColorTable:=GetGLProcAddress('CopyColorSubTable');
    glCopyColorTable:=GetGLProcAddress('CopyColorTable');
    glColorTableParameteriv:=GetGLProcAddress('ColorTableParameteriv');
    glColorTableParameterfv:=GetGLProcAddress('ColorTableParameterfv');
    glGetColorTable:=GetGLProcAddress('GetColorTable');
    glGetColorTableParameteriv:=GetGLProcAddress('GetColorTableParameteriv');
    glGetColorTableParameterfv:=GetGLProcAddress('GetColorTableParameterfv');
    glConvolutionFilter1D:=GetGLProcAddress('ConvolutionFilter1D');
    glConvolutionFilter2D:=GetGLProcAddress('ConvolutionFilter2D');
    glCopyConvolutionFilter1D:=GetGLProcAddress('CopyConvolutionFilter1D');
    glCopyConvolutionFilter2D:=GetGLProcAddress('CopyConvolutionFilter2D');
    glGetConvolutionFilter:=GetGLProcAddress('GetConvolutionFilter');
    glSeparableFilter2D:=GetGLProcAddress('SeparableFilter2D');
    glGetSeparableFilter:=GetGLProcAddress('GetSeparableFilter');
    glConvolutionParameteri:=GetGLProcAddress('ConvolutionParameteri');
    glConvolutionParameteriv:=GetGLProcAddress('ConvolutionParameteriv');
    glConvolutionParameterf:=GetGLProcAddress('ConvolutionParameterf');
    glConvolutionParameterfv:=GetGLProcAddress('ConvolutionParameterfv');
    glGetConvolutionParameteriv:=GetGLProcAddress('GetConvolutionParameteriv');
    glGetConvolutionParameterfv:=GetGLProcAddress('GetConvolutionParameterfv');
    glHistogram:=GetGLProcAddress('Histogram');
    glResetHistogram:=GetGLProcAddress('ResetHistogram');
    glGetHistogram:=GetGLProcAddress('GetHistogram');
    glGetHistogramParameteriv:=GetGLProcAddress('GetHistogramParameteriv');
    glGetHistogramParameterfv:=GetGLProcAddress('GetHistogramParameterfv');
    glMinmax:=GetGLProcAddress('Minmax');
    glResetMinmax:=GetGLProcAddress('ResetMinmax');
    glGetMinmax:=GetGLProcAddress('GetMinmax');
    glGetMinmaxParameteriv:=GetGLProcAddress('GetMinmaxParameteriv');
    glGetMinmaxParameterfv:=GetGLProcAddress('GetMinmaxParameterfv');
  end;

  if GLUHandle > 0 then
  begin
    gluBeginCurve:=GetGLUProcAddress('BeginCurve');
    gluBeginPolygon:=GetGLUProcAddress('BeginPolygon');
    gluBeginSurface:=GetGLUProcAddress('BeginSurface');
    gluBeginTrim:=GetGLUProcAddress('BeginTrim');
    gluBuild1DMipmaps:=GetGLUProcAddress('Build1DMipmaps');
    gluBuild2DMipmaps:=GetGLUProcAddress('Build2DMipmaps');
    gluCylinder:=GetGLUProcAddress('Cylinder');
    gluDeleteNurbsRenderer:=GetGLUProcAddress('DeleteNurbsRenderer');
    gluDeleteQuadric:=GetGLUProcAddress('DeleteQuadric');
    gluDeleteTess:=GetGLUProcAddress('DeleteTess');
    gluDisk:=GetGLUProcAddress('Disk');
    gluEndCurve:=GetGLUProcAddress('EndCurve');
    gluEndPolygon:=GetGLUProcAddress('EndPolygon');
    gluEndSurface:=GetGLUProcAddress('EndSurface');
    gluEndTrim:=GetGLUProcAddress('EndTrim');
    gluErrorString:=GetGLUProcAddress('ErrorString');
    gluGetNurbsProperty:=GetGLUProcAddress('GetNurbsProperty');
    gluGetString:=GetGLUProcAddress('GetString');
    gluGetTessProperty:=GetGLUProcAddress('GetTessProperty');
    gluLoadSamplingMatrices:=GetGLUProcAddress('LoadSamplingMatrices');
    gluLookAt:=GetGLUProcAddress('LookAt');
    gluNewNurbsRenderer:=GetGLUProcAddress('NewNurbsRenderer');
    gluNewQuadric:=GetGLUProcAddress('NewQuadric');
    gluNewTess:=GetGLUProcAddress('NewTess');
    gluNextContour:=GetGLUProcAddress('NextContour');
    gluNurbsCallback:=GetGLUProcAddress('NurbsCallback');
    gluNurbsCurve:=GetGLUProcAddress('NurbsCurve');
    gluNurbsProperty:=GetGLUProcAddress('NurbsProperty');
    gluNurbsSurface:=GetGLUProcAddress('NurbsSurface');
    gluOrtho2D:=GetGLUProcAddress('Ortho2D');
    gluPartialDisk:=GetGLUProcAddress('PartialDisk');
    gluPerspective:=GetGLUProcAddress('Perspective');
    gluPickMatrix:=GetGLUProcAddress('PickMatrix');
    gluProject:=GetGLUProcAddress('Project');
    gluPwlCurve:=GetGLUProcAddress('PwlCurve');
    gluQuadricCallback:=GetGLUProcAddress('QuadricCallback');
    gluQuadricDrawStyle:=GetGLUProcAddress('QuadricDrawStyle');
    gluQuadricNormals:=GetGLUProcAddress('QuadricNormals');
    gluQuadricOrientation:=GetGLUProcAddress('QuadricOrientation');
    gluQuadricTexture:=GetGLUProcAddress('QuadricTexture');
    gluScaleImage:=GetGLUProcAddress('ScaleImage');
    gluSphere:=GetGLUProcAddress('Sphere');
    gluTessBeginContour:=GetGLUProcAddress('TessBeginContour');
    gluTessBeginPolygon:=GetGLUProcAddress('TessBeginPolygon');
    gluTessCallback:=GetGLUProcAddress('TessCallback');
    gluTessEndContour:=GetGLUProcAddress('TessEndContour');
    gluTessEndPolygon:=GetGLUProcAddress('TessEndPolygon');
    gluTessNormal:=GetGLUProcAddress('TessNormal');
    gluTessProperty:=GetGLUProcAddress('TessProperty');
    gluTessVertex:=GetGLUProcAddress('TessVertex');
    gluUnProject:=GetGLUProcAddress('UnProject');
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ClearExtensions;

begin
{  glArrayElementEXT:=nil;
  glDrawArraysEXT:=nil;
  glVertexPointerEXT:=nil;
  glNormalPointerEXT:=nil;
  glColorPointerEXT:=nil;
  glIndexPointerEXT:=nil;
  glTexCoordPointerEXT:=nil;
  glEdgeFlagPointerEXT:=nil;
  glGetPointervEXT:=nil;
  glArrayElementArrayEXT:=nil;
  glAddSwapHintRectWIN:=nil;
  glColorTableEXT:=nil;
  glColorSubTableEXT:=nil;
  glGetColorTableEXT:=nil;
  glGetColorTablePameterivEXT:=nil;
  glGetColorTablePameterfvEXT:=nil;
  gluNurbsCallbackDataEXT:=nil;
  gluNewNurbsTessellatorEXT:=nil;
  gluDeleteNurbsTessellatorEXT:=nil;
  glLockArraysEXT:=nil;
  glUnlockArraysEXT:=nil;
  glCopyTexImage1DEXT:=nil;
  glCopyTexSubImage1DEXT:=nil;
  glCopyTexImage2DEXT:=nil;
  glCopyTexSubImage2DEXT:=nil;
  glCopyTexSubImage3DEXT:=nil;
  glCullParameterfvEXT:=nil;
  glCullParameterdvEXT:=nil;
  glIndexFuncEXT:=nil;
  glIndexMaterialEXT:=nil;
  glPolygonOffsetEXT:=nil;
  glTexSubImage1DEXT:=nil;
  glTexSubImage2DEXT:=nil;
  glTexSubImage3DEXT:=nil;
  glGenTexturesEXT:=nil;
  glDeleteTexturesEXT:=nil;
  glBindTextureEXT:=nil;
  glPrioritizeTexturesEXT:=nil;
  glAreTexturesResidentEXT:=nil;
  glIsTextureEXT:=nil;
}
  LastPixelFormat:=0; // to get synchronized again, if this proc was called from outside
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ReadExtensions;

// to be used in an active rendering context only!

begin
  // GL extensions
  glArrayElementEXT:=wglGetProcAddress('glArrayElementEXT');
  glDrawArraysEXT:=wglGetProcAddress('glDrawArraysEXT');
  glVertexPointerEXT:=wglGetProcAddress('glVertexPointerEXT');
  glNormalPointerEXT:=wglGetProcAddress('glNormalPointerEXT');
  glColorPointerEXT:=wglGetProcAddress('glColorPointerEXT');
  glIndexPointerEXT:=wglGetProcAddress('glIndexPointerEXT');
  glTexCoordPointerEXT:=wglGetProcAddress('glTexCoordPointerEXT');
  glEdgeFlagPointerEXT:=wglGetProcAddress('glEdgeFlagPointerEXT');
  glGetPointervEXT:=wglGetProcAddress('glGetPointervEXT');
  glArrayElementArrayEXT:=wglGetProcAddress('glArrayElementArrayEXT');
  glAddSwapHintRectWIN:=wglGetProcAddress('glAddSwapHintRectWIN');
  glColorTableEXT:=wglGetProcAddress('glColorTableEXT');
  glColorSubTableEXT:=wglGetProcAddress('glColorSubTableEXT');
  glGetColorTableEXT:=wglGetProcAddress('glGetColorTableEXT');
  glGetColorTablePameterivEXT:=wglGetProcAddress('glGetColorTablePameterivEXT');
  glGetColorTablePameterfvEXT:=wglGetProcAddress('glGetColorTablePameterfvEXT');
  glLockArraysEXT:=wglGetProcAddress('glLockArraysEXT');
  glUnlockArraysEXT:=wglGetProcAddress('glUnlockArraysEXT');
  glCopyTexImage1DEXT:=wglGetProcAddress('glCopyTexImage1DEXT');
  glCopyTexSubImage1DEXT:=wglGetProcAddress('glCopyTexSubImage1DEXT');
  glCopyTexImage2DEXT:=wglGetProcAddress('glCopyTexImage2DEXT');
  glCopyTexSubImage2DEXT:=wglGetProcAddress('glCopyTexSubImage2DEXT');
  glCopyTexSubImage3DEXT:=wglGetProcAddress('glCopyTexSubImage3DEXT');
  glCullParameterfvEXT:=wglGetProcAddress('glCullParameterfvEXT');
  glCullParameterdvEXT:=wglGetProcAddress('glCullParameterdvEXT');
  glIndexFuncEXT:=wglGetProcAddress('glIndexFuncEXT');
  glIndexMaterialEXT:=wglGetProcAddress('glIndexMaterialEXT');
  glPolygonOffsetEXT:=wglGetProcAddress('glPolygonOffsetEXT');
  glTexSubImage1dEXT:=wglGetProcAddress('glTexSubImage1DEXT');
  glTexSubImage2dEXT:=wglGetProcAddress('glTexSubImage2DEXT');
  glTexSubImage3dEXT:=wglGetProcAddress('glTexSubImage3DEXT');
  glGenTexturesEXT:=wglGetProcAddress('glGenTexturesEXT');
  glDeleteTexturesEXT:=wglGetProcAddress('glDeleteTexturesEXT');
  glBindTextureEXT:=wglGetProcAddress('glBindTextureEXT');
  glPrioritizeTexturesEXT:=wglGetProcAddress('glPrioritizeTexturesEXT');
  glAreTexturesResidentEXT:=wglGetProcAddress('glAreTexturesResidentEXT');
  glIsTextureEXT:=wglGetProcAddress('glIsTextureEXT');

  // EXT_vertex_array
  glArrayElementEXT:=wglGetProcAddress('glArrayElementEXT');
  glColorPointerEXT:=wglGetProcAddress('glColorPointerEXT');
  glDrawArraysEXT:=wglGetProcAddress('glDrawArraysEXT');
  glEdgeFlagPointerEXT:=wglGetProcAddress('glEdgeFlagPointerEXT');
  glGetPointervEXT:=wglGetProcAddress('glGetPointervEXT');
  glIndexPointerEXT:=wglGetProcAddress('glIndexPointerEXT');
  glNormalPointerEXT:=wglGetProcAddress('glNormalPointerEXT');
  glTexCoordPointerEXT:=wglGetProcAddress('glTexCoordPointerEXT');
  glVertexPointerEXT:=wglGetProcAddress('glVertexPointerEXT');

  // ARB_multitexture
  glMultiTexCoord1dARB:=wglGetProcAddress('glMultiTexCoord1dARB');
  glMultiTexCoord1dVARB:=wglGetProcAddress('glMultiTexCoord1dVARB');
  glMultiTexCoord1fARBP:=wglGetProcAddress('glMultiTexCoord1fARBP');
  glMultiTexCoord1fVARB:=wglGetProcAddress('glMultiTexCoord1fVARB');
  glMultiTexCoord1iARB:=wglGetProcAddress('glMultiTexCoord1iARB');
  glMultiTexCoord1iVARB:=wglGetProcAddress('glMultiTexCoord1iVARB');
  glMultiTexCoord1sARBP:=wglGetProcAddress('glMultiTexCoord1sARBP');
  glMultiTexCoord1sVARB:=wglGetProcAddress('glIsTextureEXT');
  glMultiTexCoord2dARB:=wglGetProcAddress('glMultiTexCoord2dARB');
  glMultiTexCoord2dvARB:=wglGetProcAddress('glMultiTexCoord2dvARB');
  glMultiTexCoord2fARB:=wglGetProcAddress('glMultiTexCoord2fARB');
  glMultiTexCoord2fvARB:=wglGetProcAddress('glMultiTexCoord2fvARB');
  glMultiTexCoord2iARB:=wglGetProcAddress('glMultiTexCoord2iARB');
  glMultiTexCoord2ivARB:=wglGetProcAddress('glMultiTexCoord2ivARB');
  glMultiTexCoord2sARB:=wglGetProcAddress('glMultiTexCoord2sARB');
  glMultiTexCoord2svARB:=wglGetProcAddress('glMultiTexCoord2svARB');
  glMultiTexCoord3dARB:=wglGetProcAddress('glMultiTexCoord3dARB');
  glMultiTexCoord3dvARB:=wglGetProcAddress('glMultiTexCoord3dvARB');
  glMultiTexCoord3fARB:=wglGetProcAddress('glMultiTexCoord3fARB');
  glMultiTexCoord3fvARB:=wglGetProcAddress('glMultiTexCoord3fvARB');
  glMultiTexCoord3iARB:=wglGetProcAddress('glMultiTexCoord3iARB');
  glMultiTexCoord3ivARB:=wglGetProcAddress('glMultiTexCoord3ivARB');
  glMultiTexCoord3sARB:=wglGetProcAddress('glMultiTexCoord3sARB');
  glMultiTexCoord3svARB:=wglGetProcAddress('glMultiTexCoord3svARB');
  glMultiTexCoord4dARB:=wglGetProcAddress('glMultiTexCoord4dARB');
  glMultiTexCoord4dvARB:=wglGetProcAddress('glMultiTexCoord4dvARB');
  glMultiTexCoord4fARB:=wglGetProcAddress('glMultiTexCoord4fARB');
  glMultiTexCoord4fvARB:=wglGetProcAddress('glMultiTexCoord4fvARB');
  glMultiTexCoord4iARB:=wglGetProcAddress('glMultiTexCoord4iARB');
  glMultiTexCoord4ivARB:=wglGetProcAddress('glMultiTexCoord4ivARB');
  glMultiTexCoord4sARB:=wglGetProcAddress('glMultiTexCoord4sARB');
  glMultiTexCoord4svARB:=wglGetProcAddress('glMultiTexCoord4svARB');
  glActiveTextureARB:=wglGetProcAddress('glActiveTextureARB');
  glClientActiveTextureARB:=wglGetProcAddress('glClientActiveTextureARB');

  // EXT_compiled_vertex_array
  glLockArrayEXT:=wglGetProcAddress('glLockArrayEXT');
  glUnlockArrayEXT:=wglGetProcAddress('glUnlockArrayEXT');

  // EXT_cull_vertex
  glCullParameterdvEXT:=wglGetProcAddress('glCullParameterdvEXT');
  glCullParameterfvEXT:=wglGetProcAddress('glCullParameterfvEXT');

  // WIN_swap_hint
  glAddSwapHintRectWIN:=wglGetProcAddress('glAddSwapHintRectWIN');

  // EXT_point_parameter
  glPointParameterfEXT:=wglGetProcAddress('glPointParameterfEXT');
  glPointParameterfvEXT:=wglGetProcAddress('glPointParameterfvEXT');

  // GLU extensions
  gluNurbsCallbackDataEXT:=wglGetProcAddress('gluNurbsCallbackDataEXT');
  gluNewNurbsTessellatorEXT:=wglGetProcAddress('gluNewNurbsTessellatorEXT');
  gluDeleteNurbsTessellatorEXT:=wglGetProcAddress('gluDeleteNurbsTessellatorEXT');

  // to get synchronized again, if this proc was called externally
  LastPixelFormat:=0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TrimAndSplitVersionString(Buffer: String; var Max, Min: Integer);

// peel out the X.Y form

var
  Separator: Integer;

begin
  try
    // there must be at least one dot to separate major and minor version number
    Separator:=Pos('.', Buffer);
    // at least one number must be before and one after the dot
    if (Separator > 1) and (Separator < Length(Buffer) - 1) and
       (Buffer[Separator - 1] in ['0'..'9']) and (Buffer[Separator + 1] in ['0'..'9']) then
    begin
      // ok, it's a valid version string, now remove unnecessary parts
      Dec(Separator);
      // find last non-numeric character before version number
      while (Separator > 0) and (Buffer[Separator] in ['0'..'9']) do Dec(Separator);
      // delete leading characters not belonging to the version string
      Delete(Buffer, 1, Separator);
      Separator:=Pos('.', Buffer) + 1;
      // find first non-numeric character after version number
      while (Separator <= Length(Buffer)) and (Buffer[Separator] in ['0'..'9']) do Inc(Separator);
      // delete trailing characters not belonging to the version string
      Delete(Buffer, Separator, 255);
      // now translate the numbers
      Separator:=Pos('.', Buffer); // necessary, because the buffer length may be changed
      Max:=StrToInt(Copy(Buffer, 1, Separator - 1));
      Min:=StrToInt(Copy(Buffer, Separator + 1, 255));
    end
    else Abort;
  except
    Min:=0;
    Max:=0;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ReadImplementationProperties;
var
   Buffer: String;
   MajorVersion, MinorVersion: Integer;

   function CheckExtension(const extName : String) : Boolean; register;
   begin
      Result:=(Pos('GL_EXT_abgr', Buffer) > 0);
   end;

begin
  // determine version of implementation
  // GL
  Buffer:=glGetString(GL_VERSION);
  TrimAndSplitVersionString(Buffer, Majorversion, MinorVersion);
  GL_VERSION_1_0:=True;
  GL_VERSION_1_1:=False;
  GL_VERSION_1_2:=False;
  if MajorVersion > 0 then begin
    if MinorVersion > 0 then begin
      GL_VERSION_1_1:=True;
      if MinorVersion > 1 then GL_VERSION_1_2:=True;
    end;
  end;
  // GLU
  GLU_VERSION_1_1:=False;
  GLU_VERSION_1_2:=False;
  GLU_VERSION_1_3:=False;
  // gluGetString is valid for version 1.1 or later
  if assigned(gluGetString) then begin
    Buffer:=gluGetString(GLU_VERSION);
    TrimAndSplitVersionString(Buffer, Majorversion, MinorVersion);
    GLU_VERSION_1_1:=True;
    if MinorVersion > 1 then begin
      GLU_VERSION_1_2:=True;
      if MinorVersion > 2 then GLU_VERSION_1_3:=True;
    end;
  end;

  // check supported extensions
  // GL
  Buffer:=glGetString(GL_EXTENSIONS);
  GL_EXT_abgr:=CheckExtension('GL_EXT_abgr');
  GL_EXT_bgra:=CheckExtension('GL_EXT_bgra');
  GL_EXT_packed_pixels:=CheckExtension('GL_EXT_packed_pixels');
  GL_EXT_paletted_texture:=CheckExtension('GL_EXT_paletted_texture');
  GL_EXT_vertex_array:=CheckExtension('GL_EXT_vertex_array');
  GL_EXT_index_array_formats:=CheckExtension('GL_EXT_index_array_formats');
  GL_EXT_index_func:=CheckExtension('GL_EXT_index_func');
  GL_EXT_index_material:=CheckExtension('GL_EXT_index_material');
  GL_EXT_index_texture:=CheckExtension('GL_EXT_index_texture');
  GL_WIN_swap_hint:=CheckExtension('GL_WIN_swap_hint');
  GL_EXT_blend_color:=CheckExtension('GL_EXT_blend_color');
  GL_EXT_blend_logic_op:=CheckExtension('GL_EXT_blend_logic_op');
  GL_EXT_blend_minmax:=CheckExtension('GL_EXT_blend_minmax');
  GL_EXT_blend_subtract:=CheckExtension('GL_EXT_blend_subtract');
  GL_EXT_convolution:=CheckExtension('GL_EXT_convolution');
  GL_EXT_copy_texture:=CheckExtension('GL_EXT_copy_texture');
  GL_EXT_histogram:=CheckExtension('GL_EXT_histogram');
  GL_EXT_polygon_offset:=CheckExtension('GL_EXT_polygon_offset');
  GL_EXT_subtexture:=CheckExtension('GL_EXT_subtexture');
  GL_EXT_texture_object:=CheckExtension('GL_EXT_texture_object');
  GL_EXT_texture3D:=CheckExtension('GL_EXT_texture3D');
  GL_EXT_cmyka:=CheckExtension('GL_EXT_cmyka');
  GL_EXT_rescale_normal:=CheckExtension('GL_EXT_rescale_normal');
  GL_SGI_color_matrix:=CheckExtension('GL_SGI_color_matrix');
  GL_EXT_texture_color_table:=CheckExtension('GL_EXT_texture_color_table');
  GL_SGI_color_table:=CheckExtension('GL_SGI_color_table');
  GL_EXT_clip_volume_hint:=CheckExtension('GL_EXT_clip_volume_hint');
  GL_EXT_compiled_vertex_array:=CheckExtension('GL_EXT_compiled_vertex_array');
  GL_EXT_cull_vertex:=CheckExtension('GL_EXT_cull_vertex');
  GL_EXT_point_parameters:=CheckExtension('GL_EXT_point_parameters');
  GL_EXT_texture_env_add:=CheckExtension('GL_EXT_texture_env_add');
  GL_EXT_misc_attribute:=CheckExtension('GL_EXT_misc_attribute');
  GL_EXT_scene_marker:=CheckExtension('GL_EXT_scene_marker');
  GL_EXT_shared_texture_palette:=CheckExtension('GL_EXT_shared_texture_palette');
  GL_EXT_texture_env_combine:=CheckExtension('GL_EXT_texture_env_combine');
  GL_NV_texgen_reflection:=CheckExtension('GL_NV_texgen_reflection');
  GL_NV_texture_env_combine4:=CheckExtension('GL_NV_texture_env_combine4');
  GL_ARB_multitexture:=CheckExtension('GL_ARB_multitexture');
  GL_ARB_imaging:=CheckExtension('GL_ARB_imaging');

  GL_EXT_fog_coord:=CheckExtension('GL_EXT_fog_coord');
  GL_EXT_light_max_exponent:=CheckExtension('GL_EXT_light_max_exponent');
  GL_EXT_secondary_color:=CheckExtension('GL_EXT_secondary_color');
  GL_EXT_separate_specular_color:=CheckExtension('GL_EXT_separate_specular_color');
  GL_EXT_stencil_wrap:=CheckExtension('GL_EXT_stencil_wrap');
  GL_EXT_texture_cube_map:=CheckExtension('GL_EXT_texture_cube_map');
  GL_EXT_texture_filter_anisotropic:=CheckExtension('GL_EXT_texture_filter_anisotropic');
  GL_EXT_texture_lod_bias:=CheckExtension('GL_EXT_texture_lod_bias');
  GL_EXT_vertex_weighting:=CheckExtension('GL_EXT_vertex_weighting');
  GL_KTX_buffer_region:=CheckExtension('GL_KTX_buffer_region');
  GL_NV_blend_square:=CheckExtension('GL_NV_blend_square');
  GL_NV_fog_distance:=CheckExtension('GL_NV_fog_distance');
  GL_NV_register_combiners:=CheckExtension('GL_NV_register_combiners');
  GL_NV_texgen_emboss:=CheckExtension('GL_NV_texgen_emboss');
  GL_NV_vertex_array_range:=CheckExtension('GL_NV_vertex_array_range');
  GL_SGIS_multitexture:=CheckExtension('GL_SGIS_multitexture');
  GL_SGIS_texture_lod:=CheckExtension('GL_SGIS_texture_lod');
  WGL_EXT_swap_control:=CheckExtension('WGL_EXT_swap_control');

  // GLU
  Buffer:=gluGetString(GLU_EXTENSIONS);
  GLU_EXT_TEXTURE:=CheckExtension('GLU_EXT_TEXTURE');
  GLU_EXT_object_space_tess:=CheckExtension('GLU_EXT_object_space_tess');
  GLU_EXT_nurbs_tessellator:=CheckExtension('GLU_EXT_nurbs_tessellator');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SetupPalette(DC: HDC; PFD: TPixelFormatDescriptor);

var
  nColors,
  I: Integer;
  LogPalette: TMaxLogPalette;
  RedMask,
  GreenMask,
  BlueMask: Byte;
  Palette: HPalette;

begin
  nColors:=1 shl Pfd.cColorBits;
  LogPalette.palVersion:=$300;
  LogPalette.palNumEntries:=nColors;
  RedMask:=(1 shl Pfd.cRedBits) - 1;
  GreenMask:=(1 shl Pfd.cGreenBits) - 1;
  BlueMask:=(1 shl Pfd.cBlueBits) - 1;
  with LogPalette, PFD do
    for I:=0 to nColors - 1 do
    begin
      palPalEntry[I].peRed:=(((I shr cRedShift) and RedMask) * 255) div RedMask;
      palPalEntry[I].peGreen:=(((I shr cGreenShift) and GreenMask) * 255) div GreenMask;
      palPalEntry[I].peBlue:=(((I shr cBlueShift) and BlueMask) * 255) div BlueMask;
      palPalEntry[I].peFlags:=0;
    end;

  Palette:=CreatePalette(PLogPalette(@LogPalette)^);
  if Palette <> 0 then
  begin
    SelectPalette(DC, Palette, False);
    RealizePalette(DC);
  end
  else RaiseLastWin32Error;
end;

//----------------------------------------------------------------------------------------------------------------------

function  CreateRenderingContext(DC: HDC; Options: TRCOptions; ColorBits, StencilBits, AccumBits, AuxBuffers: Integer;
  Layer: Integer): HGLRC;

// Set the OpenGL properties required to draw to the given canvas and
// create a rendering context for it.

const
  MemoryDCs = [OBJ_MEMDC, OBJ_METADC, OBJ_ENHMETADC];

var
  PFDescriptor: TPixelFormatDescriptor;
  PixelFormat: Integer;
  AType: DWORD;

begin
  FillChar(PFDescriptor, SizeOf(PFDescriptor), 0);
  with PFDescriptor do
  begin
    nSize:=SizeOf(PFDescriptor);
    nVersion:=1;
    dwFlags:=PFD_SUPPORT_OPENGL;
    AType:=GetObjectType(DC);
    if AType = 0 then RaiseLastWin32Error;
    if AType in MemoryDCs then dwFlags:=dwFlags or PFD_DRAW_TO_BITMAP
                          else dwFlags:=dwFlags or PFD_DRAW_TO_WINDOW;
    if opDoubleBuffered in Options then dwFlags:=dwFlags or PFD_DOUBLEBUFFER;
    if opGDI in Options then dwFlags:=dwFlags or PFD_SUPPORT_GDI;
    if opStereo in Options then dwFlags:=dwFlags or PFD_STEREO;
    iPixelType:=PFD_TYPE_RGBA;
    cColorBits:=ColorBits;
    cDepthBits:=32;
    cStencilBits:=StencilBits;
    cAccumBits:=AccumBits;
    cAuxBuffers:=AuxBuffers;
    if Layer = 0 then iLayerType:=PFD_MAIN_PLANE
                 else
      if Layer > 0 then iLayerType:=PFD_OVERLAY_PLANE
                   else iLayerType:=Byte(-1) {PFD_UNDERLAY_PLANE, only Inprise knows why they have declared
                                                an obvious Byte value as LongWord};
  end;

  // just in case it didn't happen already
  if not InitOpenGL then RaiseLastWin32Error;
  PixelFormat:=ChoosePixelFormat(DC, @PFDescriptor);
  if PixelFormat = 0 then RaiseLastWin32Error;
  // NOTE: It is not allowed to change a pixel format of a device context once it has been set.
  //       So cache DC and RC always somewhere to avoid re-setting the pixel format!
  if not SetPixelFormat(DC, PixelFormat, @PFDescriptor) then RaiseLastWin32Error;
  // check the properties just set
  DescribePixelFormat(DC, PixelFormat, SizeOf(PFDescriptor), PFDescriptor);
  with PFDescriptor do
    if (dwFlags and PFD_NEED_PALETTE) <> 0 then SetupPalette(DC, PFDescriptor);

  Result:=wglCreateLayerContext(DC, Layer);
  if Result = 0 then RaiseLastWin32Error
                else LastPixelFormat:=0;
end;

//----------------------------------------------------------------------------------------------------------------------

var
   vCurrentDC : HDC;
   vCurrentRC : HGLRC;
   vRCCount : Integer = 0;

procedure ActivateRenderingContext(DC: HDC; RC: HGLRC);
var
   PixelFormat: Integer;
begin
   Assert((DC<>0), 'ActivateRenderingContext : got DC=0');
   Assert((RC<>0), 'ActivateRenderingContext : got RC=0');
   if vRCCount=0 then begin
      vCurrentDC:=DC;
      vCurrentRC:=RC;
      Inc(vRCCount);
      // The extension function addresses are unique for each pixel format. All rendering
      // contexts of a given pixel format share the same extension function addresses.
      PixelFormat:=GetPixelFormat(DC);
      wglMakeCurrent(DC, RC);
      if PixelFormat<>LastPixelFormat then begin
         ClearExtensions;
         ReadImplementationProperties;
         ReadExtensions;
         LastPixelFormat:=PixelFormat;
      end;
   end else begin
      Assert((vCurrentDC=DC) and (vCurrentRC=RC), 'ActivateRenderingContext');
      Inc(vRCCount);
   end;
end;

procedure DeactivateRenderingContext;
begin
   if vRCCount=1 then begin
      vRCCount:=0;
      wglMakeCurrent(0, 0);
   end else begin
      Assert(vRCCount>1, 'DeactivateRenderingContext : unbalanced activations');
      Dec(vRCCount);
   end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DestroyRenderingContext(RC: HGLRC);
begin
   Assert((vRCCount=0), 'DestroyRenderingContext : unbalanced activation');
   Assert((RC=vCurrentRC), 'DestroyRenderingContext : bad RC');
   wglDeleteContext(RC);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure CloseOpenGL;
begin
  if GLHandle <> 0 then begin FreeLibrary(GLHandle); GLHandle:=0; end;
  if GLUHandle <> 0 then begin FreeLibrary(GLUHandle); GLUHandle:=0; end;
  ClearProcAddresses;
  ClearExtensions;
end;

//----------------------------------------------------------------------------------------------------------------------

function InitOpenGL: Boolean;
begin
   if (GLHandle = 0) or (GLUHandle = 0) then
      Result:=InitOpenGLFromLibrary('OpenGL32.DLL', 'GLU32.DLL')
   else Result:=True;
end;

//----------------------------------------------------------------------------------------------------------------------

function InitOpenGLFromLibrary(GL_Name, GLU_Name: String): Boolean;
begin
   Result:=False;
   CloseOpenGL;
   GLHandle:=LoadLibrary(PChar(GL_Name));
   GLUHandle:=LoadLibrary(PChar(GLU_Name));
   if (GLHandle <> 0) and (GLUHandle <> 0) then begin
      LoadProcAddresses;
      Result:=True;
   end else begin
      if GLHandle <> 0 then FreeLibrary(GLHandle);
      if GLUHandle <> 0 then FreeLibrary(GLUHandle);
   end;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization

   Set8087CW($133F);

finalization

   CloseOpenGL;
   // we don't need to reset the FPU control word as the previous set call
   // is process specific

end.
