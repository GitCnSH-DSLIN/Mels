// *************************************************************************************************
// * ==> Main -------------------------------------------------------------------------------------*
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

#ifndef MainH
#define MainH

// vcl
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.Menus.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>

// std
#include <vector>
#include <map>
#include <time.h>

// Mels library
#include <UTQRMD3.hpp>

// engine
#include "QR_Shader_OpenGL.h"

/**
* MD3 demo main form
*@author Jean-Milost Reymond
*/
class TMainForm : public TForm
{
    __published:
        TPanel *paRendering;

        void __fastcall FormCreate(TObject* pSender);
        void __fastcall FormResize(TObject* pSender);
        void __fastcall FormKeyPress(TObject* pSender, WideChar& key);
        void __fastcall FormPaint(TObject* pSender);

    public:
        /**
        * Constructor
        *@param pOwner - form owner
        */
        __fastcall TMainForm(TComponent* pOwner);

        /**
        * Destructor
        */
        virtual __fastcall ~TMainForm();

    protected:
        /**
        * Configure OpenGL with correct format descriptor
        */
        void __fastcall SetPixelFormatDescriptor();

        /**
        * Called when thread do nothing else
        *@param pSEnder - event sender
        *@param[in, out] done - if true, idle loop was ternimated and may do nothing else
        */
        void __fastcall IdleLoop(TObject* pSender, bool& done);

        /**
        * Renders (i.e. prepares and draws) scene
        */
        void __fastcall RenderGLScene();

        /**
        * Draws scene
        *@param elapsedTime - elapsed time since last draw
        */
        void __fastcall Draw(const double& elapsedTime);

    private:
        /**
        * Frame structure, contains the local model cache
        */
        struct IFrame
        {
            TQRMesh*     m_pMesh;
            TQRAABBTree* m_pAABBTree;

            /**
            * Constructor
            *@param useCollisions - if true, collision will be used
            */
            IFrame(bool useCollisions);

            /**
            * Destructor
            */
            virtual ~IFrame();
        };

        typedef std::map<std::size_t, IFrame*> IFrames;

        /**
        * Item associating a texture identifier with a model name
        */
        struct ITextureItem
        {
            std::size_t  m_ID;
            std::wstring m_Name;

            /**
            * Constructor
            */
            ITextureItem();

            /**
            * Constructor
            *@param id - texture identifier
            *@param name - texture name to link with, as defined in model
            */
            ITextureItem(std::size_t id, const std::wstring& name);

            /**
            * Destructor
            */
            virtual ~ITextureItem();
        };

        typedef std::vector<ITextureItem> ITextureTable;

        IFrames           m_Frames;
        HDC               m_hDC;
        HGLRC             m_hRC;
        TQRMD3Model*      m_pMD3;
        QR_Shader_OpenGL* m_pColorShader;
        QR_Shader_OpenGL* m_pTextureShader;
        TQRTextures       m_Textures;
        TQRMatrix4x4      m_ProjectionMatrix;
        TQRMatrix4x4      m_ViewMatrix;
        TQRMatrix4x4      m_ModelMatrix;
        std::time_t       m_PreviousTime;
        double            m_InterpolationFactor;
        std::size_t       m_FrameIndex;
        bool              m_FullScreen;
        bool              m_UseShader;
        bool              m_Collisions;

        /**
        * Configures OpenGL
        */
        void ConfigOpenGL();

        /**
        * Builds shader
        *@param pVertexPrg - stream containing vertex program
        *@param pFragmentPrg - stream containing fragment program
        *@param pShader - shader to populate
        *@return true on success, otherwise false
        */
        bool BuildShader(TStream* pVertexPrg, TStream* pFragmentPrg, QR_Shader_OpenGL* pShader);

        /**
        * Loads MD3 model
        *@param useShader - if true, shader will be used
        *@return true on success, otherwise false
        */
        bool LoadModel(bool useShader);

        /**
        * Gets frame from local cache
        *@param index - frame index
        *@param pModel - model for which next frame should be get
        *@param useCollision - if true, collisions are used
        *@return frame
        */
        IFrame* GetFrame(std::size_t index, TQRMD3Model* pModel, bool useCollision);

        /**
        * Detects collision with mouse pointer and draws the polygons in collision
        *@param modelMatrix - model matrix
        *@param pAABBTree - aligned-axis bounding box tree
        *@param useShader - whether or not shader are used to draw model
        *@param collisions - whether or not collisions are visible
        */
        void DetectAndDrawCollisions(const TQRMatrix4x4& modelMatrix,
                                           TQRAABBTree*  pAABBTree,
                                           bool          useShader,
                                           bool          collisions);

        /**
        * Prepres the shader to draw the model
        *@param pShader - shader to prepare
        *@param textures - textures belonging to model
        */
        void PrepareShaderToDrawModel(QR_Shader_OpenGL* pShader, const TQRTextures& textures);

        /**
        * Loads model textures
        *@param textureTable - texture table
        *@return true on success, otherwise false
        */
        bool LoadTexture(const ITextureTable& textureTable);

        /**
        * Draws model
        *@param pGroup - group at which model belongs
        *@param pModel - model to draw
        *@param textures - textures belonging to model, in the order where they should be combined
        *@param matrix - model matrix
        *@param index - model mesh index
        *@param nextIndex - model mesh index to interpolate with
        *@param interpolationFactor - interpolation factor
        *@param useShader - whether or not shader are used to draw model
        *@param collisions - whether or not collisions are visible
        */
        void DrawModel(TQRMD3Model*         pModel,
                       const TQRTextures    textures,
                       const TQRMatrix4x4&  matrix,
                       NativeInt            index,
                       NativeInt            nextIndex,
                       const double         interpolationFactor,
                       bool                 useShader,
                       bool                 collisions);
};
extern PACKAGE TMainForm* MainForm;
#endif
