#include <windows.h>
#include <gl\gl.h>
#include <gl\glu.h>
#include <gl\glaux.h>
#include <stdio.h>


extern bool	keys[256];			// pole - pr�ca s klavesnicou

#define POCET_TEXTUR 1					
GLuint	texture[POCET_TEXTUR];
char	texture_name[POCET_TEXTUR][20]={"data/textura.bmp"};

float uholx,uholy,uholz;

void DrawGLScene(void)				// vlastn� kreslenie
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	//cisti buffer v aktualnom viewporte a to iba color a hlbkovy bit
	glLoadIdentity();					//Nahradi aktualnu maticu z identicku maticu
	glTranslatef(0.0f,0.0f,-5.0f);	//nasoby aktualnu maticu z transformacnou maticou - posunie pociatok
	
	glRotatef(uholx,1.0f,0.0f,0.0f);
	glRotatef(uholy,0,1,0);
	glRotatef(uholz,0,0,1);


	glColor3f(1.0f,1.0f,1.0f);		//biela farba	
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	glBegin(GL_QUADS);
		// Front Face
		glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);
		// Back Face
		glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);
		glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);
		// Top Face
		glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);
		glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);
		// Bottom Face
		glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);
		glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);
		// Right face
		glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);
		glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);
		// Left Face
		glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);
	glEnd();
	
	uholx+=0.2f;
	uholy+=0.3f;
	uholz+=0.4f;
}

AUX_RGBImageRec *LoadBMP(char *Filename)			// Na��tanie bitmapov�ho obr�zka
{
	FILE *File=NULL;								// smernik na subor

	if (!Filename)return NULL;						// sk��ka �i meno s�boru bolo zadan�
	File=fopen(Filename,"r");						// otvorenie s�boru na ��tanie
	if (File)										// existuje s�bor ?
	{
		fclose(File);								// Uzatvorenie s�bora
		return auxDIBImageLoad(Filename);			// Na��ta obr�zok a vr�ti pointer
	}
	return NULL;									// Ak sa obr�zok nena��tal vr�ti NULL
}

int LoadGLTextures()								// Na��ta obr�zky a ulo�i ako textury
{
	int Status=TRUE,i;								// indikator
	AUX_RGBImageRec *TextureImage;					// miesto pre �trukt�ru

	for(i=0;i<POCET_TEXTUR;i++)
	{	
		TextureImage=NULL;
		if (TextureImage=LoadBMP(texture_name[i]))
		{
			glGenTextures(1, &texture[i]);
			glBindTexture(GL_TEXTURE_2D, texture[i]);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage->sizeX, TextureImage->sizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage->data);
		}
		else 
		{	MessageBox(NULL,"Chyba na��tania obr�zka.",texture_name[i],MB_ICONERROR);Status=false;}

		if (TextureImage)									// Ak textura existuje
		{
			if (TextureImage->data)free(TextureImage->data);// ak existuju data uvo�ni z pam�te
			free(TextureImage);								// uvo�ni �trukt�ru
		}
	}
	return Status;
}

//Tato funkcia rob� presne to ist� iba sa pou�ije LoadImage() namiesto auxDIBImageLoad()
/*
extern	HWND		hWnd;
extern	HINSTANCE	hInstance; 

int LoadGLTextures()				// Load Bitmaps And Convert To Textures
{
	HANDLE hBMP;
	BITMAP ImgInfo;
	int i;
	
	glGenTextures(POCET_TEXTUR, &texture[0]); 				// Create The Texture
	
	for(i=0;i!=POCET_TEXTUR;i++)
	{	hBMP=LoadImage(hInstance,texture_name[i],IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION|LR_LOADFROMFILE);
		if(!hBMP){MessageBox(hWnd,"Load image fail.",texture_name[i],MB_ICONERROR);return false;}
		GetObject(hBMP,sizeof(BITMAP),&ImgInfo);
		glBindTexture(GL_TEXTURE_2D, texture[i]);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);       //0x080E0 = GL_BGR_EXT
		glTexImage2D(GL_TEXTURE_2D, 0, 3, ImgInfo.bmWidth, ImgInfo.bmHeight, 0, 0x080E0, GL_UNSIGNED_BYTE,ImgInfo.bmBits);
		DeleteObject(hBMP);
	}
	return true;
}*/