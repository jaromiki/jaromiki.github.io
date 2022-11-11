#include <windows.h>	// hlaviËkov˝ s˙bor Windows kniûnice
#include <gl\gl.h>		// hlaviËkov˝ s˙bor OpenGL32 kniûnice
#include <gl\glu.h>		// hlaviËkov˝ s˙bor GLu32 kniûnice
#include <gl\glaux.h>	// hlaviËkov˝ s˙bor GLaux kniûnice 

#define obraz_x 800			//horizontalne rozlisenie
#define obraz_y 600			//vertikalne rozlisenie
#define obraz_bit 16		//pocet bitov na 1 pixel

HDC			hDC=NULL;		// priv·tny GDI Device Context
HGLRC		hRC=NULL;		// Rendering Context
HWND		hWnd=NULL;		// Handle na okno
HINSTANCE	hInstance;		// Inötalacia programu

char	MenoApplikacie[]="NaËÌtanie text˙ry";
bool	keys[256];			// pole - pr·ca s klavesnicou
bool	fullscreen=1;		// indik·tor pre fullscreen
bool	active=1;			// indikator aktivy (negacia priznaku minimalizacie)

LRESULT	CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);	// deklar·cia WndProc
void DrawGLScene(void);				//deklaracia funkcie, v tejto funkcii je vsetko co sa ma vykreslit
int LoadGLTextures(void);

void ReSizeGLScene(GLsizei width, GLsizei height)		// funkcia pro zmenu velkosti okna
{	if (height==0) height=1;
	glViewport(0,0,width,height);		// Viewport (pohlad)
	glMatrixMode(GL_PROJECTION);		// projekcia
	glLoadIdentity();					// Reset pohladu - nacita jednotkovu maticu
	gluPerspective(45.0f,(GLfloat)width/(GLfloat)height,0.1f,100.0f);
	/* gluPerspective - nastavuje perspektivu kamery, ako bude vypadat priestor z pohladu kamery.
	1. parameter urcuje zorn˝ uhol kamery. 2.param. - gldAspect je pomer v˝öky a öÌrky zobrazovanej plochy.
	3. par. udava vzdialenost od ktorej je vidiet vykreslovane objekty
	4. par. udava vzdialenost do ktorej je vidiet vykreslovane objekty */
	glMatrixMode(GL_MODELVIEW);			// Modelview
	glLoadIdentity();					// Reset The Modelview Matrix
}

int InitGL(void)					// vöetky nastavenia
{	
	if (!LoadGLTextures())								// naËÌtanie text˙r
	{	return FALSE;}									// ak sa text˙ry nepodarilo naËÌtaù

	glEnable(GL_TEXTURE_2D);							// Povolenie zobrazovanie text˙r
	glShadeModel(GL_SMOOTH);		/*nastavuje tienovanie
	GL_SMOOTH - objekty su tienovane t.j. prechody medzi farbami bodov su plinule (gouradovo (s)tienovanie)
	GL_FLAT   - objekty nie su tienovane ziadne plinule prechody */
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f); //specifikuje hodnoty na cistenie pomocou glClear par.: red, green, blue, alpha (cierny podklad)
	glClearDepth(1.0f);  //specifikuje hodnoty na cistenie pomocou glClear par.: depth (hlbka)
	/* ZAPNUTIE HLBKOVEHO TESTU */
	glEnable(GL_DEPTH_TEST);		// zapne hÂbkov˝ test
	glDepthFunc(GL_LEQUAL);			// typ hÂbkovÈho testu
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);	// ìre·lnejöieî perspektÌvne v˝poËty
	
	return TRUE;
}

