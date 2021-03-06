// *************************************************************************************************
// * ==> UTQRMD2 ----------------------------------------------------------------------------------*
// *************************************************************************************************
// * MIT License - The Mels Library, a free and easy-to-use 3D Models library                      *
// *                                                                                               *
// * Permission is hereby granted, free of charge, to any person obtaining a copy of this software *
// * and associated documentation files (the "Software"), to deal in the Software without          *
// * restriction, including without limitation the rights to use, copy, modify, merge, publish,    *
// * distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the *
// * Software is furnished to do so, subject to the following conditions:                          *
// *                                                                                               *
// * The above copyright notice and this permission notice shall be included in all copies or      *
// * substantial portions of the Software.                                                         *
// *                                                                                               *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING *
// * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND    *
// * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  *
// * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      *
// * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *
// *************************************************************************************************

{**
 @abstract(@name provides the features to load a md2 model and build his vertex buffer.)
 @image(Resources/Images/Documentation/Mels.svg)
 @author(Jean-Milost Reymond)
 @created(2015 - 2017, this file is part of the Mels library)
}
unit UTQRMD2;

{$MODE Delphi}

interface

uses Classes,
     SysUtils,
     UTQRCommon,
     UTQRHelpers,
     UTQRGraphics,
     UTQRGeometry,
     UTQR3D,
     UTQRLight,
     UTQRCollision,
     UTQRModel;

const
    //----------------------------------------------------------------------------------------------
    // Global constants
    //----------------------------------------------------------------------------------------------
    {$REGION 'Documentation'}
    {**
     The MD2 file version
    }
    {$ENDREGION}
    CQR_MD2_Mesh_File_Version: TQRUInt32 = 8;

    {$REGION 'Documentation'}
    {**
     The MD2 file magic number, that can be used to identify the file content. His value is 'IDP2'
    }
    {$ENDREGION}
    CQR_MD2_ID: TQRUInt32 = ($32 shl 24) + ($50 shl 16) + ($44 shl 8) + $49;

    {$REGION 'Documentation'}
    {**
     The MD2 normal table file version
    }
    {$ENDREGION}
    CQR_MD2_Normals_Table_File_Version: Single = 1.0;

    {$REGION 'Documentation'}
    {**
     The invalid index error value to use with MD2 files
    }
    {$ENDREGION}
    CQR_MD2_Invalid_Index: NativeUInt = NativeUInt(-1);
    //----------------------------------------------------------------------------------------------

