// *************************************************************************************************
// * ==> UTQRModelRenderer ------------------------------------------------------------------------*
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
 @abstract(@name provides a basic interface to implement a model renderer.)
 @image(Resources/Images/Documentation/Mels.svg)
 @author(Jean-Milost Reymond)
 @created(2015 - 2017, this file is part of the Mels library)
}
unit UTQRModelRenderer;

{$MODE Delphi}

interface

uses SysUtils,
     UTQRGeometry,
     UTQR3D,
     UTQRRenderer;

type
    {$REGION 'Documentation'}
    {**
     Basic interface to implement a model renderer
    }
    {$ENDREGION}
    TQRModelRenderer = class(TQRRenderer)
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
             Draws a mesh
             @param(mesh Mesh to draw)
             @param(translation Translation to apply to mesh)
             @param(rotationX Rotation on x axis to apply to mesh)
             @param(rotationY Rotation on y axis to apply to mesh)
             @param(rotationZ Rotation on z axis to apply to mesh)
             @param(scale Scaling to apply to mesh)
             @param(textures Model textures)
            }
            {$ENDREGION}
            procedure Draw(var mesh: TQRMesh;
                  const translation: TQRVector3D;
                          rotationX,
                          rotationY,
                          rotationZ: Single;
                        const scale: TQRVector3D;
                     const textures: TQRTextures); overload; virtual; abstract;

            {$REGION 'Documentation'}
            {**
             Draws a mesh
             @param(mesh Mesh to draw)
             @param(modelMatrix Model matrix to apply to mesh)
             @param(textures Model textures)
            }
            {$ENDREGION}
            procedure Draw(var mesh: TQRMesh;
                  const modelMatrix: TQRMatrix4x4;
                     const textures: TQRTextures); overload; virtual; abstract;

            {$REGION 'Documentation'}
            {**
             Draws a mesh using shader
             @param(mesh Mesh to draw)
             @param(modelMatrix Model matrix to apply to mesh)
             @param(textures Model textures)
             @param(pShader Shader that will be used to draw the model)
             @return(@true on success, otherwise @false)
            }
            {$ENDREGION}
            function Draw(var mesh: TQRMesh;
                 const modelMatrix: TQRMatrix4x4;
                    const textures: TQRTextures;
                           pShader: TQRShader): Boolean; overload; virtual; abstract;

            {$REGION 'Documentation'}
            {**
             Draws a mesh using shader
             @param(mesh Mesh to draw)
             @param(nextMesh Mesh to interpolate with)
             @param(modelMatrix Model matrix to apply to mesh)
             @param(interpolationFactor Interpolation factor)
             @param(textures Model textures)
             @param(pShader Shader that will be used to draw the model)
             @return(@true on success, otherwise @false)
            }
            {$ENDREGION}
            function Draw(var mesh: TQRMesh;
                    const nextMesh: TQRMesh;
                 const modelMatrix: TQRMatrix4x4;
               interpolationFactor: Single;
                    const textures: TQRTextures;
                           pShader: TQRShader): Boolean; overload; virtual; abstract;
    end;

implementation
//--------------------------------------------------------------------------------------------------
// TQRModelRenderer
//--------------------------------------------------------------------------------------------------
constructor TQRModelRenderer.Create;
begin
    inherited Create;
end;
//--------------------------------------------------------------------------------------------------
destructor TQRModelRenderer.Destroy;
begin
    inherited Destroy;
end;
//--------------------------------------------------------------------------------------------------

end.