void KillGLWindow(void)					// ruöÌme okno
{	if (fullscreen)						// Fullscreen (ano/nie)
	{	
		ChangeDisplaySettings(NULL,0);	//zmena grafickeho rezimu na predastavene rozlisenie
		ShowCursor(1);					//zviditelenenie kurzoru myöi
	}
	if (hRC)
	{	
		if(!wglMakeCurrent(NULL,NULL))	// make the rendering context not current
		{	MessageBox(NULL,"DC a RC chyba.","ERROR",MB_OK | MB_ICONINFORMATION);}
		if(!wglDeleteContext(hRC))		// delete the rendering context
		{	MessageBox(NULL,"Chyba: Delete Rendering Context.","ERROR",MB_OK | MB_ICONINFORMATION);}
		hRC=NULL;
	}
	if (hDC && !ReleaseDC(hWnd,hDC))		//uvolnuje kontext zariadenia
	{	
		MessageBox(NULL,"Chyba: Uvolnenia Device Context.","ERROR",MB_OK | MB_ICONINFORMATION);
		hDC=NULL;
	}
	if (hWnd && !DestroyWindow(hWnd))   //ukoncuje aplikaciu, posiela spravu WM_DESTROY
	{	
		MessageBox(NULL,"Chyba: hWnd.","ERROR",MB_OK | MB_ICONINFORMATION);
		hWnd=NULL;
	}
	if (!UnregisterClass("OpenGL",hInstance)) //removes a window class, freeing the memory required for the class.
	{	
		MessageBox(NULL,"Nejde odregistrovat okno.","ERROR",MB_OK | MB_ICONINFORMATION);
		hInstance=NULL;
	}
}

/*	Parametry pri tvorbe OpenGL okna		*
 *	title			- titulek okna			*
 *	width			-  sirka okna			*
 *	height			- vyska okna			*
 *	bits			- pocet bitu na pixel	*/