type
    {$REGION 'Documentation'}
    {**
     MD2 header
    }
    {$ENDREGION}
    TQRMD2Header = record
        {$REGION 'Documentation'}
        {**
         MD2 magic number identifier, should be equal to CQR_MD2_ID
        }
        {$ENDREGION}
        m_ID: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         MD2 version, should be equal to 8
        }
        {$ENDREGION}
        m_Version: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         MD2 texture width
        }
        {$ENDREGION}
        m_SkinWidth: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         MD2 texture height
        }
        {$ENDREGION}
        m_SkinHeight: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Size of one frame in bytes
        }
        {$ENDREGION}
        m_FrameSize: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Number of textures
        }
        {$ENDREGION}
        m_SkinCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Number of vertices
        }
        {$ENDREGION}
        m_VertexCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Number of texture coordinates
        }
        {$ENDREGION}
        m_TextureCoordCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Number of polygons
        }
        {$ENDREGION}
        m_PolygonCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Number of OpenGL commands
         @br @bold(NOTE) An openGL command is an information used to determine the kind of vertex
                         buffer to build, especially if vertex buffer is structured as triangle
                         strip or triangle fan)
        }
        {$ENDREGION}
        m_GlCmdsCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Total number of frames
        }
        {$ENDREGION}
        m_FrameCount: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to skin names (each skin name is a 64 bytes long char array and is @nil terminated)
        }
        {$ENDREGION}
        m_SkinOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to s-t texture coordinates
        }
        {$ENDREGION}
        m_TextureCoordOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to polygons
        }
        {$ENDREGION}
        m_PolygonOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to frame data
        }
        {$ENDREGION}
        m_FrameOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to OpenGL commands
         @br @bold(NOTE) An openGL command is an information used to determine the kind of vertex
                         buffer to build, especially if vertex buffer is structured as triangle
                         strip or triangle fan)
        }
        {$ENDREGION}
        m_GlCmdsOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Offset to end of file
        }
        {$ENDREGION}
        m_EndOffset: TQRUInt32;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream);
    end;

    PQRMD2Header = ^TQRMD2Header;

    {$REGION 'Documentation'}
    {**
     MD2 skin
    }
    {$ENDREGION}
    TQRMD2Skin = record
        {$REGION 'Documentation'}
        {**
         Texture name
        }
        {$ENDREGION}
        m_Name: string;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream);
    end;

    PQRMD2Skin= ^TQRMD2Skin;

    {$REGION 'Documentation'}
    {**
     MD2 vertex
    }
    {$ENDREGION}
    TQRMD2Vertex = record
        {$REGION 'Documentation'}
        {**
         Vertex coordinates
        }
        {$ENDREGION}
        m_Vertex: array[0..2] of TQRUInt8;

        {$REGION 'Documentation'}
        {**
         Index of the normal to use in the normal table
        }
        {$ENDREGION}
        m_NormalIndex: TQRUInt8;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream);
    end;

    PQRMD2Vertex = ^TQRMD2Vertex;

    {$REGION 'Documentation'}
    {**
     MD2 texture coordinate
    }
    {$ENDREGION}
    TQRMD2TextureCoord = record
        {$REGION 'Documentation'}
        {**
         Texture u coordinate
        }
        {$ENDREGION}
        m_U: TQRInt16;

        {$REGION 'Documentation'}
        {**
         Texture v coordinate
        }
        {$ENDREGION}
        m_V: TQRInt16;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream);
    end;

    PQRMD2TextureCoord = ^TQRMD2TextureCoord;

    {$REGION 'Documentation'}
    {**
     MD2 frame
    }
    {$ENDREGION}
    TQRMD2Frame = record
        {$REGION 'Documentation'}
        {**
         Frame name
        }
        {$ENDREGION}
        m_Name: string;

        {$REGION 'Documentation'}
        {**
         Scale factor to apply to each vertex of the frame
        }
        {$ENDREGION}
        m_Scale: array[0..2] of TQRFloat32;

        {$REGION 'Documentation'}
        {**
         Translation to apply to each vertex of the frame
        }
        {$ENDREGION}
        m_Translate: array[0..2] of TQRFloat32;

        {$REGION 'Documentation'}
        {**
         Vertices that compose the frame
        }
        {$ENDREGION}
        m_Vertex: array of TQRMD2Vertex;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @param(header MD2 file header)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream; const header: TQRMD2Header);
    end;

    PQRMD2Frame = ^TQRMD2Frame;

    {$REGION 'Documentation'}
    {**
     MD2 polygon
    }
    {$ENDREGION}
    TQRMD2Polygon = record
        {$REGION 'Documentation'}
        {**
         Index of each vertex composing the polygon in the frame buffer
        }
        {$ENDREGION}
        m_VertexIndex: array[0..2] of TQRInt16;

        {$REGION 'Documentation'}
        {**
         Index of each polygon texture coordinate in the frame buffer
        }
        {$ENDREGION}
        m_TextureCoordIndex: array[0..2] of TQRInt16;

        {$REGION 'Documentation'}
        {**
         Reads data from file
         @param(pBuffer Buffer to read from)
         @raises(Exception on error)
        }
        {$ENDREGION}
        procedure Read(pBuffer: TStream);
    end;

    PQRMD2Polygon = ^TQRMD2Polygon;

    {$REGION 'Documentation'}
    {**
     Reads and exposes MD2 file content
    }
    {$ENDREGION}
    TQRMD2Parser = class(TQRModelParser)
        private
            m_Header:    TQRMD2Header;
            m_Skins:     array of TQRMD2Skin;
            m_TexCoords: array of TQRMD2TextureCoord;
            m_Polygons:  array of TQRMD2Polygon;
            m_Frames:    array of TQRMD2Frame;
            m_GlCmds:    array of TQRInt32;

        protected
            {$REGION 'Documentation'}
            {**
             Gets header
             @return(Header, @nil if not found or on error)
            }
            {$ENDREGION}
            function GetHeader: PQRMD2Header; virtual;

            {$REGION 'Documentation'}
            {**
             Gets skin at index
             @param(index Index)
             @return(Skin, @nil if not found or on error)
            }
            {$ENDREGION}
            function GetSkin(index: NativeInt): PQRMD2Skin; virtual;

            {$REGION 'Documentation'}
            {**
             Gets texture coordinate at index
             @param(index Index)
             @return(Texture coordinate, @nil if not found or on error)
            }
            {$ENDREGION}
            function GetTexCoord(index: NativeInt): PQRMD2TextureCoord; virtual;

            {$REGION 'Documentation'}
            {**
             Gets polygon at index
             @param(index Index)
             @return(Polygon, @nil if not found or on error)
            }
            {$ENDREGION}
            function GetPolygon(index: NativeInt): PQRMD2Polygon; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the frame at index
             @param(index Index)
             @return(Frame, @nil if not found or on error)
            }
            {$ENDREGION}
            function GetFrame(index: NativeInt): PQRMD2Frame; virtual;

            {$REGION 'Documentation'}
            {**
             Gets OpenGL command at index
             @param(index Index)
             @return(OpenGL command, -1 if not found or on error)
            }
            {$ENDREGION}
            function GetGlCmd(index: NativeInt): TQRInt32; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the skin count
             @return(The skin count)
            }
            {$ENDREGION}
            function GetSkinCount: NativeInt; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the texture coordinate count
             @return(The texture coordinate count)
            }
            {$ENDREGION}
            function GetTexCoordCount: NativeInt; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the polygon count
             @return(The polygon count)
            }
            {$ENDREGION}
            function GetPolygonCount: NativeInt; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the frame count
             @return(The frame count)
            }
            {$ENDREGION}
            function GetFrameCount: NativeInt; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the OpenGL command count
             @return(The OpenGL command count)
            }
            {$ENDREGION}
            function GetGlCmdCount: NativeInt; virtual;

        public
            {$REGION 'Documentation'}
            {**
             Constructor
            }
            {$ENDREGION}
            constructor Create; override;

            {$REGION 'Documentation'}
            {**
             Destructor
            }
            {$ENDREGION}
            destructor Destroy; override;

            {$REGION 'Documentation'}
            {**
             Loads MD2 from buffer
             @param(pBuffer Buffer)
             @param(readLength Length to read in buffer, in bytes (not used here, can be 0))
             @return(@true on success, otherwise @false)
             @br @bold(NOTE) Read will begin from current offset
            }
            {$ENDREGION}
            function Load(const pBuffer: TStream; readLength: NativeUInt): Boolean; override;

        // Properties
        public
            {$REGION 'Documentation'}
            {**
             Gets the MD2 header
            }
            {$ENDREGION}
            property Header: PQRMD2Header read GetHeader;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 skin at index
            }
            {$ENDREGION}
            property Skins[index: NativeInt]: PQRMD2Skin read GetSkin;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 texture coordinate at index
            }
            {$ENDREGION}
            property TexCoords[index: NativeInt]: PQRMD2TextureCoord read GetTexCoord;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 polygon at index
            }
            {$ENDREGION}
            property Polygons[index: NativeInt]: PQRMD2Polygon read GetPolygon;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 frame at index
            }
            {$ENDREGION}
            property Frames[index: NativeInt]: PQRMD2Frame read GetFrame;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 OpenGL command at index
            }
            {$ENDREGION}
            property GlCmds[index: NativeInt]: TQRInt32 read GetGlCmd;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 skin count
            }
            {$ENDREGION}
            property SkinCount: NativeInt read GetSkinCount;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 texture coordinate count
            }
            {$ENDREGION}
            property TexCoordCount: NativeInt read GetTexCoordCount;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 polygon count
            }
            {$ENDREGION}
            property PolygonCount: NativeInt read GetPolygonCount;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 frame count
            }
            {$ENDREGION}
            property FrameCount: NativeInt read GetFrameCount;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 OpenGL command count
            }
            {$ENDREGION}
            property GlCmdCount: NativeInt read GetGlCmdCount;
    end;

    TQRMD2Normals = array of TQRVector3D;

    {$REGION 'Documentation'}
    {**
     MD2 model
    }
    {$ENDREGION}
    TQRMD2Model = class(TQRFramedModel)
        private
            m_pParser:             TQRMD2Parser;
            m_Normals:             TQRMD2Normals;
            m_RHToLH:              Boolean;
            m_pPreCalculatedLight: TQRDirectionalLight;

            {$REGION 'Documentation'}
            {**
             Populates the normals table
            }
            {$ENDREGION}
            procedure PopulateNormals;

        protected
            {$REGION 'Documentation'}
            {**
             Uncompresses MD2 vertex
             @param(pFrame MD2 frame)
             @param(pVertex MD2 vertex to uncompress)
             @return(The uncompressed vertex)
            }
            {$ENDREGION}
            function UncompressVertex(const frame: TQRMD2Frame;
                                     const vertex: TQRMD2Vertex): TQRVector3D; virtual;

            {$REGION 'Documentation'}
            {**
             Gets pre-calculated light
             @return(The pre-calculated light)
            }
            {$ENDREGION}
            function GetPreCalculatedLight: TQRDirectionalLight; virtual;

            {$REGION 'Documentation'}
            {**
             Sets pre-calculated light
             @param(pLight Pre-calculated light)
            }
            {$ENDREGION}
            procedure SetPreCalculatedLight(const pLight: TQRDirectionalLight); virtual;

            {$REGION 'Documentation'}
            {**
             Gets left hand to right hand conversion mode flag status
             @return(Left hand to right hand conversion mode flag status)
            }
            {$ENDREGION}
            function GetRHToLH: Boolean; virtual;

            {$REGION 'Documentation'}
            {**
             Sets left hand to right hand conversion mode flag status
             @param(value Left hand to right hand conversion mode flag status to set)
            }
            {$ENDREGION}
            procedure SetRHToLH(value: Boolean); virtual;

            {$REGION 'Documentation'}
            {**
             Gets MD2 parser
             @return(The MD2 parser)
            }
            {$ENDREGION}
            function GetParser: TQRMD2Parser; virtual;

        public
            {$REGION 'Documentation'}
            {**
             Constructor
            }
            {$ENDREGION}
            constructor Create; override;

            {$REGION 'Documentation'}
            {**
             Destructor
            }
            {$ENDREGION}
            destructor Destroy; override;

            {$REGION 'Documentation'}
            {**
             Loads MD2 from file
             @param(fileName File name)
             @return(@true on success, otherwise @false)
            }
            {$ENDREGION}
            function Load(const fileName: TFileName): Boolean; overload; virtual;

            {$REGION 'Documentation'}
            {**
             Loads MD2 from buffer
             @param(pBuffer Buffer)
             @param(readLength Length to read in buffer, in bytes)
             @return(@true on success, otherwise @false)
             @br @bold(NOTE) Read will begin from current offset
            }
            {$ENDREGION}
            function Load(const pBuffer: TStream;
                             readLength: NativeUInt): Boolean; overload; virtual;

            {$REGION 'Documentation'}
            {**
             Loads normals table from file
             @param(fileName File name)
             @return(@true on success, otherwise @false)
            }
            {$ENDREGION}
            function LoadNormals(const fileName: TFileName): Boolean; overload; virtual;

            {$REGION 'Documentation'}
            {**
             Loads normals table from buffer
             @param(pBuffer Buffer)
             @param(readLength Length to read in buffer, in bytes (not used here, can be 0))
             @return(@true on success, otherwise @false)
            }
            {$ENDREGION}
            function LoadNormals(const pBuffer: TStream;
                                    readLength: NativeUInt): Boolean; overload; virtual;

            {$REGION 'Documentation'}
            {**
             Gets the model frame mesh
             @param(index Frame mesh index to create)
             @param(mesh @bold([out]) Frame mesh)
             @param(pAABBTree Aligned-axis bounding box tree to populate, ignored if @nil)
             @param(hIsCanceled Callback function that allows to break the operation, can be @nil)
             @return(@true on success, otherwise @false)
             @br @bold(NOTE) vertex buffer content is structured as follow:
                             @br [1]x [2]y [3]z [4]nx [5]ny [6]nz [7]tu [8]tv [9]r [10]g [11]b [12]a
                             @br
                             @br where:
                             @br @bold(x/y/z)    - vertex coordinates
                             @br @bold(nx/ny/nz) - vertex normal (if the VertexFormat property contains the EQR_VF_Normals option)
                             @br @bold(tu/tv)    - vertex texture coordinates (if the VertexFormat property contains the EQR_VF_TexCoords option)
                             @br @bold(r/g/b/a)  - vertex color (if the VertexFormat property contains the EQR_VF_Colors option)
            }
            {$ENDREGION}
            function GetMesh(index: NativeUInt;
                          out mesh: TQRMesh;
                         pAABBTree: TQRAABBTree;
                       hIsCanceled: TQRIsCanceledEvent = nil): Boolean; overload; override;

            {$REGION 'Documentation'}
            {**
             Gets the model frame mesh
             @param(index Frame mesh index to get)
             @param(nextIndex Frame mesh index to interpolate with)
             @param(interpolationFactor Interpolation factor to apply)
             @param(mesh @bold([out]) Frame mesh)
             @param(hIsCanceled Callback function that allows to break the operation, can be @nil)
             @return(@true on success, otherwise @false)
             @br @bold(NOTE) vertex buffer content is structured as follow:
                             @br [1]x [2]y [3]z [4]nx [5]ny [6]nz [7]tu [8]tv [9]r [10]g [11]b [12]a
                             @br
                             @br where:
                             @br @bold(x/y/z)    - vertex coordinates
                             @br @bold(nx/ny/nz) - vertex normal (if the VertexFormat property contains the EQR_VF_Normals option)
                             @br @bold(tu/tv)    - vertex texture coordinates (if the VertexFormat property contains the EQR_VF_TexCoords option)
                             @br @bold(r/g/b/a)  - vertex color (if the VertexFormat property contains the EQR_VF_Colors option)
            }
            {$ENDREGION}
            function GetMesh(index, nextIndex: NativeUInt;
                          interpolationFactor: Double;
                                     out mesh: TQRMesh;
                                  hIsCanceled: TQRIsCanceledEvent): Boolean; overload; override;

            {$REGION 'Documentation'}
            {**
             Gets the mesh count
             @returns(The mesh count)
            }
            {$ENDREGION}
            function GetMeshCount: NativeUInt; override;

        // Properties
        public
            {$REGION 'Documentation'}
            {**
             Gets or sets the pre-calculated light to use
            }
            {$ENDREGION}
            property PreCalculatedLight: TQRDirectionalLight read GetPreCalculatedLight write SetPreCalculatedLight;

            {$REGION 'Documentation'}
            {**
             Gets or sets the left hand to right hand converter enabled status
            }
            {$ENDREGION}
            property RHToLH: Boolean read GetRHToLH write SetRHToLH;

            {$REGION 'Documentation'}
            {**
             Gets the MD2 parser
            }
            {$ENDREGION}
            property Parser: TQRMD2Parser read GetParser;
    end;

