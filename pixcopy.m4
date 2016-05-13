/*
** note:  pixcopy.c is generated from pixcopy.m4
**        please modify pixcopy.m4 to make changes
*/

define(X1,
*dest++ = pixel;
)

define(X2,
X1
X1
)

define(X3,
X1
X1
X1
)

define(X4,
X2
X2
)

define(X_3,
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;
)

define(X_6,
X_3
X_3
)

define(X_9,
X_3
X_3
X_3
)

define(X_12,
X_6
X_6
)


define(XF,
pixel = srv_colortab[*source++];  ++prev;
$1

pixel = srv_colortab[*source++];  ++prev;
$1

pixel = srv_colortab[*source++];  ++prev;
$1

pixel = srv_colortab[*source++];  ++prev;
$1
)

define(MV,
pixel = *source++;  ++prev;
$1

pixel = *source++;  ++prev;
$1

pixel = *source++;  ++prev;
$1

pixel = *source++;  ++prev;
$1
)

define(AV,
pixel = srv_average[*source++][*prev++];
$1

pixel = srv_average[*source++][*prev++];
$1

pixel = srv_average[*source++][*prev++];
$1

pixel = srv_average[*source++][*prev++];
$1
)



define(CPY,
void $1()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	$2 *dest = ($2*) screen_pixels;

	for (i=0; i<40; i++)
	{
		$3
	}
}	
)

define(CCP,
void $1()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	$2 *dest = ($2*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			$3
		}
		else
		{
			source += 4;
			prev += 4;

			dest += $4;
		}
	}
}	
)

// single pixel routines

CPY(FDoPixelCopy4,dd,XF(X1))
CPY(FDoPixelAv4,dd,AV(X1))
CCP(CFDoPixelCopy4,dd,XF(X1),4)

CPY(FDoPixelCopy3,db,XF(X_3))
CPY(FDoPixelAv3,db,AV(X_3))
CCP(CFDoPixelCopy3,db,XF(X_3),12)

CPY(FDoPixelCopy2,dw,XF(X1))
CPY(FDoPixelAv2,dw,AV(X1))
CCP(CFDoPixelCopy2,dw,XF(X1),4)

// double pixel routines

CPY(DoPixelCopy4,dd,XF(X2))
CPY(DoPixelAv4,dd,AV(X2))
CCP(CDoPixelCopy4,dd,XF(X2),8)

CPY(DoPixelCopy3,db,XF(X_6))
CPY(DoPixelAv3,db,AV(X_6))
CCP(CDoPixelCopy3,db,XF(X_6),24)

CPY(DoPixelCopy2,dw,XF(X2))
CPY(DoPixelAv2,dw,AV(X2))
CCP(CDoPixelCopy2,dw,XF(X2),8)

// triple pixel routines

CPY(DoTrPixelCopy4,dd,XF(X3))
CPY(DoTrPixelAv4,dd,AV(X3))
CCP(CDoTrPixelCopy4,dd,XF(X3),12)

CPY(DoTrPixelCopy3,db,XF(X_9))
CPY(DoTrPixelAv3,db,AV(X_9))
CCP(CDoTrPixelCopy3,db,XF(X_9),36)

CPY(DoTrPixelCopy2,dw,XF(X3))
CPY(DoTrPixelAv2,dw,AV(X3))
CCP(CDoTrPixelCopy2,dw,XF(X3),12)

CPY(DoTrPixelCopy1,db,MV(X3))
CCP(CDoTrPixelCopy1,db,MV(X3),12)

// quad pixel routines

CPY(DoWidePixelCopy4,dd,XF(X4))
CPY(DoWidePixelAv4,dd,AV(X4))
CCP(CDoWidePixelCopy4,dd,XF(X4),16)

CPY(DoWidePixelCopy3,db,XF(X_12))
CPY(DoWidePixelAv3,db,AV(X_12))
CCP(CDoWidePixelCopy3,db,XF(X_12),48)

CPY(DoWidePixelCopy2,dw,XF(X4))
CPY(DoWidePixelAv2,dw,AV(X4))
CCP(CDoWidePixelCopy2,dw,XF(X4),16)