BOOL CreateGLWindow(char* title, int width, int height, int bits, bool fullscreen_)
{
	GLuint		PixelFormat;
	WNDCLASSEX	wc;		//miesto pre strukturu pouzitu na registraciu triedy okna
	DWORD		dwExStyle;
	DWORD		dwStyle;
	RECT		WindowRect;					//miesto pre velkost okna
	WindowRect.left=(long)0;
	WindowRect.right=(long)width;
	WindowRect.top=(long)0;
	WindowRect.bottom=(long)height;

	fullscreen=fullscreen_;
	wc.cbSize			= sizeof(WNDCLASSEX); //velkost struktury WINDOWCLASSEX
	wc.style				= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;  /*nastavenie stylu okna
				CS_HREDRAW - prekreslenie okna pri zmene horizontalne velkosti okna
				CS_VREDRAW - -----------""-------------- vertikalnej  ------""-----
				CS_OWNDC - vyhradi jedinecny kontext zariadenia pre kazde okno  */
	wc.lpfnWndProc		= (WNDPROC) WndProc; //smernika na funkciu na spracovanie sprav
	wc.cbClsExtra		= 0; //specifikuje pocet extra bytov na konci struktury triedy okien na ukladanie informacii
	wc.cbWndExtra		= 0; //-------""--------------------, ktore sa maju vyhradit po vyskyte okna
	wc.hInstance		= hInstance;		//handle (ukazovatel) na instalaciu (paremeter z WinMain)
	wc.hIcon			= LoadIcon(NULL, IDI_WINLOGO); //handle ikony  ktora sa ma pouzit pre danu truedu okien
	wc.hCursor			= LoadCursor(NULL, IDC_ARROW); //handle kurzora ktory ----------------""----------------
	wc.hbrBackground	= NULL;		//handle stetca pouziteho na vyfarbenie pozadia okna
	wc.lpszMenuName		= NULL;		//ukazovatel na sz(StringZero) v ktorom je nazov pre menu (!)triedy
	wc.lpszClassName	= "OpenGL";	//ukaz na sz, ktory obsahuje nazov triedy. Tento nazov sa pouzie v parametry lpClassName vo funkcii CreateWindowEx
	wc.hIconSm			= NULL;		//handle k ikone, ktora sa ma pouzit v titulkovom pruhu okien, vytvorenych touto triedou. Ak je NULL pouzije sa hIcon

	if(!RegisterClassEx(&wc))		//registracia novej tiredy okna, pouzivanych na vytavaranie okien
	{	MessageBox(NULL,"Chyba pri registracii triedy okna.","ERROR",MB_OK|MB_ICONEXCLAMATION);return 0;}

	if(fullscreen)	//ZMENA DO FULLSCREEN
	{	
		DEVMODE dmScreenSettings;	//struktura popisujuca graficky mod
		memset(&dmScreenSettings,0,sizeof(dmScreenSettings));		//vynuluje dmScreenSettings
		dmScreenSettings.dmSize=sizeof(dmScreenSettings);			//nastavy velkost
		dmScreenSettings.dmPelsWidth	= width;		//vertikalne roazlisenie
		dmScreenSettings.dmPelsHeight	= height;		//horizontalne rozlisenie
		dmScreenSettings.dmBitsPerPel	= bits;			//pocet bitov na pixel
		dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT; //specifikuje ktore polozky v strukture su menene ??
		/**** zmena modu !!! ****/
		{	int mod;
			mod=ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);
			if(mod!=DISP_CHANGE_SUCCESSFUL)
			{	
				switch(mod)
				{	
					case(DISP_CHANGE_RESTART):MessageBox(NULL,"The computer must be restarted in order for the graphics mode to work.","Chyba pri inicializacii grafickeho rezimu",MB_ICONERROR);break;
					case(DISP_CHANGE_BADFLAGS):MessageBox(NULL,"An invalid set of flags was passed in.","Chyba pri inicializacii grafickeho rezimu",MB_ICONERROR);break;
					case(DISP_CHANGE_FAILED):MessageBox(NULL,"The display driver failed the specified graphics mode.","Chyba pri inicializacii grafickeho rezimu",MB_ICONERROR);break;
					case(DISP_CHANGE_BADMODE):MessageBox(NULL,"The graphics mode is not supported.","Chyba pri inicializacii grafickeho rezimu",MB_ICONERROR);break;
				}
				if(MessageBox(NULL,"Chyba pri inicializacii grafickeho rezimu. Chcete pokracovat v okne?","Chyba",MB_YESNO|MB_ICONEXCLAMATION)==IDYES)
				{	fullscreen=0;}  //pokracovanie v okne
				else
				{	MessageBox(NULL,"Program se uzavrie.","ERROR",MB_OK|MB_ICONSTOP);return FALSE;}
			}
		}
	}

	if (fullscreen)
	{	
		dwExStyle=WS_EX_APPWINDOW; //Forces a top-level window onto the taskbar when the window is minimized.
		dwStyle=WS_POPUP;		//vytvara prekryte okno
		ShowCursor(0);			//skryje kurzor
	}
	else
	{	
		dwExStyle=WS_EX_APPWINDOW | WS_EX_WINDOWEDGE; //okno ktore ma ohranicenie s vyvysenou hranou (WS_EX_WINDOWEDGE)
		dwStyle=WS_OVERLAPPEDWINDOW; //vytvara okno s titulkovym pruhom, ohranicenim, okno je ohraniceny tenkou ciarov
	}

	AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle); //vypocitava velkost okna
	/*vytvara okno, generuje: WM_GETMINMAXINFO,WM_NCCREATE,WM_NCCALCSIZE,WM_CREATA,WM_SHOWWINDOW */
	hWnd = CreateWindowEx( dwExStyle,	//rozsireny styl okna
					"OpenGL",		//ukazovatel na sz obsahujuci platny nazov triedy pre okno (registrovanej triedy)
					title,			//ukazovatel na sz obsahujuci meno okna (zobrazuje sa titulkovom pruhu)
					dwStyle | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,  //...
					0, 0,				//pozicia okna na obrazovke (x,y)
					WindowRect.right-WindowRect.left,	//sirka okna
					WindowRect.bottom-WindowRect.top,	//vyska okna
					NULL,				//handle k rodicovskemu oknu
					NULL,				//handle k menu okna. Ak sa ma pouzit trieda menu pouzite hodnotu NULL
					hInstance,		//handle vyskytu aplikacie, ktora vytvara okno
					NULL);			//ukazovatel na data ktora budu odovzdane oko lParam spravy WM_CREATE
	if (!hWnd)		//ak sa okno nepodarilo vytvorit koniec
	{	KillGLWindow();MessageBox(NULL,"Chyba pri tvorbe okna.","ERROR",MB_OK|MB_ICONEXCLAMATION);return FALSE;}