implementation
//--------------------------------------------------------------------------------------------------
// TQRMD2Header
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Header.Read(pBuffer: TStream);
var
    errorMsg: UnicodeString;
begin
    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, SizeOf(TQRMD2Header), errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    {$IFDEF CPUX64}
        // read header from file
        pBuffer.Read(m_ID,                 SizeOf(TQRUInt32));
        pBuffer.Read(m_Version,            SizeOf(TQRUInt32));
        pBuffer.Read(m_SkinWidth,          SizeOf(TQRUInt32));
        pBuffer.Read(m_SkinHeight,         SizeOf(TQRUInt32));
        pBuffer.Read(m_FrameSize,          SizeOf(TQRUInt32));
        pBuffer.Read(m_SkinCount,          SizeOf(TQRUInt32));
        pBuffer.Read(m_VertexCount,        SizeOf(TQRUInt32));
        pBuffer.Read(m_TextureCoordCount,  SizeOf(TQRUInt32));
        pBuffer.Read(m_PolygonCount,       SizeOf(TQRUInt32));
        pBuffer.Read(m_GlCmdsCount,        SizeOf(TQRUInt32));
        pBuffer.Read(m_FrameCount,         SizeOf(TQRUInt32));
        pBuffer.Read(m_SkinOffset,         SizeOf(TQRUInt32));
        pBuffer.Read(m_TextureCoordOffset, SizeOf(TQRUInt32));
        pBuffer.Read(m_PolygonOffset,      SizeOf(TQRUInt32));
        pBuffer.Read(m_FrameOffset,        SizeOf(TQRUInt32));
        pBuffer.Read(m_GlCmdsOffset,       SizeOf(TQRUInt32));
        pBuffer.Read(m_EndOffset,          SizeOf(TQRUInt32));
    {$ELSE}
        // read header from file
        pBuffer.Read(PQRUInt32(m_ID),                 SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_Version),            SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_SkinWidth),          SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_SkinHeight),         SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_FrameSize),          SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_SkinCount),          SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_VertexCount),        SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_TextureCoordCount),  SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_PolygonCount),       SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_GlCmdsCount),        SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_FrameCount),         SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_SkinOffset),         SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_TextureCoordOffset), SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_PolygonOffset),      SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_FrameOffset),        SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_GlCmdsOffset),       SizeOf(TQRUInt32));
        pBuffer.Read(PQRUInt32(m_EndOffset),          SizeOf(TQRUInt32));
    {$ENDIF}
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Skin
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Skin.Read(pBuffer: TStream);
var
    name:     TQRAnsiCharArray;
    errorMsg: UnicodeString;
begin
    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, 64 * SizeOf(AnsiChar), errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    // reserve memory for char array
    SetLength(name, 64);

    try
        // initialize char array memory by filling it with 0
        FillChar(name[0], 64 * SizeOf(AnsiChar), $00);

        // read skin name
        pBuffer.Read(name[0], Length(name) * SizeOf(AnsiChar));

        // set skin name
        m_Name := TQRStringHelper.AnsiCharArrayToStr(name);
    finally
        // clear memory
        SetLength(name, 0);
    end;
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Vertex
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Vertex.Read(pBuffer: TStream);
var
    errorMsg: UnicodeString;
begin
    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, SizeOf(TQRMD2Vertex), errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    // read vertex from file
    pBuffer.Read(m_Vertex[0],   SizeOf(m_Vertex));
    pBuffer.Read(m_NormalIndex, SizeOf(TQRUInt8));
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2TextureCoord
//--------------------------------------------------------------------------------------------------
procedure TQRMD2TextureCoord.Read(pBuffer: TStream);
var
    errorMsg: UnicodeString;
begin
    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, SizeOf(TQRMD2TextureCoord), errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    // read texture coordinates from file
    pBuffer.Read(m_U, SizeOf(TQRInt16));
    pBuffer.Read(m_V, SizeOf(TQRInt16));
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Frame
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Frame.Read(pBuffer: TStream; const header: TQRMD2Header);
var
    dataLength: NativeUInt;
    name:       TQRAnsiCharArray;
    i:          Cardinal;
    errorMsg:   UnicodeString;
begin
    // calculate needed length to read next data in buffer
    dataLength := (16 * SizeOf(AnsiChar)) + SizeOf(m_Scale) + SizeOf(m_Translate);

    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, dataLength, errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    if (Length(m_Vertex) > 0) then
        SetLength(m_Vertex, 0);

    // read vertex transformations
    pBuffer.Read(m_Scale,     SizeOf(m_Scale));
    pBuffer.Read(m_Translate, SizeOf(m_Translate));

    // reserve memory for char array
    SetLength(name, 16);

    try
        // initialize char array memory filling it with 0
        FillChar(name[0], 16 * SizeOf(AnsiChar), $00);

        // read frame name
        pBuffer.Read(name[0], Length(name) * SizeOf(AnsiChar));

        // set frame name
        m_Name := TQRStringHelper.AnsiCharArrayToStr(name);
    finally
        // clear memory
        SetLength(name, 0);
    end;

    // no vertex?
    if (header.m_VertexCount = 0) then
        Exit;

    // create frame vertex buffer
    SetLength(m_Vertex, header.m_VertexCount);

    // read frame vertices
    for i := 0 to header.m_VertexCount - 1 do
        m_Vertex[i].Read(pBuffer);
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Polygon
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Polygon.Read(pBuffer: TStream);
var
    errorMsg: UnicodeString;
begin
    // check if buffer is large enough to read next data block
    if (not TQRModelHelper.ValidateNextRead(pBuffer, SizeOf(TQRMD2Polygon), errorMsg)) then
        raise Exception.Create('Not enough bytes in MD2 file to read next data - ' +
                               AnsiString(errorMsg));

    // read polygon from file
    pBuffer.Read(m_VertexIndex,       SizeOf(m_VertexIndex));
    pBuffer.Read(m_TextureCoordIndex, SizeOf(m_TextureCoordIndex));
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Parser
//--------------------------------------------------------------------------------------------------
constructor TQRMD2Parser.Create;
begin
    inherited Create;
end;
//--------------------------------------------------------------------------------------------------
destructor TQRMD2Parser.Destroy;
begin
    inherited Destroy;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetHeader: PQRMD2Header;
begin
    Result := @m_Header;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetSkin(index: NativeInt): PQRMD2Skin;
begin
    // is index out of bounds?
    if ((index < 0) or (index >= Length(m_Skins))) then
        Exit(nil);

    Result := @m_Skins[index];
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetTexCoord(index: NativeInt): PQRMD2TextureCoord;
begin
    // is index out of bounds?
    if ((index < 0) or (index >= Length(m_TexCoords))) then
        Exit(nil);

    Result := @m_TexCoords[index];
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetPolygon(index: NativeInt): PQRMD2Polygon;
begin
    // is index out of bounds?
    if ((index < 0) or (index >= Length(m_Polygons))) then
        Exit(nil);

    Result := @m_Polygons[index];
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetFrame(index: NativeInt): PQRMD2Frame;
begin
    // is index out of bounds?
    if ((index < 0) or (index >= Length(m_Frames))) then
        Exit(nil);

    Result := @m_Frames[index];
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetGlCmd(index: NativeInt): TQRInt32;
begin
    // is index out of bounds?
    if ((index < 0) or (index >= Length(m_GlCmds))) then
        Exit(-1);

    Result := m_GlCmds[index];
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetSkinCount: NativeInt;
begin
    Result := Length(m_Skins);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetTexCoordCount: NativeInt;
begin
    Result := Length(m_TexCoords);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetPolygonCount: NativeInt;
begin
    Result := Length(m_Polygons);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetFrameCount: NativeInt;
begin
    Result := Length(m_Frames);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.GetGlCmdCount: NativeInt;
begin
    Result := Length(m_GlCmds);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Parser.Load(const pBuffer: TStream; readLength: NativeUInt): Boolean;
var
    offset: NativeUInt;
    i:      NativeUInt;
begin
    try
        // is buffer empty?
        if (pBuffer.Size = 0) then
            Exit(False);

        // get current offset
        offset := pBuffer.Position;

        // read file header
        m_Header.Read(pBuffer);

        // is MD2 file and version correct?
        if ((m_Header.m_ID <> CQR_MD2_ID) or (m_Header.m_Version <> CQR_MD2_Mesh_File_Version)) then
            Exit(False);

        // create mesh buffers
        SetLength(m_Skins,     m_Header.m_SkinCount);
        SetLength(m_TexCoords, m_Header.m_TextureCoordCount);
        SetLength(m_Polygons,  m_Header.m_PolygonCount);
        SetLength(m_GlCmds,    m_Header.m_GlCmdsCount);
        SetLength(m_Frames,    m_Header.m_FrameCount);

        // read skins
        if (m_Header.m_SkinCount > 0) then
        begin
            // go to skins offset
            pBuffer.Seek(Int64(offset) + Int64(m_Header.m_SkinOffset), soBeginning);

            for i := 0 to m_Header.m_SkinCount - 1 do
                m_Skins[i].Read(pBuffer);
        end;

        // read texture coordinates
        if (m_Header.m_TextureCoordCount > 0) then
        begin
            // go to texture coordinates offset
            pBuffer.Seek(Int64(offset) + Int64(m_Header.m_TextureCoordOffset), soBeginning);

            for i := 0 to m_Header.m_TextureCoordCount - 1 do
                m_TexCoords[i].Read(pBuffer);
        end;

        // read polygons
        if (m_Header.m_PolygonCount > 0) then
        begin
            // go to polygons offset
            pBuffer.Seek(Int64(offset) + Int64(m_Header.m_PolygonOffset), soBeginning);

            for i := 0 to m_Header.m_PolygonCount - 1 do
                m_Polygons[i].Read(pBuffer);
        end;

        // read OpenGL commands
        if (m_Header.m_GlCmdsCount > 0) then
        begin
            pBuffer.Seek(Int64(offset) + Int64(m_Header.m_GlCmdsOffset), soBeginning);
            pBuffer.Read(m_GlCmds[0], SizeOf(TQRInt32) * m_Header.m_GlCmdsCount);
        end;

        // read frames
        if (m_Header.m_FrameCount > 0) then
        begin
            // go to frames offset
            pBuffer.Seek(Int64(offset) + Int64(m_Header.m_FrameOffset), soBeginning);

            for i := 0 to m_Header.m_FrameCount - 1 do
                m_Frames[i].Read(pBuffer, m_Header);
        end;

        Exit(True);
    except
        on e: Exception do ; // ignore any error
    end;

    Result := False;
end;
//--------------------------------------------------------------------------------------------------
// TQRMD2Model
//--------------------------------------------------------------------------------------------------
constructor TQRMD2Model.Create;
begin
    inherited Create;

    m_pParser             := TQRMD2Parser.Create;
    m_pPreCalculatedLight := TQRDirectionalLight.Create;
    m_RHToLH              := False;

    Populatenormals;
end;
//--------------------------------------------------------------------------------------------------
destructor TQRMD2Model.Destroy;
begin
    // clear memory
    SetLength(m_Normals, 0);
    m_pPreCalculatedLight.Free;
    m_pParser.Free;

    inherited Destroy;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Model.PopulateNormals;
type
    {**
     Internal record representing a normal
    }
    IQRNormal = record
        m_X: Single;
        m_Y: Single;
        m_Z: Single;
    end;