/*Abychom mohli pracovat s OpenGL musÌme premostit vykreslov·nÌ na rozhranÌ OpenGL tÌm,
ze nastavÌme tzv. PixelFormatDescriptor, kter˝ slouzÌ jako komunik·tor mezi v˝stupnÌmi
rutinami windowsu a v˝stupnÌmi rutinami knihovny OpenGL. Poukazuje na to, jakÈ rozdÌly
jsou v zobrazov·nÌ barev atd. Toto nastavenÌ najdete ve funkci bSetupPixelFormat.
Pokud v·s zajÌmajÌ jednotlivÈ polozky ve strukture PIXELFORMATDESCRIPTOR, najdete to v helpu.*/
	static	PIXELFORMATDESCRIPTOR pfd=
	{
		sizeof(PIXELFORMATDESCRIPTOR),	//velkost PIXELFORMATDESCRIPTOR
		1,							//verzia tato hodnota ma byt nastavena na 1
		PFD_DRAW_TO_WINDOW |		//support window  	-(The buffer can draw to a window or device surface.)
		PFD_SUPPORT_OPENGL |	//support OpenGL  	-(The buffer supports OpenGL drawing.)
		PFD_DOUBLEBUFFER,		//double buffered  	-(The buffer is double-buffered. This flag and PFD_SUPPORT_GDI are mutually exclusive in the current generic implementation
		PFD_TYPE_RGBA,			//RGBA type  			-(RGBA pixels. Each pixel has four components in this order: red, green, blue, and alpha.)
		(BYTE)bits,  		//<bits> -bit color depth  -(For RGBA pixel types, it is the size of the color buffer, excluding the alpha bitplanes.)
		0, 0, 0, 0, 0, 0,	//color bits ignored  		-(cRedBits,cRedShift,cGreenBits,cGreenShift,cBlueBits,cBlueShift)
		0,	0,					//no alpha buffer, shift bit ignored ,  -(cAlphaBits,cAlphaShift)
		0,					//no accumulation buffer  	-(cAccumBits)
		0, 0, 0, 0,   		//accum bits ignored  		-(cAccumRedBits,cAccumGreenBits,cAccumBlueBits,cAccumAlphaBits)
		16,					//16-bit z-buffer,  			-(cDepthBits - Specifies the depth of the depth (z-axis) buffer.)
		0,					//no stencil buffer  		-(cStencilBits - Specifies the depth of the stencil buffer.)
		0, 					//no auxiliary buffer  		-(cAuxBuffers)
		PFD_MAIN_PLANE,		//main layer  -(iLayerType - Ignored. Earlier implementations of OpenGL used this member, but it is no longer used.)
		0,					//reserved  					-(bReserved)
		0, 0, 0				//layer masks ignored  		-(dwLayerMask,dwVisibleMask,dwDamageMask)
	};

	hDC=GetDC(hWnd); 		//ziskanie handla obrazoveho kontextu zariadenia (DC) klienskej casti okna (s hanflom hWnd)
	if (!hDC)
	{	
		KillGLWindow();
		MessageBox(NULL,"Nejde vytvorit GL Device Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}
	/*The ChoosePixelFormat function attempts to match an appropriate pixel format supported by a device context to a given pixel format specification.*/
	PixelFormat=ChoosePixelFormat(hDC,&pfd); //device context to search for a best pixel format match, pixel format for which a best match is sought
	if (!PixelFormat)
	{	
		KillGLWindow();
		MessageBox(NULL,"Nejde n·jst PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}
	/*The SetPixelFormat function sets the pixel format of the specified device context to the format specified by the iPixelFormat index.*/
	if(!SetPixelFormat(hDC,PixelFormat,&pfd))
	{	
		KillGLWindow();
		MessageBox(NULL,"Nejde nastavit PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}
	/*The wglCreateContext function creates a new OpenGL rendering context,
	which is suitable for drawing on the device referenced by hdc.
	The rendering context has the same pixel format as the device context.*/
	hRC=wglCreateContext(hDC);  // create a rendering context
	if (!hRC)                //return value is a valid handle to an OpenGL rendering context.
	{	
		KillGLWindow();
		MessageBox(NULL,"Nejde vytvorit GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}
   /*The wglMakeCurrent function makes a specified OpenGL rendering context the calling
   thread's current rendering context. All subsequent OpenGL calls made by the thread are
   drawn on the device identified by hdc. You can also use wglMakeCurrent to change the
   calling thread's current rendering context so it's no longer current. */
	if(!wglMakeCurrent(hDC,hRC))  // make it the calling thread's current rendering context
	{	
		KillGLWindow();
		MessageBox(NULL,"Nejde aktivovat GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}

	ShowWindow(hWnd,SW_SHOW);		//zvyditelnie okna, posiela spravu WM_SHOWWINDOW
	SetForegroundWindow(hWnd);		//nastavuje okno na to s ktorym pracuje uzivatel
	SetFocus(hWnd);					//nastavy vstup klavesnice na toto okno
	if(!fullscreen)
	{
		GetClientRect(hWnd,&WindowRect);				//zistenie rozmerov u6ivatelskej casti okna
		ReSizeGLScene(WindowRect.right,WindowRect.bottom);	//nastavenie perspektivy
	}
	else ReSizeGLScene(width, height);	//definovana v tomto subore

	if (!InitGL())					//incializacia noveho okna
	{
		KillGLWindow();
		MessageBox(NULL,"Chyba pri inicializ·cii.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;
	}

	
	return 1;
}

/*********************************************************************************************/
/*Funkcia na spracovanie sprav. Spravy su posielane do funkcie pomocou DispatchMessage(&msg);*/

LRESULT CALLBACK WndProc(HWND	hWnd,UINT	uMsg,WPARAM	wParam,LPARAM	lParam)
{	switch (uMsg)
	{	
		case WM_ACTIVATE:			//generovane ak je okno aktivizovane, alebo deaktivizovane
		{	
			if (!HIWORD(wParam))	//HIWORD(wParam) -priznak minimalizovaneho okna
			{active=TRUE;}			//okno nie je minimalizovane
			else active=FALSE;		//okno     je minimalizovane
			return 0;
		}
		/*case WM_SYSCOMMAND:{  switch (wParam){  case SC_SCREENSAVE: case SC_MONITORPOWER: return 0;}break;}*/
		case WM_CLOSE:{PostQuitMessage(0);return 0;}	//generuje WM_QUIT a wParam=0
		case WM_KEYDOWN:{keys[wParam] = 1;return 0;}	//stlacenie klavesy
		case WM_KEYUP:	{keys[wParam] = 0;return 0;}	//pustenie klavesy
		case WM_SIZE:	{ReSizeGLScene(LOWORD(lParam),HIWORD(lParam));return 0;}  //zmena velkosti, funkcia je definovana v tomto subore
	}
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}

/**********VSTUPNA FUNCKIA*****************************************************/
int WINAPI WinMain(HINSTANCE hInstance_,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
{	
	MSG		msg;		//mesto pre strukturu MESSAGE - pre spravy
	BOOL	koniec=0;
	hInstance=hInstance_;
	
	if (MessageBox(NULL,"Cela obrazovka?", "Nastavenie obrazovky (pocas behu pomocou F1)",MB_YESNO|MB_ICONQUESTION)==IDNO)
	{	fullscreen=FALSE;}
	if (!CreateGLWindow(MenoApplikacie,obraz_x,obraz_y,obraz_bit, fullscreen))return 0;
	while(!koniec)		//pokial nie je koniec
	{
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))	 /*ak nie je pristupna sprave vrati 0
		ak je prisupna sparava vrati nenulu a zapise ju do struktury msg,
		NULL - HWND spracuva spravy z aktualneho vlakna, PM_REMOVE - presuva spravu z radu sprav
		na rozdiel od GetMessage, PeekMessage necaka na pijatie dalsiej sprave pred vratenim (hodnoty)*/
		{				//sprava je pristupna - treba ju spracovat
			if (msg.message==WM_QUIT)koniec=1;
			else
			{	
				TranslateMessage(&msg);	//preklada virtualne spravy (VK_*) na znakove spravy (WM_CHAR)
				DispatchMessage(&msg);	//posiela spravy aplikacie prislusnej funkcie (WndProc)na spracovanie
			}							//- "" -	  vracia to co vracia WndProc
		}
		else	//ziadna sprava - cinnost ktoru ma vykonavat mimo spracovavania sprav
		{	if (active)DrawGLScene();	//ak je program aktivny vykresluj
			if (keys[VK_ESCAPE])koniec=1;	//ak je stlaceny Esc ukonc
			else SwapBuffers(hDC);		//prehodi buffer
			if (keys[VK_F1])			//cez F1 prepinanie z Fullscreen do okna
			{	
				keys[VK_F1]=FALSE;
				KillGLWindow();
				fullscreen=!fullscreen;
				if (!CreateGLWindow(MenoApplikacie,obraz_x,obraz_y,obraz_bit,fullscreen))return 0;
			}
		}
	}
	KillGLWindow();
	return (msg.wParam);		//funkcia WinMain ma vratit hodnotu, ktora bola pouzita z funkciou PostQuitMessage
}