const
    {**
     Normal table used by the MDL models
    }
    normals: array[0..161] of IQRNormal =
    (
        (m_X: -0.525731; m_Y:  0.000000; m_Z:  0.850651),
        (m_X: -0.442863; m_Y:  0.238856; m_Z:  0.864188),
        (m_X: -0.295242; m_Y:  0.000000; m_Z:  0.955423),
        (m_X: -0.309017; m_Y:  0.500000; m_Z:  0.809017),
        (m_X: -0.162460; m_Y:  0.262866; m_Z:  0.951056),
        (m_X:  0.000000; m_Y:  0.000000; m_Z:  1.000000),
        (m_X:  0.000000; m_Y:  0.850651; m_Z:  0.525731),
        (m_X: -0.147621; m_Y:  0.716567; m_Z:  0.681718),
        (m_X:  0.147621; m_Y:  0.716567; m_Z:  0.681718),
        (m_X:  0.000000; m_Y:  0.525731; m_Z:  0.850651),
        (m_X:  0.309017; m_Y:  0.500000; m_Z:  0.809017),
        (m_X:  0.525731; m_Y:  0.000000; m_Z:  0.850651),
        (m_X:  0.295242; m_Y:  0.000000; m_Z:  0.955423),
        (m_X:  0.442863; m_Y:  0.238856; m_Z:  0.864188),
        (m_X:  0.162460; m_Y:  0.262866; m_Z:  0.951056),
        (m_X: -0.681718; m_Y:  0.147621; m_Z:  0.716567),
        (m_X: -0.809017; m_Y:  0.309017; m_Z:  0.500000),
        (m_X: -0.587785; m_Y:  0.425325; m_Z:  0.688191),
        (m_X: -0.850651; m_Y:  0.525731; m_Z:  0.000000),
        (m_X: -0.864188; m_Y:  0.442863; m_Z:  0.238856),
        (m_X: -0.716567; m_Y:  0.681718; m_Z:  0.147621),
        (m_X: -0.688191; m_Y:  0.587785; m_Z:  0.425325),
        (m_X: -0.500000; m_Y:  0.809017; m_Z:  0.309017),
        (m_X: -0.238856; m_Y:  0.864188; m_Z:  0.442863),
        (m_X: -0.425325; m_Y:  0.688191; m_Z:  0.587785),
        (m_X: -0.716567; m_Y:  0.681718; m_Z: -0.147621),
        (m_X: -0.500000; m_Y:  0.809017; m_Z: -0.309017),
        (m_X: -0.525731; m_Y:  0.850651; m_Z:  0.000000),
        (m_X:  0.000000; m_Y:  0.850651; m_Z: -0.525731),
        (m_X: -0.238856; m_Y:  0.864188; m_Z: -0.442863),
        (m_X:  0.000000; m_Y:  0.955423; m_Z: -0.295242),
        (m_X: -0.262866; m_Y:  0.951056; m_Z: -0.162460),
        (m_X:  0.000000; m_Y:  1.000000; m_Z:  0.000000),
        (m_X:  0.000000; m_Y:  0.955423; m_Z:  0.295242),
        (m_X: -0.262866; m_Y:  0.951056; m_Z:  0.162460),
        (m_X:  0.238856; m_Y:  0.864188; m_Z:  0.442863),
        (m_X:  0.262866; m_Y:  0.951056; m_Z:  0.162460),
        (m_X:  0.500000; m_Y:  0.809017; m_Z:  0.309017),
        (m_X:  0.238856; m_Y:  0.864188; m_Z: -0.442863),
        (m_X:  0.262866; m_Y:  0.951056; m_Z: -0.162460),
        (m_X:  0.500000; m_Y:  0.809017; m_Z: -0.309017),
        (m_X:  0.850651; m_Y:  0.525731; m_Z:  0.000000),
        (m_X:  0.716567; m_Y:  0.681718; m_Z:  0.147621),
        (m_X:  0.716567; m_Y:  0.681718; m_Z: -0.147621),
        (m_X:  0.525731; m_Y:  0.850651; m_Z:  0.000000),
        (m_X:  0.425325; m_Y:  0.688191; m_Z:  0.587785),
        (m_X:  0.864188; m_Y:  0.442863; m_Z:  0.238856),
        (m_X:  0.688191; m_Y:  0.587785; m_Z:  0.425325),
        (m_X:  0.809017; m_Y:  0.309017; m_Z:  0.500000),
        (m_X:  0.681718; m_Y:  0.147621; m_Z:  0.716567),
        (m_X:  0.587785; m_Y:  0.425325; m_Z:  0.688191),
        (m_X:  0.955423; m_Y:  0.295242; m_Z:  0.000000),
        (m_X:  1.000000; m_Y:  0.000000; m_Z:  0.000000),
        (m_X:  0.951056; m_Y:  0.162460; m_Z:  0.262866),
        (m_X:  0.850651; m_Y: -0.525731; m_Z:  0.000000),
        (m_X:  0.955423; m_Y: -0.295242; m_Z:  0.000000),
        (m_X:  0.864188; m_Y: -0.442863; m_Z:  0.238856),
        (m_X:  0.951056; m_Y: -0.162460; m_Z:  0.262866),
        (m_X:  0.809017; m_Y: -0.309017; m_Z:  0.500000),
        (m_X:  0.681718; m_Y: -0.147621; m_Z:  0.716567),
        (m_X:  0.850651; m_Y:  0.000000; m_Z:  0.525731),
        (m_X:  0.864188; m_Y:  0.442863; m_Z: -0.238856),
        (m_X:  0.809017; m_Y:  0.309017; m_Z: -0.500000),
        (m_X:  0.951056; m_Y:  0.162460; m_Z: -0.262866),
        (m_X:  0.525731; m_Y:  0.000000; m_Z: -0.850651),
        (m_X:  0.681718; m_Y:  0.147621; m_Z: -0.716567),
        (m_X:  0.681718; m_Y: -0.147621; m_Z: -0.716567),
        (m_X:  0.850651; m_Y:  0.000000; m_Z: -0.525731),
        (m_X:  0.809017; m_Y: -0.309017; m_Z: -0.500000),
        (m_X:  0.864188; m_Y: -0.442863; m_Z: -0.238856),
        (m_X:  0.951056; m_Y: -0.162460; m_Z: -0.262866),
        (m_X:  0.147621; m_Y:  0.716567; m_Z: -0.681718),
        (m_X:  0.309017; m_Y:  0.500000; m_Z: -0.809017),
        (m_X:  0.425325; m_Y:  0.688191; m_Z: -0.587785),
        (m_X:  0.442863; m_Y:  0.238856; m_Z: -0.864188),
        (m_X:  0.587785; m_Y:  0.425325; m_Z: -0.688191),
        (m_X:  0.688191; m_Y:  0.587785; m_Z: -0.425325),
        (m_X: -0.147621; m_Y:  0.716567; m_Z: -0.681718),
        (m_X: -0.309017; m_Y:  0.500000; m_Z: -0.809017),
        (m_X:  0.000000; m_Y:  0.525731; m_Z: -0.850651),
        (m_X: -0.525731; m_Y:  0.000000; m_Z: -0.850651),
        (m_X: -0.442863; m_Y:  0.238856; m_Z: -0.864188),
        (m_X: -0.295242; m_Y:  0.000000; m_Z: -0.955423),
        (m_X: -0.162460; m_Y:  0.262866; m_Z: -0.951056),
        (m_X:  0.000000; m_Y:  0.000000; m_Z: -1.000000),
        (m_X:  0.295242; m_Y:  0.000000; m_Z: -0.955423),
        (m_X:  0.162460; m_Y:  0.262866; m_Z: -0.951056),
        (m_X: -0.442863; m_Y: -0.238856; m_Z: -0.864188),
        (m_X: -0.309017; m_Y: -0.500000; m_Z: -0.809017),
        (m_X: -0.162460; m_Y: -0.262866; m_Z: -0.951056),
        (m_X:  0.000000; m_Y: -0.850651; m_Z: -0.525731),
        (m_X: -0.147621; m_Y: -0.716567; m_Z: -0.681718),
        (m_X:  0.147621; m_Y: -0.716567; m_Z: -0.681718),
        (m_X:  0.000000; m_Y: -0.525731; m_Z: -0.850651),
        (m_X:  0.309017; m_Y: -0.500000; m_Z: -0.809017),
        (m_X:  0.442863; m_Y: -0.238856; m_Z: -0.864188),
        (m_X:  0.162460; m_Y: -0.262866; m_Z: -0.951056),
        (m_X:  0.238856; m_Y: -0.864188; m_Z: -0.442863),
        (m_X:  0.500000; m_Y: -0.809017; m_Z: -0.309017),
        (m_X:  0.425325; m_Y: -0.688191; m_Z: -0.587785),
        (m_X:  0.716567; m_Y: -0.681718; m_Z: -0.147621),
        (m_X:  0.688191; m_Y: -0.587785; m_Z: -0.425325),
        (m_X:  0.587785; m_Y: -0.425325; m_Z: -0.688191),
        (m_X:  0.000000; m_Y: -0.955423; m_Z: -0.295242),
        (m_X:  0.000000; m_Y: -1.000000; m_Z:  0.000000),
        (m_X:  0.262866; m_Y: -0.951056; m_Z: -0.162460),
        (m_X:  0.000000; m_Y: -0.850651; m_Z:  0.525731),
        (m_X:  0.000000; m_Y: -0.955423; m_Z:  0.295242),
        (m_X:  0.238856; m_Y: -0.864188; m_Z:  0.442863),
        (m_X:  0.262866; m_Y: -0.951056; m_Z:  0.162460),
        (m_X:  0.500000; m_Y: -0.809017; m_Z:  0.309017),
        (m_X:  0.716567; m_Y: -0.681718; m_Z:  0.147621),
        (m_X:  0.525731; m_Y: -0.850651; m_Z:  0.000000),
        (m_X: -0.238856; m_Y: -0.864188; m_Z: -0.442863),
        (m_X: -0.500000; m_Y: -0.809017; m_Z: -0.309017),
        (m_X: -0.262866; m_Y: -0.951056; m_Z: -0.162460),
        (m_X: -0.850651; m_Y: -0.525731; m_Z:  0.000000),
        (m_X: -0.716567; m_Y: -0.681718; m_Z: -0.147621),
        (m_X: -0.716567; m_Y: -0.681718; m_Z:  0.147621),
        (m_X: -0.525731; m_Y: -0.850651; m_Z:  0.000000),
        (m_X: -0.500000; m_Y: -0.809017; m_Z:  0.309017),
        (m_X: -0.238856; m_Y: -0.864188; m_Z:  0.442863),
        (m_X: -0.262866; m_Y: -0.951056; m_Z:  0.162460),
        (m_X: -0.864188; m_Y: -0.442863; m_Z:  0.238856),
        (m_X: -0.809017; m_Y: -0.309017; m_Z:  0.500000),
        (m_X: -0.688191; m_Y: -0.587785; m_Z:  0.425325),
        (m_X: -0.681718; m_Y: -0.147621; m_Z:  0.716567),
        (m_X: -0.442863; m_Y: -0.238856; m_Z:  0.864188),
        (m_X: -0.587785; m_Y: -0.425325; m_Z:  0.688191),
        (m_X: -0.309017; m_Y: -0.500000; m_Z:  0.809017),
        (m_X: -0.147621; m_Y: -0.716567; m_Z:  0.681718),
        (m_X: -0.425325; m_Y: -0.688191; m_Z:  0.587785),
        (m_X: -0.162460; m_Y: -0.262866; m_Z:  0.951056),
        (m_X:  0.442863; m_Y: -0.238856; m_Z:  0.864188),
        (m_X:  0.162460; m_Y: -0.262866; m_Z:  0.951056),
        (m_X:  0.309017; m_Y: -0.500000; m_Z:  0.809017),
        (m_X:  0.147621; m_Y: -0.716567; m_Z:  0.681718),
        (m_X:  0.000000; m_Y: -0.525731; m_Z:  0.850651),
        (m_X:  0.425325; m_Y: -0.688191; m_Z:  0.587785),
        (m_X:  0.587785; m_Y: -0.425325; m_Z:  0.688191),
        (m_X:  0.688191; m_Y: -0.587785; m_Z:  0.425325),
        (m_X: -0.955423; m_Y:  0.295242; m_Z:  0.000000),
        (m_X: -0.951056; m_Y:  0.162460; m_Z:  0.262866),
        (m_X: -1.000000; m_Y:  0.000000; m_Z:  0.000000),
        (m_X: -0.850651; m_Y:  0.000000; m_Z:  0.525731),
        (m_X: -0.955423; m_Y: -0.295242; m_Z:  0.000000),
        (m_X: -0.951056; m_Y: -0.162460; m_Z:  0.262866),
        (m_X: -0.864188; m_Y:  0.442863; m_Z: -0.238856),
        (m_X: -0.951056; m_Y:  0.162460; m_Z: -0.262866),
        (m_X: -0.809017; m_Y:  0.309017; m_Z: -0.500000),
        (m_X: -0.864188; m_Y: -0.442863; m_Z: -0.238856),
        (m_X: -0.951056; m_Y: -0.162460; m_Z: -0.262866),
        (m_X: -0.809017; m_Y: -0.309017; m_Z: -0.500000),
        (m_X: -0.681718; m_Y:  0.147621; m_Z: -0.716567),
        (m_X: -0.681718; m_Y: -0.147621; m_Z: -0.716567),
        (m_X: -0.850651; m_Y:  0.000000; m_Z: -0.525731),
        (m_X: -0.688191; m_Y:  0.587785; m_Z: -0.425325),
        (m_X: -0.587785; m_Y:  0.425325; m_Z: -0.688191),
        (m_X: -0.425325; m_Y:  0.688191; m_Z: -0.587785),
        (m_X: -0.425325; m_Y: -0.688191; m_Z: -0.587785),
        (m_X: -0.587785; m_Y: -0.425325; m_Z: -0.688191),
        (m_X: -0.688191; m_Y: -0.587785; m_Z: -0.425325)
    );

var
    arraySize, i: Integer;

begin
    arraySize := Length(normals);
    SetLength(m_Normals, arraySize);

    // initialize normal table
    for i := 0 to arraySize - 1 do
    begin
        m_Normals[i].X := normals[i].m_X;
        m_Normals[i].Y := normals[i].m_Y;
        m_Normals[i].Z := normals[i].m_Z;
    end;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.UncompressVertex(const frame: TQRMD2Frame;
                                     const vertex: TQRMD2Vertex): TQRVector3D;
var
    vertArray: array[0..2] of Single;
    i:         Byte;
begin
    // iterate through vertex coordinates
    for i := 0 to 2 do
        // uncompress vertex using frame scale and translate values
        vertArray[i] := (frame.m_Scale[i] * vertex.m_Vertex[i]) + frame.m_Translate[i];

    Result := TQRVector3D.Create(vertArray[0], vertArray[1], vertArray[2]);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetPreCalculatedLight: TQRDirectionalLight;
begin
    Result := m_pPreCalculatedLight;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Model.SetPreCalculatedLight(const pLight: TQRDirectionalLight);
begin
    m_pPreCalculatedLight.Assign(pLight);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetRHToLH: Boolean;
begin
    Result := m_RHToLH;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRMD2Model.SetRHToLH(value: Boolean);
begin
    m_RHToLH := value;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetParser: TQRMD2Parser;
begin
    Result := m_pParser;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.Load(const fileName: TFileName): Boolean;
begin
    Result := m_pParser.Load(fileName);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.Load(const pBuffer: TStream; readLength: NativeUInt): Boolean;
begin
    Result := m_pParser.Load(pBuffer, readLength);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.LoadNormals(const fileName: TFileName): Boolean;
var
    pBuffer: TFileStream;
begin
    pBuffer := nil;

    try
        // file exists?
        if (not FileExists(fileName)) then
            Exit(False);

        // create a file buffer and open it for read
        pBuffer := TFileStream.Create(fileName, fmOpenRead);
        pBuffer.Seek(0, soBeginning);

        // read MD2 normals file content
        Result := LoadNormals(pBuffer, pBuffer.Size);
    finally
        // clear buffer
        pBuffer.Free;
    end;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.LoadNormals(const pBuffer: TStream; readLength: NativeUInt): Boolean;
var
    fileVersion, x, y, z: Single;
    dataLength:           TQRUInt32;
    i:                    Cardinal;
begin
    // is buffer empty?
    if (pBuffer.Size = 0) then
        Exit(False);

    fileVersion := 0;

    // read version
    pBuffer.Read(fileVersion, SizeOf(fileVersion));

    // is version correct?
    if (fileVersion <> CQR_MD2_Normals_Table_File_Version) then
        Exit(False);

    dataLength := 0;

    // read file length
    pBuffer.Read(dataLength, SizeOf(TQRUInt32));

    // is file empty?
    if (dataLength = 0) then
        Exit(False);

    // reserve memory for normals table
    SetLength(m_Normals, dataLength);

    // iterate through normals
    for i := 0 to dataLength - 1 do
    begin
        x := 0.0;
        y := 0.0;
        z := 0.0;

        // read next normal from file
        pBuffer.Read(x, SizeOf(x));
        pBuffer.Read(y, SizeOf(y));
        pBuffer.Read(z, SizeOf(z));

        // set normal in table
        m_Normals[i] := TQRVector3D.Create(x, y, z);
    end;

    Result := True;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetMesh(index: NativeUInt;
                          out mesh: TQRMesh;
                         pAABBTree: TQRAABBTree;
                       hIsCanceled: TQRIsCanceledEvent): Boolean;
type
    TQRSingleArray = array of Single;
var
    srcFrame:                                    TQRMD2Frame;
    stride, normalCount, i, j, meshIndex, glCmd: NativeInt;
    srcVertex:                                   TQRMD2Vertex;
    ucpVertex, normal:                           TQRVector3D;
    tu, tv:                                      Single;
    pMeshColor:                                  TQRColor;
    foundNormal, doFreeColor:                    Boolean;
    glCmdsSingle:                                TQRSingleArray;
begin
    // is frame index out of bounds?
    if (index >= GetMeshCount) then
        Exit(False);

    // get normal count
    normalCount := Length(m_Normals);

    // do use normals and pre-calculated normals table wasn't populated?
    if ((EQR_VF_Normals in VertexFormat) and (normalCount = 0)) then
        Exit(False);

    // get source frame from which mesh should be extracted
    srcFrame := m_pParser.m_Frames[index];

    // basically stride is the coordinates values size
    stride := 3;

    // do include m_Normals?
    if (EQR_VF_Normals in VertexFormat) then
        Inc(stride, 3);

    // do include texture coordinates?
    if (EQR_VF_TexCoords in VertexFormat) then
        Inc(stride, 2);

    // do include colors?
    if (EQR_VF_Colors in VertexFormat) then
        Inc(stride, 4);

    i      := 0;
    glCmd  := m_pParser.m_GLCmds[i];

    // iterate through OpenGL commands (negative value is for triangle fan,
    // positive value is for triangle strip, 0 means list end)
    while (glCmd <> 0) do
    begin
        // is canceled?
        if (Assigned(hIsCanceled) and hIsCanceled) then
            Exit(False);

        // the first command is the number of vertices to process, already read, so skip it
        Inc(i);

        // add mesh to output
        SetLength(mesh, Length(mesh) + 1);
        meshIndex := Length(mesh) - 1;

        // create and populate new vertex for the current command
        mesh[meshIndex].m_Name      := 'qr_md2';
        mesh[meshIndex].m_Stride    := stride;
        mesh[meshIndex].m_Format    := VertexFormat;
        mesh[meshIndex].m_CoordType := EQR_VC_XYZ;

        // search for OpenGL command type
        if (glCmd < 0) then
        begin
            mesh[meshIndex].m_Type := EQR_VT_TriangleFan;
            glCmd                  := -glCmd;
        end
        else
            mesh[meshIndex].m_Type := EQR_VT_TriangleStrip;

        j := 0;

        // iterate through OpenGL commands to process
        while (glCmd > 0) do
        begin
            // is canceled?
            if (Assigned(hIsCanceled) and hIsCanceled) then
                Exit(False);

            // get source vertex
            srcVertex := srcFrame.m_Vertex[m_pParser.m_GLCmds[i + 2]];

            // uncompress vertex
            ucpVertex := UncompressVertex(srcFrame, srcVertex);

            // do convert right hand <-> left hand coordinate system?
            if (m_RHToLH) then
                // apply conversion
                ucpVertex.X := -ucpVertex.X;

            // populate vertex buffer
            SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 3);
            mesh[meshIndex].m_Buffer[j]     := ucpVertex.X;
            mesh[meshIndex].m_Buffer[j + 1] := ucpVertex.Y;
            mesh[meshIndex].m_Buffer[j + 2] := ucpVertex.Z;
            Inc(j, 3);

            // do include m_Normals?
            if (EQR_VF_Normals in VertexFormat) then
            begin
                // is normal index out of bounds?
                if (srcVertex.m_NormalIndex >= normalCount) then
                    Exit(False);

                // get vertex normal
                normal := m_Normals[srcVertex.m_NormalIndex];

                // do convert right hand <-> left hand coordinate system?
                if (m_RHToLH) then
                    // apply conversion
                    normal.X := -normal.X;

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 3);
                mesh[meshIndex].m_Buffer[j]     := normal.X;
                mesh[meshIndex].m_Buffer[j + 1] := normal.Y;
                mesh[meshIndex].m_Buffer[j + 2] := normal.Z;
                Inc(j, 3);
            end;

            // do include texture coordinates?
            if (EQR_VF_TexCoords in VertexFormat) then
            begin
                // reinterpret OpenGL commands array as an array of single
                glCmdsSingle := TQRSingleArray(m_pParser.m_GLCmds);

                // get vertex texture coordinates
                tu := glCmdsSingle[i];
                tv := glCmdsSingle[i + 1];

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 2);
                mesh[meshIndex].m_Buffer[j]     := tu;
                mesh[meshIndex].m_Buffer[j + 1] := tv;
                Inc(j, 2);
            end;

            // do include colors?
            if (EQR_VF_Colors in VertexFormat) then
            begin
                doFreeColor := False;

                // do pre-calculate lightining or use the material color?
                if (m_pPreCalculatedLight.Enabled) then
                begin
                    // by default, normal exists
                    foundNormal := True;

                    // are normals also included?
                    if (not(EQR_VF_Normals in VertexFormat)) then
                    begin
                        // is normal index out of bounds?
                        if (srcVertex.m_NormalIndex >= normalCount) then
                        begin
                            // normal isn't available
                            foundNormal := False;
                        end
                        else
                        begin
                            // get vertex normal
                            normal := m_Normals[srcVertex.m_NormalIndex];

                            // do convert right hand <-> left hand coordinate system?
                            if (m_RHToLH) then
                                // apply conversion
                                normal.X := -normal.X;
                        end;
                    end;

                    // calculate lightning from pre-calculated light
                    if (foundNormal) then
                    begin
                        doFreeColor := True;
                        pMeshColor  := CalculateLight(normal, m_pPreCalculatedLight);
                    end
                    else
                        // unfortunately normal isn't available, so use the ambient color (not the
                        // best solution, but for lack of better...)
                        pMeshColor := m_pPreCalculatedLight.Ambient;
                end
                else
                begin
                    // use default color
                    pMeshColor := Color;
                end;

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 4);
                mesh[meshIndex].m_Buffer[j]     := pMeshColor.GetRedF;
                mesh[meshIndex].m_Buffer[j + 1] := pMeshColor.GetGreenF;
                mesh[meshIndex].m_Buffer[j + 2] := pMeshColor.GetBlueF;
                mesh[meshIndex].m_Buffer[j + 3] := pMeshColor.GetAlphaF;
                Inc(j, 4);

                if (doFreeColor) then
                    pMeshColor.Free;
            end;

            Dec(glCmd);
            Inc(i, 3);
        end;

        // go to next OpenGL command
        glCmd := m_pParser.m_GLCmds[i];
    end;

    // canceled?
    if (Assigned(hIsCanceled) and hIsCanceled) then
        Exit(True);

    // no aligned-axis bounding box tree to populate?
    if (not Assigned(pAABBTree)) then
        Exit(True);

    // populate aligned-axis bounding box tree
    Result := TQRModelHelper.PopulateAABBTree(mesh, pAABBTree, hIsCanceled);
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetMesh(index, nextIndex: NativeUInt;
                          interpolationFactor: Double;
                                     out mesh: TQRMesh;
                                  hIsCanceled: TQRIsCanceledEvent): Boolean;
type
    TQRSingleArray = array of Single;
var
    srcFrame, intFrame:                                                   TQRMD2Frame;
    stride, normalCount, i, j, meshIndex, glCmd:                          NativeInt;
    srcVertex, intVertex:                                                 TQRMD2Vertex;
    ucpVertex, ucpIntVertex, finalVertex, normal, intNormal, finalNormal: TQRVector3D;
    tu, tv:                                                               Single;
    pMeshColor:                                                           TQRColor;
    foundNormal, doFreeColor:                                             Boolean;
    glCmdsSingle:                                                         TQRSingleArray;
begin
    // is frame index out of bounds?
    if ((index >= GetMeshCount) or (nextIndex >= GetMeshCount)) then
        Exit(False);

    // get normal count
    normalCount := Length(m_Normals);

    // do use normals and pre-calculated normals table wasn't populated?
    if ((EQR_VF_Normals in VertexFormat) and (normalCount = 0)) then
        Exit(False);

    // get source frame from which mesh should be extracted, and frame to interpolate with
    srcFrame := m_pParser.m_Frames[index];
    intFrame := m_pParser.m_Frames[nextIndex];

    // basically stride is the coordinates values size
    stride := 3;

    // do include m_Normals?
    if (EQR_VF_Normals in VertexFormat) then
        Inc(stride, 3);

    // do include texture coordinates?
    if (EQR_VF_TexCoords in VertexFormat) then
        Inc(stride, 2);

    // do include colors?
    if (EQR_VF_Colors in VertexFormat) then
        Inc(stride, 4);

    i      := 0;
    glCmd  := m_pParser.m_GLCmds[i];

    // iterate through OpenGL commands (negative value is for triangle fan,
    // positive value is for triangle strip, 0 means list end)
    while (glCmd <> 0) do
    begin
        // is canceled?
        if (Assigned(hIsCanceled) and hIsCanceled) then
            Exit(False);

        // the first command is the number of vertices to process, already read, so skip it
        Inc(i);

        // add mesh to output
        SetLength(mesh, Length(mesh) + 1);
        meshIndex := Length(mesh) - 1;

        // create and populate new vertex for the current command
        mesh[meshIndex].m_Name      := 'qr_md2';
        mesh[meshIndex].m_Stride    := stride;
        mesh[meshIndex].m_Format    := VertexFormat;
        mesh[meshIndex].m_CoordType := EQR_VC_XYZ;

        // search for OpenGL command type
        if (glCmd < 0) then
        begin
            mesh[meshIndex].m_Type := EQR_VT_TriangleFan;
            glCmd                  := -glCmd;
        end
        else
            mesh[meshIndex].m_Type := EQR_VT_TriangleStrip;

        j := 0;

        // iterate through OpenGL commands to process
        while (glCmd > 0) do
        begin
            // is canceled?
            if (Assigned(hIsCanceled) and hIsCanceled) then
                Exit(False);

            // get source vertex, and vertex to interpolate with
            srcVertex := srcFrame.m_Vertex[m_pParser.m_GLCmds[i + 2]];
            intVertex := intFrame.m_Vertex[m_pParser.m_GLCmds[i + 2]];

            // uncompress vertices
            ucpVertex    := UncompressVertex(srcFrame, srcVertex);
            ucpIntVertex := UncompressVertex(intFrame, intVertex);

            // do convert right hand <-> left hand coordinate system?
            if (m_RHToLH) then
            begin
                // apply conversion
                ucpVertex.X    := -ucpVertex.X;
                ucpIntVertex.X := -ucpIntVertex.X;
            end;

            // calculate final mesh vertex
            finalVertex := ucpVertex.Interpolate(ucpIntVertex, interpolationFactor);

            // populate vertex buffer
            SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 3);
            mesh[meshIndex].m_Buffer[j]     := finalVertex.X;
            mesh[meshIndex].m_Buffer[j + 1] := finalVertex.Y;
            mesh[meshIndex].m_Buffer[j + 2] := finalVertex.Z;
            Inc(j, 3);

            // do include m_Normals?
            if (EQR_VF_Normals in VertexFormat) then
            begin
                // is normal index out of bounds?
                if (srcVertex.m_NormalIndex >= normalCount) then
                    Exit(False);

                // get vertex normal, and normal to interpolate with
                normal    := m_Normals[srcVertex.m_NormalIndex];
                intNormal := m_Normals[intVertex.m_NormalIndex];

                // do convert right hand <-> left hand coordinate system?
                if (m_RHToLH) then
                begin
                    // apply conversion
                    normal.X    := -normal.X;
                    intNormal.X := -intNormal.X;
                end;

                // calculate final vertex normal
                finalNormal := normal.Interpolate(intNormal, interpolationFactor);

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 3);
                mesh[meshIndex].m_Buffer[j]     := finalNormal.X;
                mesh[meshIndex].m_Buffer[j + 1] := finalNormal.Y;
                mesh[meshIndex].m_Buffer[j + 2] := finalNormal.Z;
                Inc(j, 3);
            end;

            // do include texture coordinates?
            if (EQR_VF_TexCoords in VertexFormat) then
            begin
                // reinterpret OpenGL commands array as an array of single
                glCmdsSingle := TQRSingleArray(m_pParser.m_GLCmds);

                // get vertex texture coordinates
                tu := glCmdsSingle[i];
                tv := glCmdsSingle[i + 1];

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 2);
                mesh[meshIndex].m_Buffer[j]     := tu;
                mesh[meshIndex].m_Buffer[j + 1] := tv;
                Inc(j, 2);
            end;

            // do include colors?
            if (EQR_VF_Colors in VertexFormat) then
            begin
                doFreeColor := False;

                // do pre-calculate lightining or use the material color?
                if (m_pPreCalculatedLight.Enabled) then
                begin
                    // by default, normal exists
                    foundNormal := True;

                    // are normals also included?
                    if (not(EQR_VF_Normals in VertexFormat)) then
                    begin
                        // is normal index out of bounds?
                        if (srcVertex.m_NormalIndex >= normalCount) then
                        begin
                            // normal isn't available
                            foundNormal := False;
                        end
                        else
                        begin
                            // get vertex normal, and normal to interpolate with
                            normal    := m_Normals[srcVertex.m_NormalIndex];
                            intNormal := m_Normals[intVertex.m_NormalIndex];

                            // do convert right hand <-> left hand coordinate system?
                            if (m_RHToLH) then
                            begin
                                // apply conversion
                                normal.X    := -normal.X;
                                intNormal.X := -intNormal.X;
                            end;

                            // calculate final vertex normal
                            finalNormal := normal.Interpolate(intNormal, interpolationFactor);
                        end;
                    end;

                    // calculate lightning from pre-calculated light
                    if (foundNormal) then
                    begin
                        doFreeColor := True;
                        pMeshColor   := CalculateLight(finalNormal, m_pPreCalculatedLight);
                    end
                    else
                        // unfortunately normal isn't available, so use the ambient color (not the
                        // best solution, but for lack of better...)
                        pMeshColor := m_pPreCalculatedLight.Ambient;
                end
                else
                begin
                    // use default color
                    pMeshColor := Color;
                end;

                SetLength(mesh[meshIndex].m_Buffer, Length(mesh[meshIndex].m_Buffer) + 4);
                mesh[meshIndex].m_Buffer[j]     := pMeshColor.GetRedF;
                mesh[meshIndex].m_Buffer[j + 1] := pMeshColor.GetGreenF;
                mesh[meshIndex].m_Buffer[j + 2] := pMeshColor.GetBlueF;
                mesh[meshIndex].m_Buffer[j + 3] := pMeshColor.GetAlphaF;
                Inc(j, 4);

                if (doFreeColor) then
                    pMeshColor.Free;
            end;

            Dec(glCmd);
            Inc(i, 3);
        end;

        // go to next OpenGL command
        glCmd := m_pParser.m_GLCmds[i];
    end;

    Result := True;
end;
//--------------------------------------------------------------------------------------------------
function TQRMD2Model.GetMeshCount: NativeUInt;
begin
    Result := m_pParser.m_Header.m_FrameCount;
end;
//--------------------------------------------------------------------------------------------------

end.
