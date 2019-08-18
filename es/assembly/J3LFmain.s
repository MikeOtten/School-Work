;******************************************************************************
;   How to use this file:                                                     *
;   ======================                                                    *
;                                                                             *
;   This file is a basic template for creating Assembly code for a dsPIC30F   *
;   device.  Copy this file into your project directory and modify or         *
;   add to it as needed.                                                      *
;                                                                             *
;   Add the device linker script (e.g., p30f6010.gld) and the device          *
;   include file (e.g. p30f6010.inc). If you are using this file for          *
;   an application that uses a device other than dsPIC 30F6010 which is       *
;   identified in the list of supported devices, add the linker script and    *
;   include file specific to that device into your project.                   *
;                                                                             *
;   If you plan to use initialized data sections in the application and       *
;   would like to use the start-up module in the run-time library to          *
;   initialize the data sections then use the template file in this folder    *
;   named, "tmp6010_srt.s". Refer to the document "dsPIC 30F Assembler,       *
;   Linker and Utilities User's Guide" for further information on the start-up*
;   module in the run-time library.                                           *
;                                                                             *
;   If interrupts are not used, all code presented for that interrupt         *
;   can be removed or commented out using comment symbols (semi-colons).      *
;                                                                             *
;   For additional information about dsPIC 30F  architecture and language     *
;   tools, refer to the following documents:                                  *
;                                                                             *
;   MPLAB C30 Compiler User's Guide                       : DS51284           *
;   dsPIC 30F Assembler, Linker and Utilities User's Guide: DS51317           *
;   dsPIC 30F 16-bit MCU Family Reference Manual          : DS70046           *
;   dsPIC 30F Power and Motion Control Family Data Sheet  : DS70082           *
;   dsPIC 30F Programmer's Reference Manual               : DS70030           *
;                                                                             *
;******************************************************************************
;                                                                             *
;   Author              :  David Otten                                        *
;   Company             :                                                     *
;   Filename            :  Jehu_3.s                                           *
;   Date                :  11/8/2014                                          *
;   File Version        :  0.10                                               *
;   11/21/2015 Came in 31 out of 121 in All Japan Qualifying		      *
;   11/22/2015 Came in 27 out of 39 in All Japan Final			      *
;                                                                             *
;   Other Files Required: p30F6010.gld, p30f6010.inc                          *
;                                                                             *
;   Devices Supported by this file:                                           *
;			    dsPIC 33EPXXXGM3XX/6XX/7XX                        *
;                                                                             *
;******************************************************************************
;    Notes:                                                                   *
;    ======                                                                   *
;                                                                             *
;1. The device include file defines bit names and their location within SFR   *
;   words. Replace the path to the include file, if necessary.                *
;   For e.g., to use the p30f2010 device modify the .include directive to     *
;   .include "Yourpath\p30F2010.inc"                                          *
;                                                                             *
;2. The "config" macro is present in the device specific '.inc' file and can  *
;   be used to set configuration bits for the dsPIC 30F device.               *
;   The '.inc' files also contain examples on using the "config" macro.       *
;   Some examples have been provided in this file. The user application may   *
;   require a different setting for the configuration bits.                   *
;   The dsPIC 30F 16-bit MCU Family Refernce Manual(DS70046) explains the     *
;   function of the configuration bits.                                       *
;                                                                             *
;3. The "__reset" label is the first label in the code section and must be    *
;   declared global. The Stack Pointer (W15) and the Stack Pointer Limit      *
;   register must be initialized to values that are past the run-time heap    *
;   space, so as to avoid corrupting user data. Initializing these registers  *
;   at the "__reset" label ensures that user data is not corrupted            *
;   accidentally. The __SP_init and __SPLIM_init literals are defined by the  *
;   linker. The linker automatically addresses above the run-time heap to     *
;   these symbols. Users can change the __SP_init and __SPLIM_init literals to*
;   suit their application.                                                   *
;                                                                             *
;4. A ".section <section_name>, <attributes>" directive declares a new section*
;   named "<section_name>" with an attribute list that specifies if the       *
;   section is located in Program Space(code), Uninitialized(bss) or          *
;   Initialized Data Space(data). Refer to the document "dsPIC 30F Assembler, *
;   Linker and Utilities User's Guide" for further details.                   *
;                                                                             *
;5. Initialize W registers: Using uninitialized W registers as Effective      *
;   Addresses(pointers) will cause an "Uninitialized W Register Trap" !       *
;                                                                             *
;6. The label "__T1Interrupt" is defined in the device linker script. The     *
;   label defines the starting location in program space of the Timer1        *
;   interrupt service routine (ISR).                                          *
;   Similarly, the linker script defines labels for all ISRs. Notice, that    *
;   the ISR label names are preceded by two underscore characters.            *
;   When users needs to write ISR code, they must use these labels after      *
;   providing them global scope. The linker will then place the ISR address in*
;   the respective interrupt vector table location in program space.          *
;   Context Save/Restore in ISRs can be performed using the double-word PUSH  *
;   instruction,PUSH.D. User can also make use of MOV.D, PUSH and PUSH.S      *
;   instructions. Refer dsPIC 30F 16-bit MCU Family Refernce Manual(DS70046)  *
;   for further details.                                                      *

        .equ __33EP512GM306, 1
        .include "p33EP512GM306.inc"

;==========================================================================
;
;   Configuration Words
;
;   Configuration words exist in Program Space and their locations are
;   defined in the device linker script. They can be set in source code
;   or in the MPLAB IDE. Each configuration word should be specified
;   only once (multiple settings may be combined.)
;
;==========================================================================
;
;  Setting configuration words using macros:
;
;  The following macro named 'config' can be used to set configuration words:
;
;
;  For example, to set CONFIG_REG using the macro above, the following line
;  can be pasted only at the beginning of the assembly source code,
;  immediately below the '.include' directive.
;
;        config __CONFIG_REG, SETTING_A & SETTING_B
;
;  Note that the 'config' macro takes two arguments: the first is the name
;  of a configuration word (in this case, __CONFIG_REG), the second argument
;  is a boolean expression that may include multiple settings.
;  The example above would enable SETTING_A and also SETTING_B.
;
;  A description of all possible settings for each configuration word
;  appears below.
;
;==========================================================================

;----- FICD (0x557f0) --------------------------------------------------
;
;  The following settings are available for FICD:
;
;   ICD Communication Channel Select bits:
;     ICS_NONE             Reserved, do not use
;     ICS_PGD3             Communicate on PGEC3 and PGED3
;     ICS_PGD2             Communicate on PGEC2 and PGED2
;     ICS_PGD1             Communicate on PGEC1 and PGED1
;
;   JTAG Enable bit:
;     JTAGEN_OFF           JTAG is disabled
;     JTAGEN_ON            JTAG is enabled

        config __FICD, ICS_PGD2 & JTAGEN_OFF
                            ;Communicate on PGEC2 and PGED2
                            ;JTAG is disabled

;----- FPOR (0x557f2) --------------------------------------------------
;
;  The following settings are available for FPOR:
;
;   :
;     BOREN_OFF            BOR is disabled
;     BOREN_ON             BOR is enabled
;
;   Alternate I2C1 pins:
;     ALTI2C1_ON           I2C1 mapped to ASDA1/ASCL1 pins
;     ALTI2C1_OFF          I2C1 mapped to SDA1/SCL1 pins
;
;   Alternate I2C2 pins:
;     ALTI2C2_ON           I2C2 mapped to ASDA2/ASCL2 pins
;     ALTI2C2_OFF          I2C2 mapped to SDA2/SCL2 pins
;
;   Watchdog Window Select bits:
;     WDTWIN_WIN75         WDT Window is 75% of WDT period
;     WDTWIN_WIN50         WDT Window is 50% of WDT period
;     WDTWIN_WIN37         WDT Window is 37.5% of WDT period
;     WDTWIN_WIN25         WDT Window is 25% of WDT period

        config __FPOR, BOREN_ON
                            ;BOR is enabled

;----- FWDT (0x557f4) --------------------------------------------------
;
;  The following settings are available for FWDT:
;
;   Watchdog Timer Postscaler bits:
;     WDTPOST_PS1          1:1
;     WDTPOST_PS2          1:2
;     WDTPOST_PS4          1:4
;     WDTPOST_PS8          1:8
;     WDTPOST_PS16         1:16
;     WDTPOST_PS32         1:32
;     WDTPOST_PS64         1:64
;     WDTPOST_PS128        1:128
;     WDTPOST_PS256        1:256
;     WDTPOST_PS512        1:512
;     WDTPOST_PS1024       1:1,024
;     WDTPOST_PS2048       1:2,048
;     WDTPOST_PS4096       1:4,096
;     WDTPOST_PS8192       1:8,192
;     WDTPOST_PS16384      1:16,384
;     WDTPOST_PS32768      1:32,768
;
;   Watchdog Timer Prescaler bit:
;     WDTPRE_PR32          1:32
;     WDTPRE_PR128         1:128
;
;   PLL Lock Enable bit:
;     PLLKEN_OFF           Clock switch will not wait for the PLL lock signal.
;     PLLKEN_ON            Clock switch to PLL source will wait until the PLL lock signal is valid.
;
;   Watchdog Timer Window Enable bit:
;     WINDIS_ON            Watchdog Timer in Window mode
;     WINDIS_OFF           Watchdog Timer in Non-Window mode
;
;   Watchdog Timer Enable bit:
;     FWDTEN_OFF           Watchdog timer enabled/disabled by user software
;     FWDTEN_ON            Watchdog timer always enabled

        config __FWDT, PLLKEN_ON & FWDTEN_OFF
                            ;Clock switch to PLL source will wait until the PLL lock signal is valid
                            ;Watchdog timer enabled/disabled by user software

;----- FOSC (0x557f6) --------------------------------------------------
;
;  The following settings are available for FOSC:
;
;   Primary Oscillator Mode Select bits:
;     POSCMD_EC            EC (External Clock) Mode
;     POSCMD_XT            XT Crystal Oscillator Mode
;     POSCMD_HS            HS Crystal Oscillator Mode
;     POSCMD_NONE          Primary Oscillator disabled
;
;   OSC2 Pin Function bit:
;     OSCIOFNC_ON          OSC2 is general purpose digital I/O pin
;     OSCIOFNC_OFF         OSC2 is clock output
;
;   Peripheral pin select configuration:
;     IOL1WAY_OFF          Allow multiple reconfigurations
;     IOL1WAY_ON           Allow only one reconfiguration
;
;   Clock Switching Mode bits:
;     FCKSM_CSECME         Both Clock switching and Fail-safe Clock Monitor are enabled
;     FCKSM_CSECMD         Clock switching is enabled,Fail-safe Clock Monitor is disabled
;     FCKSM_CSDCMD         Both Clock switching and Fail-safe Clock Monitor are disabled

        config __FOSC, POSCMD_NONE & OSCIOFNC_OFF & IOL1WAY_OFF & FCKSM_CSECME
                            ;Primary Oscillator disabled
                            ;OSC2 is clock output
                            ;Allow multiple reconfigurations
                            ;Both Clock switching and Fail-safe Clock Monitor are enabled

;----- FOSCSEL (0x557f8) --------------------------------------------------
;
;  The following settings are available for FOSCSEL:
;
;   Oscillator Source Selection:
;     FNOSC_FRC            Internal Fast RC (FRC)
;     FNOSC_FRCPLL         Fast RC Oscillator with divide-by-N with PLL module (FRCPLL)
;     FNOSC_PRI            Primary Oscillator (XT, HS, EC)
;     FNOSC_PRIPLL         Primary Oscillator with PLL module (XT + PLL, HS + PLL, EC + PLL)
;     FNOSC_SOSC           Secondary Oscillator (SOSC)
;     FNOSC_LPRC           Low-Power RC Oscillator (LPRC)
;     FNOSC_FRCDIVN        Internal Fast RC (FRC) Oscillator with postscaler
;
;   PWM Lock Enable bit:
;     PWMLOCK_OFF          PWM registers may be written without key sequence
;     PWMLOCK_ON           Certain PWM registers may only be written after key sequence
;
;   Two-speed Oscillator Start-up Enable bit:
;     IESO_OFF             Start up with user-selected oscillator source
;     IESO_ON              Start up device with FRC, then switch to user-selected oscillator source

        config __FOCSEL, FNOSC_FRC & PWMLOCK_ON & IESO_ON
                            ;Internal Fast RC (FRC)
                            ;Certain PWM registers may only be written after key sequence
                            ;Start up device with FRC, then switch to user-selected oscillator source

;----- FGS (0x557fa) --------------------------------------------------
;
;  The following settings are available for FGS:
;
;   General Segment Write-Protect bit:
;     GWRP_ON              General Segment is write protected
;     GWRP_OFF             General Segment may be written
;
;   General Segment Code-Protect bit:
;     GCP_ON               General Segment Code protection Enabled
;     GCP_OFF              General Segment Code protect is Disabled

        config __FGS, GWRP_OFF & GCP_OFF
                            ;General Segment may be written
                            ;General Segment Code protect is Disabled

;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

	.equ LEDR,9         ;bit to turn on red LED (port B)
	.equ LEDG,10        ;bit to turn on green LED (port C)
  	.equ LED,14         ;bit to turn on sensor LEDs (port E)
        .equ CS1,4          ;bit to enable CS for external RAM (port C)
        .equ CS2,8          ;bit to enable CS for (port B)
        .equ CS3,11         ;bit to enable CS for (port C)
        .equ CS4,12         ;bit to enable CS for (port E)

	.equ onecm,566	    ;encoder counts for 1 cm of movement (Jehu)
;	.equ onecm,464	    ;encoder counts for 1 cm of movement (Jehu 3)
	.equ KS1,6342
	.equ KS2,6082
	.equ KS3,25779	    ;51557

;..............................................................................
;Global Declarations:
;..............................................................................

;        .global _wreg_init       ;Provide global scope to _wreg_init routine
                                 ;In order to call this routine from a C file,
                                 ;place "wreg_init" in an "extern" declaration
                                 ;in the C file.

 ;       .global __reset          ;The label for the first line of code.

;        .global __T1Interrupt    ;Declare Timer 1 ISR name global

;..............................................................................
;Constants stored in Program space
;..............................................................................

        .section .myconstbuffer, code
        .palign 2                ;Align next word stored in Program space to an
                                 ;address that is a multiple of 2
ps_coeff:
        .hword   0x0002, 0x0003, 0x0005, 0x000A

;..............................................................................
;Uninitialized variables in X-space in data memory
;..............................................................................

;         .section .xbss, bss, xmemory
;x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.

;..............................................................................
;Uninitialized variables in Y-space in data memory
;..............................................................................

;          .section .ybss, bss, ymemory
;y_input:  .space 2*SAMPLES

;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................

	.section .nbss, bss, near
FLAG0:	.space 2	    ;flag byte 0
        .equ DP1F,0	    ;decimal point 1 flag
	.equ DP2F,1	    ;decimal point 2 flag
	.equ DP3F,2	    ;decimal point 3 flag
	.equ INESF,6	    ;ignore next end signal flag
	.equ LOBATF,8	    ;low battery flag
	.equ LOSIGF,10	    ;low signal flag
	.equ CHGVF,11	    ;changed velocity flag (INIMT)

PSDA:	.space 2	    ;PSD A side signal
PSDB:	.space 2	    ;PSD B side signal
PSDSIG:	.space 2	    ;PSD signal
PSDERR:	.space 2	    ;PSD error
OLDERR:	.space 2	    ;old PSD error
PSDDER:	.space 2	    ;PSD derivative
ENDS1:	.space 2	    ;END1 sensor signal
ENDS2:	.space 2	    ;END2 sensor signal
TRNS1:	.space 2	    ;TRN1 sensor signal
TRNS2:	.space 2	    ;TRN2 sensor signal
BATT:	.space 2	    ;battery voltage
GYRO:	.space 2	    ;turn rate from gyro
GYRO0:	.space 2	    ;gyro zero
ACCX:	.space 2	    ;X-direction accelerometer signal
ACCX0:	.space 2	    ;X accelerometer zero
ACCY:	.space 2	    ;Y-direction accelerometer signal
ACCY0:	.space 2	    ;Y accelerometer zero
LEFENC:	.space 2	    ;left wheel encoder
RITENC:	.space 2	    ;right wheel encoder
LEFSPD:	.space 2	    ;left wheel speed
RITSPD:	.space 2	    ;right wheel speed
FWDSPD:	.space 2	    ;forward speed
ROTSPD:	.space 2	    ;rotational speed
FWDDIS:	.space 4	    ;forward distance
ROTDIS:	.space 4	    ;rotational distance
ESCTR:	.space 2	    ;end signal counter
ETCTR:	.space 2	    ;elapsed time counter
BATCOR:	.space 2	    ;battery voltage correction
RUNCTR:	.space 2	    ;run counter (0 = learn run)

;ACCDIS:	.space 4	    ;acceleration distance
;MAXDIS:	.space 4	    ;maximum velocity distance
;DECDIS:	.space 4	    ;deceleration distance

ROTVEL:	.space 2	    ;rotational velocity
FWDVEL:	.space 2	    ;forward velocity
VELINC:	.space 2	    ;velocity increment
FWDINC:	.space 2	    ;forward increment

FWDERN:	.space 2	    ;drive motor new forward error
FWDERO:	.space 2	    ;drive motor old forward error
FWDOUT:	.space 2	    ;drive motor forward output
;DMLFF:	.space 2	    ;left drive motor feed-forward voltage
;DMRFF:	.space 2	    ;right drive motor feed-forward voltage

;PROVEC:	.space 2	    ;address of current routine
;INIVEL:	.space 2	    ;initial velocity
MAXVEL:	.space 2	    ;maximum velocity
FINVEL:	.space 2	    ;final velocity
ACCEL:	.space 2	    ;acceleration
;DECEL:	.space 2	    ;deceleration
TRNACC:	.space 2	    ;turn acceleration
MAXRA:	.space 2	    ;maximum radial acceleration
RADLIM:	.space 2	    ;radius limit for turn (larger is straight)
RADIUS:	.space 2	    ;radius of turn
SEGINC:	.space 2	    ;segment increment (for simulator - svp)
SEGDIS:	.space 4	    ;segment distance (for simulator - svp)

SUPVOL:	.space 2	    ;supply voltage
FILSIZ:	.space 2	    ;counter for external RAM file size

ANCH3:	.space 2	    ;analog channel 3
ANCH4:	.space 2	    ;analog channel 4
ANCH5:	.space 2	    ;analog channel 5
ANCH6:	.space 2	    ;analog channel 6
ANCH7:	.space 2	    ;analog channel 7
ADCTR:	.space 2	    ;A/D counter

TEMP0:	.space 4	    ;temporary storage 0
TEMP1:	.space 4	    ;temporary storage 1
TEMP2:	.space 4	    ;temporary storage 2
TEMP3:	.space 4	    ;temporary storage 3

PSDSDC:	.space 2	    ;psd debounce counter
TRNSDC:	.space 2	    ;turn sensor debounce counter
ENDSDC:	.space 2	    ;end sensor debounce counter

SAMCTR:	.space 2	    ;sample counter
MOVPTR:	.space 2	    ;move buffer pointer
MOVEND:	.space 2	    ;end of move buffer data

;..............................................................................
;Uninitialized variables in data memory - does not need to be near
;..............................................................................

	.section .fbss, bss
ZERMOV:	.space 28	    ;data for zero move (before first move)
MOVBUF:	.space 250*28	    ;6000	    ;move buffer
ENDBUF:	.space 2	    ;end of buffer

;..............................................................................
;Code Section in Program Memory
;..............................................................................

	.text		    ;Start of Code section
        .global __reset	    ;declare reset name global
__reset:
        MOV #__SP_init, W15 ;initalize the Stack Pointer
        MOV #__SPLIM_init, W0	;initialize the Stack Pointer Limit Register
        MOV W0, SPLIM
        NOP		    ;add NOP to follow SPLIM initialization
        
;dmo:	bra dmo
;******************************************************************************
;Start of initializing program
	;
	;init ports
	;
        mov     #0x0080,W0  ;init LATA
        mov     W0,LATA
        mov     #0x0203,W0  ;configure RA0, RA1, and RA9 as inputs
        mov     W0,TRISA    ;configure all other pins as outputs
        mov     #0x0003,W0  ;init analog pins
        mov     W0,ANSELA
        clr     CNENA       ;clear change notification
        clr     CNPUA       ;disable pull up
        clr     CNPDA       ;disable pull down

        mov     #0x1380,W0  ;init LATB
        mov     W0,LATB
        mov     #0xcc0f,W0  ;configure RB0 - RB3, RB10, RB11, RB14, and RB15 as inputs
        mov     W0,TRISB    ;configure all other pins as outputs
        mov     #0x000f,W0  ;init analog pins
        mov     W0,ANSELB
        clr     CNENB       ;clear change notification
        clr     CNPUB       ;disable pull up
        clr     CNPDB       ;disable pull down

        mov     #0x0d90,W0  ;init LATC
        mov     W0,LATC
        mov     #0x2005,W0  ;configure RC0, RC2, and RC13 as inputs
        mov     W0,TRISC    ;configure all other pins as outputs
        mov     #0x0001,W0  ;init analog pins
        mov     W0,ANSELC
        clr     CNENC       ;clear change notification
        clr     CNPUC       ;disable pull up
        clr     CNPDC       ;disable pull down

        mov     #0x0020,W0  ;init LATD
        mov     W0,LATD
        mov     #0x0040,W0  ;configure RD6 as an input
        mov     W0,TRISD    ;configure all other pins as outputs
        clr     ANSELD      ;set all pins to digital
        clr     CNEND       ;clear change notification
        clr     CNPUD       ;disable pull up
        clr     CNPDD       ;disable pull down

        mov     #0x1000,W0  ;init LATE
        mov     W0,LATE
        clr     TRISE       ;configure PORT E as all outputs
        clr     ANSELE      ;set all pins to digital
        clr     CNENE       ;clear change notification
        clr     CNPUE       ;disable pull up
        clr     CNPDE       ;disable pull down

        mov     #0x0000,W0  ;init LATF
        mov     W0,LATF
        mov     #0x0002,W0  ;configue RF1 as an input
        mov     W0,TRISF    ;configure all other pins as outputs
        clr     CNENF       ;clear change notification
        clr     CNPUF       ;disable pull up
        clr     CNPDF       ;disable pull down

        mov     #0x0100,W0  ;init LATG
        mov     W0,LATG
        mov     #0x0080,W0  ;configure RG7 as an input
        mov     W0,TRISG    ;configure all other pins as outputs
        clr     ANSELG      ;set all pins to digital
        clr     CNENG       ;clear change notification
        clr     CNPUG       ;disable pull up
        clr     CNPDG       ;disable pull down
;dmo:	bra     dmo
	;
	;init clock (Fosc = 29.49 MHz, Fcy = 14.75 MHz, Icc = 46 mA)
	;
;        mov     #0x0000,W0 ;init clock divisor register
			    ;PLL prescaler = input/2
			    ;PLL postscaler = output/2
			    ;DOZE = Fcy/1
;        mov     #0x0040,W0 ;PLL postscaler = output/4
        mov     #0x00c0,W0  ;PLL postscaler = output/8
	mov	W0,CLKDIV

	mov	#62,W0      ;init PLL feedback divisor register
                            ;62 -> 64 = 59 MIPS (good for baud rates)
                            ;63 -> 65 = 60 MIPS
                            ;74 -> 76 = 70 MIPS
 	mov	W0,PLLFBD

	mov	#0x1,W0	    ;place new oscillator seletion in W0
	mov	#OSCCONH,W1 ;OSCCONH (high byte) unlock sequence
	mov	#0x78,W2
	mov	#0x9A,W3
	mov.b	W2,[W1]	    ;write 0x0078
	mov.b	W3,[W1]	    ;write 0x009a
 	mov.b	WREG,OSCCONH	;new oscillator selection

	mov	#OSCCONL,W1 ;OSCCONL (low byte) unlock sequence
	mov	#0x46,W2
	mov	#0x57,W3
	mov.b	W2,[W1]	    ;write 0x0046
	mov.b	W3,[W1]	    ;write 0x0057
	bset	OSCCON,#0   ;request clock switch by setting OSWEN bit

init0:	btsc	OSCCONL,#OSWEN	;wait for clock switch to complete
	bra	init0
	;
	;Init Time 1 Module
	; used to time the sample rate
	;
	mov	#14746,W0   ;init period register (ctr+1)
	mov	W0,PR1	    ;period = 1 msec
	mov	#0x8000,W0  ;init time base register
			    ;timer on
			    ;continue operation in idle mode
			    ;timer gate disabled
			    ;1:1 prescale (14.7456 MHz)
			    ;internal clock
	mov	W0,T1CON
        ;
        ;init PWM Master Time Base
        ;
        mov     #0x0000,W0  ;init PWMx time base control register
        mov     W0,PTCON
        mov     #0x0000,W0  ;init PWMx primary master clock divider select register 2
                            ;divide by 1
        mov     W0,PTCON2
        mov     #0x00ff,W0  ;init PWMx primary master time base period register
                            ;256 counts
        mov     W0,PTPER
        ;
        ;init PWM 1
        ;
        mov     #0xabcd,W10 ;load first unlock key to W10 register
        mov     #0x4321,W11 ;load second unlock key to W11 register
	mov	#0x0000,W0  ;init PWM 1 I/O control register
			    ;GPIO module controls PWMxH pin
			    ;GPIO module controls PWMxL pin
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON1   ;write desired value to IOCON1 register
		;
		;init PWM 2
		;
	mov	#0x0000,W0  ;init PWM 2 control register
			    ;positive dead time actively applied
	mov	W0,PWMCON2

	mov	#0,W0	    ;init PWM 2 duty cycle register
	mov	W0,PDC2

	mov	#0,W0	    ;init PWM 2 phase register
	mov	W0,PHASE2

	mov	#1,W0	    ;init PWMH 2 dead time register
	mov	W0,DTR2

	mov	#1,W0	    ;init PWML 2 dead time register
	mov	W0,ALTDTR2

	mov	#0xe000,W0  ;init PWM 2 I/O control register
			    ;PWM module controls PWMxH pin
			    ;PWM module controls PWMxL pin
			    ;complementary PWM output mode
			    ;overide enable for PWMxH
			    ;overide enable for PWMxL
			    ;overide syncronized to PWM time base
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON2   ;write desired value to IOCON2 register
        ;
        ;init PWM 3
        ;
	mov	#0x0000,W0  ;init PWM 1 I/O control register
			    ;GPIO module controls PWMxH pin
			    ;GPIO module controls PWMxL pin
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON3   ;write desired value to IOCON3 register
	;
	;init PWM 4
	;
	mov	#0x0000,W0  ;init PWM 4 control register
			    ;positive dead time actively applied
	mov	W0,PWMCON4

	mov	#0,W0	    ;init PWM 4 duty cycle register
	mov	W0,PDC4

	mov	#0,W0	    ;init PWM 4 phase register
	mov	W0,PHASE4

	mov	#1,W0	    ;init PWMH 4 dead time register
	mov	W0,DTR4

	mov	#1,W0	    ;init PWML 4 dead time register
	mov	W0,ALTDTR4

	mov	#0xd002,W0  ;init PWM 4 I/O control register
			    ;PWM module controls PWMxH pin
			    ;PWM module controls PWMxL pin
			    ;complementary PWM output mode
			    ;overide enable for PWMxH
			    ;overide enable for PWMxL
                            ;swap PWMxH and PWMxL
			    ;overide syncronized to PWM time base
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON4   ;write desired value to IOCON4 register
	;
	;init PWM 5
	;
	mov	#0x0000,W0  ;init PWM 5 control register
			    ;positive dead time actively applied
	mov	W0,PWMCON5

	mov	#0,W0	    ;init PWM 5 duty cycle register
	mov	W0,PDC5

	mov	#0,W0	    ;init PWM 5 phase register
	mov	W0,PHASE5

	mov	#1,W0	    ;init PWMH 5 dead time register
	mov	W0,DTR5

	mov	#1,W0	    ;init PWML 5 dead time register
	mov	W0,ALTDTR5

	mov	#0xe000,W0  ;init PWM 5 I/O control register
			    ;PWM module controls PWMxH pin
			    ;PWM module controls PWMxL pin
			    ;complementary PWM output mode
			    ;overide enable for PWMxH
			    ;overide enable for PWMxL
			    ;overide syncronized to PWM time base
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON5   ;write desired value to IOCON5 register
	;
	;init PWM 6
	;
	mov	#0x0000,W0  ;init PWM 6 control register
			    ;positive dead time actively applied
	mov	W0,PWMCON6

	mov	#0,W0	    ;init PWM 6 duty cycle register
	mov	W0,PDC6

	mov	#0,W0	    ;init PWM 6 phase register
	mov	W0,PHASE6

	mov	#1,W0	    ;init PWMH 6 dead time register
	mov	W0,DTR6

	mov	#1,W0	    ;init PWML 6 dead time register
	mov	W0,ALTDTR6

	mov	#0xd002,W0  ;init PWM 6 I/O control register
			    ;PWM module controls PWMxH pin
			    ;PWM module controls PWMxL pin
			    ;complementary PWM output mode
			    ;overide enable for PWMxH
			    ;overide enable for PWMxL
                            ;swap PWMxH and PWMxL
			    ;overide syncronized to PWM time base
        mov     W10,PWMKEY  ;write first unlock key to PWMKEY register
        mov     W11,PWMKEY  ;write second unlock key to PWMKEY register
	mov	W0,IOCON6   ;write desired value to IOCON6 register

        clr     W10         ;clear first unlock key
        clr     W11         ;clear second unlock key
	bset	PTCON,#PTEN ;enable PWM module
        ;
        ;init quadrature encoder 1
        ;
        ;connect QEI 1 inputs
        mov     #0x2f2e,W0  ;init peripheral pin select input register 14
                            ;RPI46 -> QEA1
        mov     W0,RPINR14  ;RPI47 -> QEB1
        mov     #0x8000,W0  ;init QEI Control Register
                            ;enable module counters
                            ;index does not affect counter
                            ;external gate disabled
                            ;quadrature encoder mode
        mov     W0,QEI1CON
        mov     #0x5800,W0  ;init QEI I/O Control Register
                            ;input pin digital filter enabled
                            ;1:8 clock divide for digital input filter
        mov     W0,QEI1IOC
        ;
        ;init quadrature encoder 2
        ;
        ;connect QEI 2 inputs
	mov     #0x2a2b,W0  ;init peripheral pin select input register 16
                            ;RP43 -> QEA2
        mov     W0,RPINR16  ;RP42 -> QEB2
        mov     #0x8000,W0  ;init QEI Control Register
                            ;enable module counters
                            ;index does not affect counter
                            ;external gate disabled
                            ;quadrature encoder mode
        mov     W0,QEI2CON
        mov     #0x5800,W0  ;init QEI I/O Control Register
                            ;input pin digital filter enabled
                            ;1:8 clock divide for digital input filter
        mov     W0,QEI2IOC
		;
		;init SPI 1 Module for external nonvolatile RAM
		;
	mov	#0x0000,W0  ;init status and control register
	mov	W0,SPI1STAT
	mov	#0x053f,W0  ;init control register 1
	mov	#0x053b,W0  ;1:2 secondary prescale
                            ;16-bit transmission
                            ;master mode
                            ;SMP = 0 input data is sampled at middle of data output time
                            ;CKE = 1 serial output data changes on transition from idle clock state to active clock state
                            ;CKP = 0 idle state for clock is a low level; active state is a high level
                            ;1:1 secondary prescale
                            ;1:1 primary prescale
	mov	W0,SPI1CON1
	mov	#0x0001,W0  ;init control register 2
                            ;enhanced buffer enabled
	mov	W0,SPI1CON2
	bset	SPI1STAT,#SPIEN	;enable SPI 1 module
        ;
        ;Init SPI 2 Module for
        ;
        ;connect SPI 2 input and output
;        mov     #0x0032,W0  ;init peripheral pin select input register 22
;        mov     W0,RPINR22  ;RPI50 -> SDI2
;        mov     #0x0008,W0  ;init peripheral pin select output register 1
;        mov     W0,RPOR1    ;SDO2 -> RP36
;        mov     #0x0900,W0  ;init peripheral pin select output register 2
;        mov     W0,RPOR2    ;SCK2 -> RP39

;	mov	#0x0000,W0  ;init status and control register
;	mov	W0,SPI2STAT
;	mov	#0x007d,W0  ;init control register 1
                            ;8 bit transmission
                            ;SMP = 0 input data is sampled at middle of data output time
                            ;CKE = 0
                            ;CKP = 1
                            ;master mode
                            ;1:1 secondary prescale
                            ;16:1 primary prescale
;	mov	W0,SPI2CON1
;	mov	#0x0001,W0  ;init control register 2
                            ;enhanced buffer enabled
;	mov	W0,SPI2CON2
;	bset	SPI2STAT,#SPIEN	;enable SPI 2 module
	;
	;Init SPI 3 Module for
	;
        ;connect SIP3 input and output
;	mov     #0x0077,W0  ;init peripheral pin select input register 29
;	mov     W0,RPINR29  ;RPI119 -> SDI3
;	mov     #0x1f00,W0  ;init peripheral pin select output register 10
;	mov     W0,RPOR10   ;SDO3 -> RP118
;	mov     #0x0020,W0  ;init peripheral pin select output register 11
;	mov	W0,RPOR11   ;SCK3 -> RP120

;	clr	SPI3STAT
;	clr     SPI3CON1
;	clr     SPI3CON2
;	bset    SPI3CON1,#MSTEN
;	bset    SPI3CON1,#CKP
;	bset    SPI3CON1,#4
;	bset    SPI3CON1,#3
;	bset    SPI3CON1,#2
;;	bset    SPI3CON1,#1
;	bset    SPI3CON1,#0

;	bclr    IFS5,#SPI3IF	;clear interrupt flag
;	bclr    IEC5,#SPI3IE    ;disable interrupt
;	mov	#0x0000,W0  ;init status and control register
;	mov	W0,SPI3STAT
;	mov	#0x007d,W0  ;init control register 1
                            ;8 bit transmission
                            ;SMP = 0 input data is sampled at middle of data output time
                            ;CKE = 0
                            ;CKP = 1
                            ;master mode
                            ;1:1 secondary prescale
                            ;16:1 primary prescale
;	mov	W0,SPI3CON1
;	mov	#0x0000,W0  ;init control register 2
                            ;enhanced buffer enabled
;	mov	W0,SPI3CON2
;	bset	SPI3STAT,#SPIEN	;enable SPI 3 module
 	;
	;Init UART Module 1 for Serial 1
	;
        ;connect UART 1 input and output
        mov     #0x0046,W0  ;init peripheral pin select input register 18
        mov     W0,RPINR18  ;RP70 -> U1RX
        mov     #0x0001,W0  ;init peripheral pin select output register 8
        mov     W0,RPOR8    ;U1TX -> RP69

	mov	#7,W0	    ;init baud rate register
			    ;7.3728  * 2 = 14.7456 MHz Fcy
			    ;95 = 9600 (+0.00%)
                            ;47 = 19200 (+0.00%)
                            ;23 = 38400 (+0.00%)
                            ;15 = 57600 (+0.00%)
                            ;7 = 115200 (+0.00%)
                            ;3 = 230400 (+0.00%)
                            ;1 = 460800 (+0.00%)
                            ;0 = 921699 (+0.00%)
	mov	W0,U1BRG
	clr	U1STA	    ;init status and control register
	mov	#0x8001,W0  ;init mode register
                            ;16 clocks per bit period
			    ;8-bit data, no parity
			    ;2 stop bits
	mov	W0,U1MODE
        mov     #0x1000,W0  ;init status and control register
                            ;enable receiver
        mov     W0,U1STA
	bset	U1STA,#UTXEN	;enable transmit
	;
	;Init A/D converter 1
	;
	mov	#0x000f,W0  ;init ADC1 control register 1
			    ;ADC 1 module off
			    ;continue operation in idle mode
                            ;10-bit, 4-channel operation
			    ;integer output
			    ;program conversion start
			    ;sample channels simultaneously
			    ;sampling begins immediately after last conversion
	mov	W0,AD1CON1

	mov	#0x0200,W0  ;init ADC1 control register 2
			    ;AVDD, AVSS
                            ;disable offset calibration
			    ;do not scan inputs
			    ;convert CH0, CH1, CH2, and CH3
			    ;interrupt after 1 sample/conversion
			    ;buffer configured as one 16-word buffer
			    ;always use MUX A
	mov	W0,AD1CON2

	mov	#0x0001,W0  ;init ADC1 control register 3
			    ;clock derived from system clock
			    ;auto-sample time = 0 Tad
			    ;A/D conversion clock = 2 Tcy
	mov	W0,AD1CON3

        mov     #0x0000,W0  ;init ADC1 control regester 4
                            ;DMA disabled
        mov     W0,AD1CON4

	mov	#0x0000,W0  ;init ADC1 input channel 1, 2, 3 select register
			    ;MUX B
			    ;	CH1 positive = AN0 = CFA
			    ;	CH2 positive = AN1 = CFB
			    ;	CH3 positive = AN2 = END1
			    ;	CH1, CH2, and CH3 negative input is Vref-
			    ;MUX A
			    ;	CH1 positive = AN0 = CFA
			    ;	CH2 positive = AN1 = CFB
			    ;	CH3 positive = AN2 = END1
			    ;	CH1, CH2, and CH3 negative input is Vref-
	mov	W0,AD1CHS123

        mov     #0x0606,W0  ;init ADC1 input channel 0 select register
                            ;MUX B
                            ;   CH0 negative input is Vref-
                            ;   CH0 positive = AN6 = BATT
                            ;MUX A
                            ;   CH0 negative input is Vref-
                            ;   CH0 positive = AN6 = BATT
        mov     W0,AD1CHS0

	bset	AD1CON1,#ADON	;turn on ADC1
	;
	;Init A/D converter 2
	;
	mov	#0x000f,W0  ;init ADC2 control register 1
			    ;ADC 2 module off
			    ;continue operation in idle mode
			    ;10-bit, 4-channel operation
			    ;integer output
			    ;program conversion start
			    ;sample channels simultaneously
			    ;sampling begins immediately after last conversion
	mov	W0,AD2CON1

	mov	#0x0200,W0  ;init ADC2 control register 2
			    ;AVDD, AVSS
                            ;disable offset calibration
			    ;do not scan inputs
			    ;convert CH0, CH1, CH2, and CH3
			    ;interrupt after 1 sample/conversion
			    ;buffer configured as one 16-word buffer
			    ;always use MUX A
	mov	W0,AD2CON2

	mov	#0x0001,W0  ;init ADC2 control register 3
			    ;clock derived from system clock
			    ;auto-sample time = 0 Tad
			    ;A/D conversion clock = 2 Tcy
	mov	W0,AD2CON3

        mov     #0x0000,W0  ;init ADC2 control regester 4
                            ;DMA disabled
        mov     W0,AD2CON4

	mov	#0x0101,W0  ;init ADC2 input channel 1, 2, 3 select register
			    ;MUX B
			    ;	CH1 positive = AN3 = END2
			    ;	CH2 positive = AN4 = TRN2
			    ;	CH3 positive = AN5 = TRN1
			    ;	CH1, CH2, and CH3 negative input is Vref-
			    ;MUX A
			    ;	CH1 positive = AN3 = END2
			    ;	CH2 positive = AN4 = TRN2
			    ;	CH3 positive = AN5 = TRN1
			    ;	CH1, CH2, and CH3 negative input is Vref-
	mov	W0,AD2CHS123

	mov     #0x0202,W0  ;init ADC2 input channel 0 select register
                            ;MUX B
                            ;   CH0 negative input is Vref-
                            ;   CH0 positive = AN2 = END1
                            ;MUX A
                            ;   CH0 negative input is Vref-
                            ;   CH0 positive = AN2 = END1
        mov     W0,AD2CHS0

	bset	AD2CON1,#ADON	;turn on ADC2
	;
	;Init variables
	;
	mov	#FLAG0,W0   ;clear RAM
	repeat	#200
	clr		[W0++]
	;
	;Init interrupts
	;
;	bclr	IFS0,#U1RXIF	;clear UART 1 receive interrupt flag
;	bset	IEC0,#U1RXIE	;enable UART 1 receive interrupts
	;
	;Sigon Message
	;
	rcall	ver	    ;display firmware version
	rcall	listc	    ;display list of commands
	rcall	crlf
	rcall	blink	    ;the lights should only blink when the uP resets
	bclr	LATB,#LEDR  ;turn on red LED
	bclr	LATC,#LEDG  ;turn on green LED

;dmo9:	btss	IFS0,#T1IF  ;check if Timer 1 timed out
;	bra	dmo9	    ;if no, loop again
;	bclr	IFS0,#T1IF  ;if yes, clear Timer 1 interrupt flag

;	btg	LATB,#LEDR
;	btg	LATC,#LEDG

;	mov     #0xaaaa,W0
;	mov     W0,SPI1BUF
;	mov     W0,SPI2BUF
;	mov     W0,SPI3BUF

;	bra     dmo9

;	btg     LATB,#LEDR
;dmo:	btg	LATB,#LEDR
;	btg	LATC,#LEDG
;	btg	LATE,#LED
;	mov     #4,W0
;dmo0:	clr     W1
;dmo1:	dec     W1,W1
;	bra     NZ,dmo1
;	dec     W0,W0
;	bra     NZ,dmo0
;	bra     dmo

;******************************************************************************
;Dispatch program
	;
	;check RS-232 serial interface
	;
dispat:
;	mov	SI1RP,W0    ;check if any bytes in buffer
;	sub	SI1SP,WREG
;	bra	NZ,dispa0   ;if no, skip down
;	rcall   comand	    ;if yes, get command
;dispa0:
;	bra     dispat

    	btsc	U1STA,#URXDA	;check if character is available
	rcall	comand	    ;if yes, get command
        btsc    U1STA,#OERR ;if no, check for overrun error
        bclr    U1STA,#OERR ;if set, clear it
;	bra	dispat	    ;loop again
;dispa0:
	btss	IFS0,#T1IF  ;check if Timer 1 timed out
	bra	dispat	    ;if no, loop again
	bclr	IFS0,#T1IF  ;if yes, clear Timer 1 interrupt flag
;	btsc	PORTF,#1    ;check if left switch closed (red)
;	bra	run	    ;if yes, skip down
	btsc	PORTC,#13   ;check if right switch closed (green)
	bra	run	    ;if yes, skip down

	bra	dispat		;loop again

;******************************************************************************
;Routine to run line follower

run:	bset	LATB,#LEDR  ;turn off red LED
	bset	LATC,#LEDG  ;turn off green LED
	clr	W1	    ;open write file starting at begining of RAM
	rcall	wrfile
	clr	FILSIZ	    ;init file pointer
	clr	FILSIZ+2
	rcall	second	    ;delay for 1 second
	call	encodr	    ;zero encoders
	clr	FWDINC	    ;init motor control variables
	clr	FWDERN
	clr	FWDERO
	clr	FWDOUT
	clr	SAMCTR	    ;init sample counter
	clr	FWDDIS	    ;init forward distance
	clr	FWDDIS+2
	clr	ROTDIS	    ;init rotational distance
	clr	ROTDIS+2
	mov	#2,W0	    ;init end signal counter
	mov	W0,ESCTR
	mov	#MOVBUF,W0  ;init move buffer pointer
	mov	W0,MOVPTR
	call	getpar	    ;update run parameters
	rcall	updmt	    ;update move table based on run parameters
;	mov	#36*36,W0   ;init turn acceleration (20*20)
;	mov	W0,TRNACC
;	mov	#0x3000,W0
;	mov	W0,ACCEL
	clr	FWDVEL
	clr	VELINC
;	mov	#36,W0
;	mov	W0,MAXVEL
;	clr	ROTVEL
;	bclr	LATE,#1	    ;clear left direction bit
;	bclr	LATE,#3	    ;clear right direction bit
	bset	PTCON,#PTEN ;enable PWM

run0:	btss	IFS0,#T1IF  ;check if Timer 1 timed out
	bra	run0	    ;if no, loop again
	bclr	IFS0,#T1IF  ;if yes, clear Timer 1 interrupt flag
	rcall	psd
	rcall	encodr
	mov	PSDERR,W0
	asr	W0,#2,W0    ;divide signal
	add	PSDDER,WREG ;add derivative 
	add	PSDDER,WREG ;x2
	add	PSDDER,WREG ;x3
	add	PSDDER,WREG ;x4
	add	PSDDER,WREG ;x5 
	add	PSDDER,WREG ;x6
	add	PSDDER,WREG ;x7
	add	PSDDER,WREG ;x8
	mov	W0,ROTVEL
	rcall	profil	    ;update velocity profile
	rcall	updwp	    ;update wheel position
	rcall	dmctrl	    ;control drive motors
	rcall	mtrdrv

	inc	ETCTR	    ;increment elapsed time counter
	inc	SAMCTR	    ;increment sample counter

;	mov	#1150,W0    ;check if psd signal is > 1150 (crossover)
;	subr	PSDSIG,WREG
;	bclr	SR,#Z	    ;transer carry flag to zero flag
;	btsc	SR,#C
;	bset	SR,#Z
;	mov	#PSDSDC,W1  ;debounce psd signal
;	rcall	hyst
;	bra	NC,run1	    ;if old signal, skip down
;	bra	Z,run1	    ;if trailing edge, skip down
;	bset	FLAG0,#INESF	;if leading edge, set ignor signal flags
;	bset	FLAG0,#INTSF
	btsc	FLAG0,#LOSIGF	;check low signal flag
	bra	run6	    ;if set, stop run

	btss	TRNSDC,#2   ;check if turn sensor is on
	bra	run1	    ;if no, skip down
	btss	ENDSDC,#2   ;check if end sensor is on
	bra	run1	    ;if no, skip down
	bset	FLAG0,#INESF	;if both on, set ignor end sensor flag

run1:
;	mov	#0xffc0,W0  ;debounce end sensor signal (>63)
	mov	#0xff80,W0  ;debounce end sensor signal (>127)
	and	ENDS1,WREG
	mov	#ENDSDC,W1
	rcall	hyst
	bra	NC,run3	    ;if old signal, skip down
	bra	NZ,run3	    ;if leading edge, skip down
	btsc	FLAG0,#INESF	;if trailing edge, check if ignor end signal flag is set
	bra	run2	    ;if yes, skip down
	dec	ESCTR	    ;if no, decrement end signal counter
	bra	Z,run6	    ;if zero, stop run
	clr	ETCTR	    ;clear elapsed time counter (start of run)
run2:	bclr	FLAG0,#INESF	;clear ignor end signal flag
run3:
;	mov	#0xffc0,W0  ;debounce turn sensor signal (>63)
	mov	#0xff80,W0  ;debounce turn sensor signal (>127)
	and	TRNS1,WREG
	mov	#TRNSDC,W1
	rcall	hyst
	bra	NC,run5	    ;if old signal, skip down
	bra	Z,run5	    ;if trailing edge, skip down
;	btsc	FLAG0,#INTSF	;if leading edge, check if ignor turn signal flag is set
;	bra	run4	    ;if yes, skip down
	;
	;save data to move table
	;
	call	run14	    ;save data to move
	cp0	RUNCTR	    ;check run counter
	bra	Z,run4	    ;zero, skip down
	mov	MOVPTR,W1   ;if no, get move pointer
	mov	[W1+#10],W0 ;check if next move is straight
	inc	W0,W0
	bra	NZ,run4	    ;if no, skip down
	mov	[W1+#10-28],W0	;if yes, check if last move was a straight
	inc	W0,W0
	bra	Z,run5	    ;if yes,skip down
run4:	clr	SAMCTR	    ;clear sample counter
	clr	FWDDIS	    ;clear forward distance
	clr	FWDDIS+2
	clr	ROTDIS	    ;clear rotational distance
	clr	ROTDIS+2
	;
run5:
;	bra	run0	    ;*****
	cp0	RUNCTR	    ;check run counter
	bra	Z,run0	    ;if search run, skip down
	rcall	store_ram   ;store diagnostic data in RAM
	mov	FILSIZ,W0   ;check if RAM is full
	mov	#0x6000,W1
	cpsgt	W0,W1
	bra	run0	    ;if no, loop again
	;
	;stop run
	;
run6:
	mov	#(50*onecm),W0	;increment final straight by 50 cm
	add	FWDDIS	    ;50 cm = 1/2 of distance between goal posts
	clr	W0
	addc	FWDDIS+2
	rcall	run14	    ;save data to move table
	clr	PDC2	    ;turn off all PWM drives
	clr	PDC4
	clr	PDC5
	clr	PDC6
	rcall	second	    ;delay for 1 second to make sure motors stop
	bclr	PTCON,#PTEN ;disable PWM
	clr	FWDVEL	    ;clear forward velocity
	clr	ROTVEL	    ;clear rotational velocity
	bset	LATC,#CS1   ;turn off CS
	bclr	LATB,#LEDR  ;turn on red LED
;	bclr	LATC,#LEDG  ;turn on green LED

run7:	btss	PORTF,#1    ;check if left switch closed (red)
	bra	run7	    ;if no, check again

	rcall	ver	    ;if yes, display software version
	rcall	crlf	    ;display run counter
	mov	RUNCTR,W0
	rcall	byteo
	rcall	comma	    ;straight acceleration
	mov	ACCEL,W0
	swap	W0
	rcall	byteo
	rcall	comma	    ;turn acceleration^2
	mov	TRNACC,W0
	rcall	wordo
	rcall	comma	    ;begining of move buffer
	mov 	#MOVBUF,W0
	rcall	wordo
	rcall	comma	    ;end of move pointer
	mov	MOVEND,W0
	rcall	wordo
	rcall	comma	    ;elapsed time counter
	mov	ETCTR,W0
	rcall	wordo

	mov	RUNCTR,W0   ;store elapsed time in EEPROM
	mul.uu	W0,#8,W2    ;multiply run counter by 8
	mov	#0xf00e,W1  ;add to start address of parameters
	add	W1,W2,W1
	mov	ETCTR,W2
	rcall	eewr	    ;save elapsed time in EEPROM
		
	call	crlf	    ;display sensor zero
	mov	GYRO0,W0
	call	wordo
	rcall	comma
	mov	ACCX0,W0
	call	wordo
	rcall	comma
	mov	ACCY0,W0
	call	wordo

;	inc	RUNCTR
;	call	getpar	    ;update run parameters
;	rcall	updmt	    ;update move table based on run parameters
;	dec	RUNCTR

	rcall	dump_mov_tbl	;display move table

	rcall	dump_ram    ;display RAM file data

	btss	FLAG0,#LOSIGF	;check low signal flag
	inc	RUNCTR	    ;if cleared, increment run counter
	bclr	LATC,#LEDG  ;turn on green LED
	bra	dispat	    ;return to dispat routine
	;
	;save data to move table
	;
run14:	cp0	RUNCTR	    ;check run counter
	bra	Z,run15	    ;zero, skip down
	mov	#28,W0	    ;if no, increment move table pointer
	add	MOVPTR
	return
	;
run15:	mov	MOVPTR,W1   ;get move buffer pointer
	mov	SAMCTR,W0   ;store sample counter
	mov	W0,[W1++]
	mov	FWDDIS,W0   ;store forward distance
	mov	W0,[W1++]
	mov	FWDDIS+2,W0
	mov	W0,[W1++]
	mov	ROTDIS,W0   ;store rotational distance
	mov	W0,[W1++]
	mov	ROTDIS+2,W0
	mov	W0,[W1++]
	clr	W0	    ;clear turn radius
	mov	W0,[W1++]
	mov	W0,[W1++]   ;clear max velocity
	mov	W0,[W1++]   ;clear initial velocity
	mov	W0,[W1++]   ;clear acceleration distance
	mov	W0,[W1++]
	mov	W0,[W1++]   ;clear maximum velocity distance
	mov	W0,[W1++]
	mov	W0,[W1++]   ;clear deceleration distance
	mov	W0,[W1++]
	mov	W1,MOVPTR   ;save pointer
	mov	W1,MOVEND   ;save current end of move data
	return

;******************************************************************************
;Routine to update move table
	;
	;on the first pass, calculate the turn radius, identify turns and
	;straights (based on radius), and calculate initial velocity for turns
	;
updmt:	cp0	RUNCTR	    ;check run counter
	btsc	SR,#Z	    ;if not zero, skip down
	return		    ;if zero, return
	;
	mov	#MOVBUF,W12 ;get move pointer
	mov	MOVEND,W13  ;get final pointer
updmt0:	mov	[W12+#2],W2 ;get FWDDIS
	mov	[W12+#4],W3 ;calculate turn radius (256*FWDDIS/ROTDIS)

	lsr	W2,#8,W0    ;multiply W3:W2 by 256
	sl	W2,#8,W2
	sl	W3,#8,W3
	add	W0,W3,W3

	mov	[W12+#6],W4 ;get ROTDIS
	mov	[W12+#8],W5
	btsc	W5,#15	    ;take absolute value of ROTDIS
	neg	W4,W4
	cp0	W4	    ;check if denominator is zero
	bra	Z,updmt1    ;if yes,skip down
	repeat	#17	    ;if no, calculate radius
	div.ud	W2,W4
	bra	OV,updmt1   ;if overflow, skip down
	mov	RADLIM,W1   ;if no, check if greater than 5000
	sub	W0,W1,W1    ;5510 = 100 cm radius
	bra	C,updmt1    ;if yes, skip down
	;
	;move is a turn
	;
	mov	W0,[W12+#10]	;save radius
	rcall	turn_velocity	;calculate turn velocity based on radius
	mov	W0,[W12+#12]	;save as initial velocity
	mov	W0,[W12+#14]	;save as maximum velocity also
	clr	W0	    ;init acceleration distance
	mov	W0,[W12+#16]
	mov	W0,[W12+#18]
	mov	W0,[W12+#20]	;init maximum velocity distance
	mov	W0,[W12+#22]
	mov	W0,[W12+#24]	;init deceleration distance
	mov	W0,[W12+#26]
	bra	updmt2	    ;skip down
	;
	;move is a straight
	;
updmt1:	mov	#0xffff,W0  ;set radius to large (straight)
	mov	W0,[W12+#10]	;save radius
	mov	MAXVEL,W0   ;set maximum velocity
	mov	W0,[W12+#14]
updmt2:	add	#28,W12	    ;increment pointer to next table entry
	cp	W12,W13	    ;check if finished
	bra	NZ,updmt0   ;if no, loop for all data

;	mov	#551,W0	    ;****** set next move to 10 cm turn
;	mov	W0,[W12+#10]
;	mov	#36,W0	    ;****** set initial velocity to 36
;	mov	W0,[W12+#12]
;	mov	W0,[W12+#14]	;****** set maximum velocity to 36

	mov	#0xffff,W0  ;set next move to straight
	mov	W0,[W12+#10]
	clr	W0	    ;set initial velocity to 0
	mov	W0,[W12+#12]
	mov	W0,[W12+#14]	;set maximum velocity to 0
	
	mov	#1,W0	    ;*****
	rcall	byteo	    ;*****
	rcall	comma	    ;*****
	;
	;On the next pass, check for contiguous turns and copy the
	;maximum velocity of the current turn into the initial velocity
	;of a subsequent turn if the maximum velocity of the current
	;turn is less than the maximum velocity of the subseqent turn.
	;Also copy the maximum velocity of the current turn into the
	;initial velocity of a subsequent straight.
	;
	mov	#MOVBUF,W12 ;get move pointer
updmt3:	mov	[W12+#10],W0	;get turn radius
	inc	W0,W0	    ;check if straight
	bra	Z,updmt5    ;if yes, skip down

	mov	[W12+#14],W1	;get maximum velocity of current turn
	mov	[W12+#10+28],W0	;get turn radius of next segment
	inc	W0,W0	    ;check if straight
	bra	Z,updmt4    ;if yes, skip down

	mov	[W12+#14+28],W0	;if no, get maximum velocity of next turn
	cpslt	W0,W1	    ;check if next turn velocity is less
updmt4:	mov	W1,[W12+#12+28]	;if yes, save as initial velocity for next segment

updmt5:	add	#28,W12	    ;increment pointer to next table entry
	cp	W12,W13	    ;check if finished
	bra	NZ,updmt3   ;if no, loop for all data

	mov	#2,W0	    ;*****
	rcall	byteo	    ;*****
	rcall	comma	    ;*****
	;
	;on the next pass, check if the distance of each segment is large enough to
	;allow the expected velocity change.  If no, reduce velocity change to 
	;accommodate available distance
	;
updm10:	bclr	FLAG0,#CHGVF	;clear change velocity flag
	mov	#MOVBUF,W12 ;get move pointer
updm11:	mov	[W12+#10],W0	;get turn radius
	inc	W0,W0	    ;check if straight
	bra	Z,updm13    ;if yes, skip down
	;
	;check turn
	;
	mov	[W12+#12],W7	;W7 = Vini
	mov	[W12+#12+28],W8	;W8 = Vfin
	mov	[W12+#10],W9	;W9 = radius
	
	rcall	comma		;*****
	mov	W7,W0		;*****
	rcall	binasc		;*****
	rcall	comma		;*****
	mov	W8,W0		;*****
	rcall	binasc		;*****
	rcall	comma		;*****
	mov	W9,W0		;*****
	rcall	binasc		;*****
	
	cp	W7,W8	    ;compare initial and final velocity
	bra	Z,updm19    ;if equal, skip down
	bra	C,updm12    ;if Vini > Vfin, skip down

	call	trnddv	    ;calculate distance required to change velocity for next turn
	mov	[W12+#2],W8 ;get forward distance
	mov	[W12+#4],W1
	mov	#(5*onecm),W0	;subtract 5 cm for margin
	sub	W8,W0,W8
	clr	W0
	subb	W1,W0,W1
	cpseq	W0,W1	    ;check if W1:W8 > 2^16-1
	setm	W8	    ;if yes, set W8 = 2^16-1
	cp	W8,W10	    ;compare to FWDDIS
	bra	GTU,updm19  ;if required distance is less, skip down
	mov	[W12+#12],W7	;W7 = Vini
	call	dvtrnd	    ;W8 = distance
	mov	W7,[W12+#12+28]	;update Vfin
	bset	FLAG0,#CHGVF	;set change velocity flag
	bra	updm19	    ;skip down
	;
updm12:	exch	W7,W8	    ;exchange Vini and Vfin
	call	trnddv	    ;calculate distance required to change velocity for next turn
	mov	[W12+#2],W8 ;get forward distance
	mov	[W12+#4],W1
	mov	#(5*onecm),W0	;subtract 5 cm for margin
	sub	W8,W0,W8
	clr	W0
	subb	W1,W0,W1
	cpseq	W0,W1	    ;check if W1:W8 > 2^16-1
	setm	W8	    ;if yes, set W8 = 2^16-1
	cp	W8,W10	    ;compare to FWDDIS
	bra	GTU,updm19  ;if required distance is less, skip down
	mov	[W12+#12+28],W7	;W7 = Vini
	call	dvtrnd	    ;W8 = distance
	mov	W7,[W12+#12]	;update Vfin
	bset	FLAG0,#CHGVF	;set change velocity flag
	bra	updm19	    ;skip down
	;
	;check straight
	;
updm13:	mov	W12,W11	    ;save pointer to initial segment
	clr	W6	    ;init forward distance
	clr	W7
updm14:	mov	[W12+#2],W0 ;get forward distance
	add	W6,W0,W6    ;add to total
	mov	[W12+#4],W0
	addc	W7,W0,W7
	mov	[W12+#10+28],W0	;get turn radius of next move
	inc	W0,W0	    ;check if straight
	bra	NZ,updm15   ;if no, skip down
	add	#28,W12	    ;if yes, increment pointer
	cp	W12,W13	    ;check if this is the last move
	bra	NZ,updm14   ;if no, loop for next straight
	sub	#28,W12	    ;if yes, decrease pointer

updm15:	mov	#(5*onecm),W0	;subtract 5 cm for margin
	sub	W6,W0,W6
	clr	W0
	subb	W7,W0,W7
	cpseq	W0,W7	    ;check if W7:W6 > 2^16-1
	setm	W6	    ;if yes, set W6 = 2^16-1
	mov	[W11+#12],W0	;W0 = Vini
	mov	[W12+#12+28],W1	;W1 = Vfin
	cp	W0,W1	    ;compare initial and final velocity
	bra	Z,updm19    ;if equal, skip down
	bra	C,updm16    ;if Vini > Vfin, skip down
	call	strddv	    ;calculate distance required to change velocity for next turn
	cp	W6,W0	    ;compare to FWDDIS
	bra	GTU,updm19  ;if required distance is less, skip down
	mov	W6,W0	    ;W0 = distance
	mov	[W11+#12],W1	;W1 = Vini
	call	dvstrd
	mov	W0,[W12+#12+28]	;update Vfin
	bset	FLAG0,#CHGVF	;set change velocity flag
	bra	updm19	    ;skip down
	;
updm16:	exch	W0,W1	    ;exchange Vini and Vfin
	call	strddv	    ;calculate distance required to change velocity for next turn
	cp	W6,W0	    ;compare to FWDDIS
	bra	GTU,updm19  ;if required distance is less, skip down
	mov	W6,W0	    ;W0 = distance
	mov	[W12+#12+28],W1	;W1 = Vini
	call	dvstrd
	mov	W0,[W11+#12]	;update Vini
	bset	FLAG0,#CHGVF	;set change velocity flag

updm19:
	rcall	crlf	    ;***** print out index of segment just finished
	mov	W12,W0	    ;*****
	rcall	binasc	    ;*****
	
	add	#28,W12	    ;increment pointer to next table entry
	cp	W12,W13	    ;check if finished
	bra	NZ,updm11   ;if no, loop for all data
	btsc	FLAG0,#CHGVF	;if yes, check if change velocity flag set
	bra	updm10	    ;if yes, loop again
	
			    ;***** this may be where I want to implement a
			    ;***** counter and keep track of how many times
			    ;***** I go around the loop
			    ;***** I took out this check but the program still hangs
			    ;***** I am using the 2015_japan_test with 40,28,200
			    ;***** It also fails with 42,28,200

	mov	#3,W0	    ;*****
	rcall	byteo	    ;*****
	rcall	comma	    ;*****
	;
	;on the next pass, calculate the acceleration profile for turns
	;
	mov	#MOVBUF,W12 ;get move pointer
updm40:	mov	[W12+#10],W0	;get turn radius
	inc	W0,W0		;check if straight
	bra	Z,updm45	;if yes, skip down
	mov	[W12+#12],W7	;W7 = Vini
	mov	[W12+#12+28],W8	;W8 = Vfin
	mov	[W12+#10],W9	;W9 = radius
	call	trnddv	    ;calculate distance required to change velocity for next turn
	push.d	W10	    ;save result
	mov	[W12+#12],W7	;W7 = Vini
	mov	[W12+#14],W8	;W8 = MAXVEL
	call	trnddv	    ;calculate distance to get to max velocity
	pop.d	W0	    ;restore previous result
	mov	[W12+#2],W2 ;get FWDDIS
	mov	[W12+#4],W3
	mov	#(5*onecm),W4	;subtract 5 cm for margin
	sub	W2,W4,W2
	clr	W4
	subb	W3,W4,W3
	bra	C,updm41    ;if positive, skip down
	clr	W2	    ;if negative, set distance to 0
	clr	W3
updm41:	add	W0,W2,W4    ;add acceleration distance to FWDDIS
	addc	W1,W3,W5
	asr	W5,W5	    ;divide sum by 2
	rrc	W4,W4
	mov	W4,W6	    ;init maximum velocity distance
	mov	W5,W7
	sub	W4,W10,W0   ;check if maximum velocity distance < acceleration distance
	subb	W5,W11,W1
	bra	NC,updm42   ;if no, skip down
	mov	W10,W4	    ;update accleration distance
	mov	W11,W5
	add	W6,W0,W6    ;update maximum distance
	addc	W7,W1,W7
updm42:	mov	W4,[W12+#16]	;save acceleration distance
	mov	W5,[W12+#18]
	mov	W6,[W12+#20]	;save maximum distance
	mov	W7,[W12+#22]
	mov	W2,[W12+#24]	;save deceleration distance
	mov	W3,[W12+#26]
updm45:	add	#28,W12	    ;increment pointer to next table entry
	cp	W12,W13	    ;check if finished
	bra	NZ,updm40   ;if no, loop for all data

	mov	#4,W0	    ;*****
	rcall	byteo	    ;*****
	rcall	comma	    ;*****
		;
	;on the next pass, calculate the acceleration profile for straights
	;if there are multiple straights in a row, calculate the acceleration 
	;profile for the combined straight
	;
	mov	#MOVBUF,W12 ;get move pointer
updm30:	mov	[W12+#10],W0	;get turn radius
	inc	W0,W0	    ;check if straight
	bra	NZ,updm33   ;if no, skip down

	mov	[W12+#12],W10	;if yes, save initial velocity in W10
	mov	W10,W0	    ;W0 = Vini
	mov	[W12+#14],W1	;W1 = MAXVEL
	call	strddv	    ;calculate distance to get to max velocity
	mov	W0,W8	    ;save in W9:W8
	mov	W1,W9

	push	W12	    ;save pointer
	clr	W6	    ;init forward distance
	clr	W7
	clr	W11	    ;init counter

updm31:	mov	[W12+#2],W0 ;get forward distance
	add	W0,W6,W6    ;add to total
	mov	[W12+#4],W0
	addc	W0,W7,W7
	inc	W11,W11	    ;increment counter
	add	#28,W12	    ;increment pointer

	cp	W12,W13	    ;check if this is the last move
	bra	Z,updm36    ;if yes, skip down

	mov	[W12+#10],W0	;if no, get turn radius of next move
	inc	W0,W0	    ;check if straight
	bra	Z,updm31    ;if yes, loop for next straight

updm36:	mov	W10,W0	    ;W0 = Vini
	mov	[W12+#12],W1	;W1 = Vfin
	call	strddv	    ;calculate distance required to change velocity for next turn

;	mov	[W12+#2],W2 ;get FWDDIS
;	mov	[W12+#4],W3
	mov	#(5*onecm),W4	;subtract 5 cm for margin
	sub	W6,W4,W2
	clr	W4
	subb	W7,W4,W3
	bra	C,updm34    ;if positive, skip down
	clr	W2	    ;if negative, set distance to 0
	clr	W3
updm34:	add	W0,W2,W4    ;add acceleration distance to FWDDIS
	addc	W1,W3,W5
	asr	W5,W5	    ;divide sum by 2
	rrc	W4,W4
	mov	W4,W6	    ;init maximum velocity distance
	mov	W5,W7
	sub	W4,W8,W0    ;check if maximum velocity distance < acceleration distance
	subb	W5,W9,W1
	bra	NC,updm35   ;if no, skip down
	mov	W8,W4	    ;update accleration distance
	mov	W9,W5
	add	W6,W0,W6    ;update maximum disance
	addc	W7,W1,W7
updm35:	pop	W12	    ;get pointer

updm32:	mov	W4,[W12+#16]	;save acceleration distance
	mov	W5,[W12+#18]
	mov	W6,[W12+#20]	;save maximum distance
	mov	W7,[W12+#22]
	mov	W2,[W12+#24]	;save deceleration distance
	mov	W3,[W12+#26]

	dec	W11,W11	    ;decrement counter
	bra	Z,updm33    ;if zero, skip down

	bra	updm39	    ;*****
	mov	[W12+#2],W0 ;if no, get forward distance for this segment
	mov	[W12+#4],W1
	sub	W4,W0,W4    ;subtract from acceleration distance
	subb	W5,W1,W5
	bra	C,updm37    ;if positive, skip down
	clr	W4	    ;if negative, set to zero
	clr	W5
updm37:	sub	W6,W0,W6    ;subtract from maximum velocity distance
	subb	W7,W1,W7
	bra	C,updm38    ;if positive, skip down
	clr	W6	    ;if negative, set to zero
	clr	W7
updm38:	sub	W2,W0,W2    ;subtract from deceleration distance
	subb	W3,W1,W3
	bra	C,updm39    ;if positive, skip down
	clr	W2	    ;if negative, set to zero
	clr	W3
updm39:	add	#28,W12	    ;increment pointer
	bra	updm32
		;		
updm33:	add	#28,W12	    ;increment pointer to next table entry
	cp	W12,W13	    ;check if finished
	bra	NZ,updm30   ;if no, loop for all data
	return

;******************************************************************************
;Routine to calculate distance in a straight to change velocity
; distance = (Vfin^2 - Vini^2) / (2 * FWDACC)
; W0 = Vini
; W1 = Vfin
; W1:W0 = distance
; uses W2,W3,W4, and W5

strddv:	cpsgt	W0,W1	    ;check if Vini < Vfin
	bra	strdd0	    ;if yes, skip down
	exch	W0,W1	    ;if no, exchange Vfin and Vini
	rcall	strdd0	    ;calculate distance
	neg	W0,W0	    ;take negative of result
	setm	W1
	return

strdd0:	mul.uu	W0,W0,W2    ;W3:W2 = Vini^2
	mul.uu	W1,W1,W4    ;W5:W4 = Vfin^2
	sub	W4,W2,W2    ;W3:W2 = W5:W4 - W3:W2
	subb	W5,W3,W3
	lsr	W2,#8,W0    ;multiply W3:W2 by 256
	sl	W2,#8,W2
	sl	W3,#8,W3
	add	W0,W3,W3
	mov	ACCEL,W4
	lsr	W4,#7,W5
	repeat	#17
	div.ud	W2,W5
	bra	NOV,strdd1  ;check for overflow
	mov	#0xffff,W0  ;if yes, saturate result
strdd1:	clr	W1
	return

;******************************************************************************
;Routine to calculate change in velocity based on distance in a straight
; Vfin = sqrt(Vini^2 + (2 * FWDACC * distance))
; W0 = distance
; W1 = Vini
; W0 = Vfin
; uses W2,W3,W4, and W5

dvstrd:	mul.uu	W1,W1,W2    ;W3:W2 = Vini^2
	mov	ACCEL,W1
	lsr	W1,#7,W1
	mul.uu	W0,W1,W4    ;W5:W4 = FWDACC * distance
	lsr	W4,#8,W0    ;divide W5:W4 by 256
	sl	W5,#8,W1
	add	W0,W1,W0
	asr	W5,#8,W1
	add	W0,W2,W0    ;add Vini^2
	addc	W1,W3,W1
	bra	sqrt	    ;take square root

;******************************************************************************
;Routine to calculate distance in a turn to change velocity
; W7 = Vini
; W8 = Vfin
; W9 = turn radius
; uses W0,W1,W2,W3,W4,W5, and W6
; W11:W10 = distance

trnddv:	clr	W6	    ;clear velocity increment
	clr	W10	    ;clear distance increment
	clr	W11	    ;clear forward distance
	cpsne	W7,W8	    ;check if Vfin = Vini
	return		    ;if yes, return
	cpsgt	W7,W8	    ;check if Vini < Vfin
	bra	trndd0	    ;if yes, skip down
	exch	W7,W8	    ;if no, exchange Vfin and Vini
	rcall	trndd0	    ;calculate distance
	neg	W10,W10	    ;take negative of result
	setm	W11
	return
	;
trndd0:	mul.uu	W7,W7,W2    ;calculate radial acceleration
	mov	#6375,W0    ;W3:W2 = velocity^2
	mul.uu	W0,W2,W4    ;W5:W4 = 24.90358 * 256 * velocity^2
	repeat	#17	    ;W0 = 6375 * velocity^2 / radius (W9)
	div.ud	W4,W9
	mov	#128,W1	    ;round result
	add	W0,W1,W0
	lsr	W0,#8,W0    ;divide by 256
	mul.uu	W0,W0,W2    ;calculate straight acceleration
	mov	MAXRA,W1    ;STRACC = sqrt(MAXRA^2 - RADACC^2)
	mul.uu	W1,W1,W4
	sub	W4,W2,W0
	clr	W1
	rcall	sqrt
	sl	W0,#8,W0    ;shift acceleration up 8 bits
	add	W6,W0,W6    ;increment velocity (W7:W6)
	clr	W0
	addc	W7,W0,W7
	add	W6,W10,W10  ;increment distance (W11:W10)
	addc	W7,W11,W11
	cpsgt	W8,W7	    ;check if final velocity reached
	bra	trndd1	    ;if yes, skip down
	bra	trndd0	    ;if no, loop again
	;
trndd1:	mov	W11,W10	    ;move result to W11:W10
	clr	W11	    ;clear high word of distance
	return

;******************************************************************************
;Routine to calculate change in velocity based on distance in a turn
; W7 = Vini
; W8 = distance
; W9 = turn radius
; uses W0,W1,W2,W3,W4,W5, and W6
; W7 = Vfin

dvtrnd:	clr	W6	    ;clear velocity increment
	clr	W10	    ;clear distance increment
	clr	W11	    ;clear forward distance
dvtrn0:	mul.uu	W7,W7,W2    ;calculate radial acceleration
	mov	#6375,W0    ;W3:W2 = velocity^2
	mul.uu	W0,W2,W4    ;W5:W4 = 24.90358 * 256 * velocity^2
	repeat	#17	    ;W0 = 6375 * velocity^2 / radius (W9)
	div.ud	W4,W9
	mov	#128,W1	    ;round result
	add	W0,W1,W0
	lsr	W0,#8,W0    ;divide by 256
	mul.uu	W0,W0,W2    ;calculate straight acceleration
	mov	MAXRA,W1    ;STRACC = sqrt(MAXRA^2 - RADACC^2)
	mul.uu	W1,W1,W4
	sub	W4,W2,W0
	clr	W1
	rcall	sqrt
	sl	W0,#8,W0    ;shift acceleration up 8 bits
	add	W6,W0,W6    ;increment velocity (W7:W6)
	clr	W1
	addc	W7,W1,W7
	add	W10,W6,W10  ;increment distance (W11:W10)
	addc	W11,W7,W11
	cp	W8,W11	    ;check if distance reached
	bra	GTU,dvtrn0  ;if no, loop again
	sub	W6,W0,W6    ;if yes, subtract last addition to velocity
	subb	W7,W1,W7
	return

;******************************************************************************
;Routine to calculate distance in a turn to increase velocity
; if distance = maximum, FWDVEL is maximum available velocity increase
; MAXRA = maximum radial acceleration
; RADIUS = radius of turn
; FWDVEL = initial velocity
; MAXVEL = maximum velocity
; W11 = maximum distance
; W9 = calculated distance

trn_accel_dist:
	clr	W8	    ;clear distance increment
	clr	W9	    ;clear forward distance
tad0:	rcall	trn_accel
	mov	VELINC,W0
	add	W0,W8,W8
	mov	FWDVEL,W1
	addc	W1,W9,W9
	mov	MAXVEL,W0
	cpsgt	W0,W1
	return
	cpsgt	W9,W11
	bra	tad0
	return
		
;******************************************************************************
;Routine to calculate distance in a turn to decrease velocity
; if distance = maximum, FWDVEL is maximum available velocity decrease
; MAXRA = maximum radial acceleration
; RADIUS = radius of turn
; FWDVEL = initial velocity
; FINVEL = final velocity
; W11 = maximum distance
; W9 = calculated distance

trn_decel_dist:
	dec	FWDVEL
	setm	VELINC
	clr	W8	    ;clear distance increment
	clr	W9	    ;clear forward distance
tdd0:	rcall	trn_decel
	mov	VELINC,W0
	add	W0,W8,W8
	mov	FWDVEL,W1
	addc	W1,W9,W9
	mov	FINVEL,W0
	dec	W0,W0
	cpslt	W0,W1
	return
	cpsgt	W9,W11
	bra	tdd0
	return

;******************************************************************************
;Routine to increase velocity by available straight acceleration
; MAXRA = maximum radial acceleration
; RADIUS = radius of turn
; MAXVEL = maximum velocity

trn_accel:
	rcall	avail_str_accel
	add	VELINC
	clr	W0
	addc	FWDVEL
;	mov	MAXVEL,W0
;	sub	FWDVEL,WREG
;	bra		
	return

;******************************************************************************
;Routine to decrease velocity by available straight acceleration
; MAXRA = maximum radial acceleration
; RADIUS = radius of turn
; FINVEL = final velocity

trn_decel:
	rcall	avail_str_accel
	sub	VELINC
	clr	W0
	subb	FWDVEL
;	mov	FINVEL,W0
;	sub	FWDVEL,WREG
;	bra
	return

;******************************************************************************
;Routine to calculate available straight acceleration based on current velocity and turn radius
; STRACC = sqrt(MAXRA^2 - RADACC^2)
; MAXRA = maximum radial acceleration
; FWDVEL = velocity
; RADIUS = radius
; W0 = result

avail_str_accel:
	rcall	radial_accel	;calculate radial acceleration
	mul.uu	W0,W0,W2    ;calculate STRACC
	mov	MAXRA,W1    ;STRACC = sqrt(MAXRA^2 - RADACC^2)
	mul.uu	W1,W1,W4
	sub	W4,W2,W0
	clr	W1
	rcall	sqrt
	sl	W0,#8,W0    ;shift acceleration up 8 bits
	return

;******************************************************************************
;Routine to calculate radial acceleration based on current velocity and turn radius
; acceleration(pulses/int^2) = 24.90358 * velocity(pulses/int)^2/radius(Jehu unit)
; FWDVEL = velocity
; RADIUS = radius
; W0 = result

radial_accel:
	mov	FWDVEL,W0   ;get velocity
	mul.uu	W0,W0,W2    ;W3:W2 = velocity^2
	mov	#6375,W0    ;W5:W4 = 24.90358 * 256 * velocity^2
	mul.uu	W0,W2,W4
	mov	RADIUS,W2   ;get radius
	repeat	#17	    ;W0 = 6375 * velocity^2 / radius
	div.ud	W4,W2
	mov	#128,W1	    ;round result
	add	W0,W1,W0
	lsr	W0,#8,W0    ;divide by 256
	return

; W7 = velocity
; W9 = turn radius
; W0 = result

;radial_accel:
	mul.uu	W7,W7,W2    ;calculate radial acceleration
	mov	#6375,W0    ;W3:W2 = velocity^2
	mul.uu	W0,W2,W4    ;W5:W4 = 24.90358 * 256 * velocity^2
	repeat	#17	    ;W0 = 6375 * velocity^2 / radius (W9)
	div.ud	W4,W9
	mov	#128,W1	    ;round result
	add	W0,W1,W0
	lsr	W0,#8,W0    ;divide by 256

	mul.uu	W0,W0,W2    ;calculate straight acceleration
	mov	MAXRA,W1    ;STRACC = sqrt(MAXRA^2 - RADACC^2)
	mul.uu	W1,W1,W4
	sub	W4,W2,W0
	clr	W1
	rcall	sqrt
	sl	W0,#8,W0    ;shift acceleration up 8 bits

;******************************************************************************
;Routine to calculate maximum turn velocity based on radius
; turn_velocity = sqrt(trnacc * radius / 551)
; TRNACC = turn velocity^2 for 10 cm radius turn
; W0 = radius
; W0 = result

turn_velocity:
	mov	TRNACC,W1
	mul.uu	W0,W1,W2
	mov	#551,W4
	repeat	#17
	div.ud	W2,W4
	clr	W1
	bra	sqrt

;******************************************************************************
;Routine to calculate square root
; W0,W1 = number
; W0 = result

sqrt:	push.d	W2	    ;save registers
	push.d	W4
	clr	W2	    ;clear result
	mov	#0x8000,W3  ;init mask
sqrt0:	add	W2,W3,W2    ;add mask to result
	mul.uu	W2,W2,W4    ;square result
	sub	W0,W4,W4    ;compare to number
	subb	W1,W5,W5
	btss	SR,#C	    ;if less or equal, skip down
	sub	W2,W3,W2    ;if greater, subtract mask
	lsr	W3,W3	    ;shift mask down 1 bit
	bra	NZ,sqrt0    ;loop for all mask bits
	mov	W2,W0	    ;move result to W0
	pop.d	W4	    ;restore registers
	pop.d	W2
	return

;******************************************************************************
;Routine to store data in RAM file

store_ram:
	mov	#0x003f,W0  ;mask bottom 6 bits of PSD error
	and	ROTSPD,WREG
	btsc	TRNSDC,#2   ;put status of turn sensor in bit 8
	bset	W0,#7
	btsc	ENDSDC,#2   ;put status of end sensor in bit 7
	bset	W0,#6
	rcall	ramwr
;	mov	PSDSIG,W0   ;store PSD signal
;	swap	W0
;	rcall	ramwr
;	swap	W0
;	rcall	ramwr
;	mov	ACCX,W0	    ;store acceleration x signal
;	swap	W0
;	rcall	ramwr
;	swap	W0
;	rcall	ramwr
;	mov	ACCY,W0	    ;store acceleration y signal
;	mov	GYRO,W0	    ;store gyro signal
;	swap	W0
;	rcall	ramwr
;	swap	W0
;	rcall	ramwr
;	mov	FWDOUT,W0   ;store FWDOUT
;	swap	W0
;	rcall	ramwr
;	swap	W0
;	rcall	ramwr
;	mov	PDC1,W0
;	rcall	ramwr
;	mov	PDC2,W0
;	rcall	ramwr
	mov	FWDVEL,W0   ;store FWDVEL
	rcall	ramwr
;	mov	FWDDIS,W0   ;store FWDDIS
;	swap	W0
;	rcall	ramwr
;	swap	W0
;	rcall	ramwr
;	mov	FWDSPD,W0   ;store FWDSPD
;	rcall	ramwr
	return

;******************************************************************************
;Routine to dump RAM file data

dump_ram:
	rcall	crlf	    ;skip to new line
	clr	W1	    ;open read file starting at begining of RAM
	rcall	rdfile
	mov	FILSIZ,W2   ;save file size
	clr	FILSIZ	    ;init current pointer
dmpra0:	rcall	crlf	    ;display PSD error
	rcall	ramrd
	push	W1
	push	W2
	mov	W0,W2
	mov	#0x003f,W1
	and	W0,W1,W0
	rcall	byteo
	rcall	comma	    ;display turn sensor bit
	mov	#0,W0
	btsc	W2,#7
	mov	#1,W0
	rcall	niblo
	rcall	comma	    ;display end sensor bit
	mov	#0,W0
	btsc	W2,#6
	mov	#1,W0
	rcall	niblo
	pop	W2
	pop	W1
	rcall	comma	    ;display FWDVEL
	rcall	ramrd
	rcall	byteo
;	rcall	comma	    ;display FWDDIS
;	rcall	ramrd
;	rcall	byteo
;	rcall	ramrd
;	rcall	byteo
	mov	FILSIZ,W0   ;check if finished
	cpsgt	W0,W2
	bra	dmpra0	    ;loop for all data bytes
	bset	LATC,#CS1   ;turn off CS
	return

;******************************************************************************
;Routine to dump move table

dump_mov_tbl:
	mov	#tbloffset(dmpt10),W1
	rcall	mesag
	rcall	crlf	    ;display run counter
	mov	RUNCTR,W0
	rcall	byteo
	rcall	comma	    ;straight acceleration
	mov	ACCEL,W0
	swap	W0
	rcall	byteo
	rcall	comma	    ;turn acceleration^2
	mov	TRNACC,W0
	clr	W1	    ;calculate square root
	rcall	sqrt
	rcall	wordo
	rcall	comma	    ;maximum velocity
	mov	MAXVEL,W0
	rcall	wordo
	rcall	comma	    ;maximum radius limit
	mov	RADLIM,W0
	rcall	wordo
	rcall	comma	    ;begining of move buffer
	mov 	#MOVBUF,W0
	rcall	wordo
	rcall	comma	    ;end of move pointer
	mov	MOVEND,W0
	rcall	wordo
	rcall	comma	    ;number no moves
	mov	#MOVBUF,W0
	sub	MOVEND,WREG
	mov	#28,W2
	repeat	#17
	div.u	W0,W2
	rcall	wordo		
	mov	#tbloffset(dmpt11),W1
	rcall	mesag
	mov	#MOVBUF,W1  ;init move pointer
	mov	MOVEND,W2   ;init final pointer
dmpmt0:	rcall	crlf
	mov	[W1++],W0   ;display sample counter
	rcall	wordo
	rcall	comma	    ;display forward distance
	inc2	W1,W1
	mov	[W1--],W0
	rcall	wordo
	mov	[W1++],W0
	inc2	W1,W1
	rcall	wordo
	rcall	comma	    ;display rotational distance
	inc2	W1,W1
	mov	[W1--],W0
	rcall	wordo
	mov	[W1++],W0
	inc2	W1,W1
	rcall	wordo
	rcall	comma	    ;display turn radius
	mov	[W1++],W0
	rcall	wordo
	rcall	comma	    ;display initial velocity
	mov	[W1++],W0
	rcall	wordo
	rcall	comma	    ;display maximum velocity
	mov	[W1++],W0
	rcall	wordo
	rcall	comma	    ;display acceleration distance distance
	inc2	W1,W1
	mov	[W1--],W0
	rcall	wordo
	mov	[W1++],W0
	inc2	W1,W1
	rcall	wordo
	rcall	comma	    ;display maximum velocity distance
	inc2	W1,W1
	mov	[W1--],W0
	rcall	wordo
	mov	[W1++],W0
	inc2	W1,W1
	rcall	wordo
	rcall	comma	    ;display deceleration distance
	inc2	W1,W1
	mov	[W1--],W0
	rcall	wordo
	mov	[W1++],W0
	inc2	W1,W1
	rcall	wordo
	cp	W1,W2	    ;check if finished
	bra	NZ,dmpmt0   ;if no, loop for all data
	rcall	crlf	    ;display last entry
	rcall	comma
	rcall	comma
	rcall	comma	    ;display turn radius
	mov	[W1+#10],W0
	rcall	wordo
	rcall	comma	    ;display initial velocity
	mov	[W1+#12],W0
	rcall	wordo
	rcall	comma	    ;display maximum velocity
	mov	[W1+#14],W0
	rcall	wordo
	return

dmpt10:	.hword	0x0d0a
	.asciz	"RUNCTR,ACCEL,ROTACC,MAXVEL,RADLIM,MOVTBL,MOVEND,MOVCNT"
dmpt11:	.asciz	"SAMCTR,FWDDIS,ROTDIS,RADIUS,INIVEL,MAXVEL,ACCDIS,MAXDIS,DECDIS"

;******************************************************************************
;Routine to compute wheel position consistent with desired velocity profile

profil:	cp0	RUNCTR	    ;check run counter
	bra	NZ,accpro   ;if speed run, skip down
	cp0	ESCTR	    ;if search run, check if finished
	bra	Z,profi0    ;if yes, skip down
;	bra	profi2	    ;*****
	mov	MAXVEL,W0   ;if no, check if max velocity reached
	sub	FWDVEL,WREG
	bra	C,profi1    ;if yes, skip down
	mov	ACCEL,W0    ;if no, increment forward velocity
	add	VELINC
	clr	W0
	addc	FWDVEL
	return
	;
profi0:	mov	ACCEL,W0    ;decrement forward velocity
	sub	VELINC
	clr	W0
	subb	FWDVEL
profi1:	return
	;
profi2:	mov	FWDVEL,W0   ;get FWDVEL
	mov	#10,W1	    ;check if greater than 10
	cp	W0,W1
	bra	LTU,profi5  ;if no, skip down
	mov	ROTSPD,W0   ;if yes, get ROTSPD
	btsc	W0,#15	    ;take absolute value
	neg	W0,W0
	mov	#18,W1	    ;#36,W1		;scale ROTSPD by forward velocity
	mul.uu	W0,W1,W2
	mov	FWDVEL,W4
	repeat	#17
	div.ud	W2,W4
	mov	MAXVEL,W1   ;get maximum velocity
	sub	W1,W0,W1    ;reduce maximum velocity by ROTSPD
	mov	FWDVEL,W0   ;get forward velocity
	cp	W0,W1	    ;compare with modified maximum velocity
	bra	Z,profi3    ;if equal, skip down
	bra	GTU,profi4  ;if greater, skip down
profi5:	mov	ACCEL,W0    ;if less, increment forward velocity
	add	VELINC
	clr	W0
	addc	FWDVEL
profi3:	return
	;
profi4:	mov	ACCEL,W0    ;decrement forward velocity
	sub	VELINC
	clr	W0
	subb	FWDVEL
	return
		
;******************************************************************************
;Routine to handle acceleration part of profile

accpro:	mov	MOVPTR,W12  ;init pointer
	btsc	FWDDIS+2,#15	;check if FWDDIS is negative
	bra	accpr0	    ;if yes, skip down
	mov	[W12+#16],W0	;if no, check if past acceleration distance
	sub	FWDDIS,WREG ;F - WREG
	mov	[W12+#18],W0
	subb	FWDDIS+2,WREG
	bra	C,maxpro    ;if yes, skip down
accpr0:	rcall	getacc	    ;if no, increment forward velocity
	add	VELINC
	clr	W0
	addc	FWDVEL
	return

;******************************************************************************
;Routine to handle maximum velocity part of profile

maxpro:	mov	[W12+#20],W0	;check if past maximum velocity distance
	sub	FWDDIS,WREG
	mov	[W12+#22],W0
	subb	FWDDIS+2,WREG
	bra	C,decpro    ;if yes, skip down
;	clr	VELINC	    ;***** make sure velocity increment is zero
	return		    ;if no, leave velocity constant

;******************************************************************************
;Routine to handle deceleration part of profile

decpro:
;	mov	[W12+#24],W0	;check if past deceleration distance
;	sub	FWDDIS,WREG
;	mov	[W12+#26],W0
;	subb	FWDDIS+2,WREG
;	bra	NC,decpr1   ;if no, skip down
	mov	[W12+#12+28],W0	;if yes, get initial velocity for next move
;	mov	[W12+#10],W1	;check if straight
;	inc	W1,W1
;	bra	Z,decpr0    ;if yes, skip down
;	mov	[W12+#12],W0	;if no, get initial velocity for current move
decpr0:	sub	FWDVEL,WREG ;compare to forward velocity
;	bra	Z,decpr2    ;if equal, skip down
	bra	NC,decpr2   ;if forward velocity less, skip down
decpr1:
;	mov	ACCEL,W0    ;if greater, decrement forward velocity
	rcall	getacc	    ;if greater, decrement forward velocity
	sub	VELINC
	clr	W0
	subb	FWDVEL
decpr2:	return

;******************************************************************************
;Routine to get acceleration
; if straight use ACCEL
; if turn, calculate available forward acceleration

getacc:	mov	[W12+#10],W1	;check if straight
	inc	W1,W1
	bra	NZ,getac0   ;if no, skip down
	mov	ACCEL,W0    ;if yes, get forward acceleration for straight
	return
	;
getac0:	mov	FWDVEL,W0   ;get velocity
	mul.uu	W0,W0,W2    ;calculate radial acceleration
	mov	#6375,W0    ;W3:W2 = velocity^2
	mul.uu	W0,W2,W4    ;W5:W4 = 24.90358 * 256 * velocity^2
	mov	[W12+#10],W2	;get radius
	repeat	#17	    ;W0 = 6375 * velocity^2 / radius
	div.ud	W4,W2
	mov	#128,W1	    ;round result
	add	W0,W1,W0
	lsr	W0,#8,W0    ;divide by 256
	mul.uu	W0,W0,W2    ;calculate straight acceleration
	mov	MAXRA,W1    ;STRACC = sqrt(MAXRA^2 - RADACC^2)
	mul.uu	W1,W1,W4
	sub	W4,W2,W0
	clr	W1
	rcall	sqrt
	sl	W0,#8,W0    ;shift acceleration up 8 bits
	return

;******************************************************************************
;Routine to update wheel position
; later it may also calculate feed forward constants

updwp:	mov	VELINC,W0
	add	FWDINC
	mov	FWDVEL,W0
	addc	FWDERN
	return		    ;if no, return

;******************************************************************************
;Routine to get parameters from EEPROM

getpar:	mov	RUNCTR,W0   ;get run counter
	mul.uu	W0,#8,W2    ;multiply by 8
;	mov	#0xf008,W1  ;add to start address of parameters
	mov	#tbloffset(defpar+4),W1
	add	W1,W2,W1
	call	eerd	    ;get ACCEL
	sl	W0,#8,W0    ;shift acceleration up 8 bits
	mov	W0,ACCEL    ;save it
	inc2	W1,W1
	call	eerd	    ;get TRNACC
	mov	W0,FWDVEL   ;save turn velocity
	mul.uu	W0,W0,W2    ;square turn acceleration
	mov	W2,TRNACC   ;save it
	inc2	W1,W1
	call	eerd	    ;get MAXVEL
	mov	W0,MAXVEL   ;save it
	mov	#551,W0	    ;calculate maximum radial acceleration
	mov	W0,RADIUS
	rcall	radial_accel
	mov	W0,MAXRA    ;save it

	mov	MAXVEL,W0   ;calculate radius limit
	mov	#256,W1	    ;551*(MAXVEL/FWDVEL)^2
	mul.uu	W0,W1,W2
	mov	FWDVEL,W4
		
	repeat	#17
	div.ud	W2,W4

	mul.uu	W0,W0,W2
	mov	#551,W2
	mul.uu	W2,W3,W0
	mov	#5000,W0    ;*****
	mov	W0,RADLIM   ;save it

	return

;******************************************************************************
;Routine to decode and execute commands from the serial interface

comand:	rcall 	ser1in	    ;get command
	mov.b	#'+',W1	    ;check if increase pulse width command
	cpsne.b	W0,W1
	bra	incpw	    ;if yes, skip down
	mov.b	#'-',W1	    ;if no, check if decrease pulse width command
	cpsne.b	W0,W1
	bra	decpw	    ;if yes, skip down
	mov.b	#'0',W1	    ;if no, check if zero pulse width command
	cpsne.b	W0,W1
	bra	zeropw	    ;if yes, skip down
	mov.b	#'2',W1	    ;check if MAX21003 test command
	cpsne.b	W0,W1
	bra	max2	    ;if yes, skip down
	mov.b	#'3',W1	    ;if no, check if ADXL345 test command
	cpsne.b	W0,W1
	bra	adx3	    ;if yes, skip down
	mov.b	#'6',W1	    ;if no, check if MPU-6500 test command
	cpsne.b	W0,W1
	bra	mpu6	    ;if yes, skip down
	mov.b	#'a',W1	    ;if no, check if ADC test command
	cpsne.b	W0,W1
;	bra	adctst	    ;if yes, skip down
	bra	psdtst
	mov.b	#'d',W1	    ;if no, check if diagnostic command
	cpsne.b	W0,W1
	bra	diag	    ;if yes, skip down
	mov.b	#'l',W1	    ;if no, check if list command
	cpsne.b	W0,W1
	bra	listc	    ;if yes, skip down
	mov.b	#'m',W1	    ;if no, check if memory test
	cpsne.b	W0,W1
	bra	memtst	    ;if yes, skip down
	mov.b	#'n',W1	    ;if no, check if motion control test
	cpsne.b	W0,W1
	bra	motion	    ;if yes, skip down
	mov.b	#'p',W1	    ;if no, check if edit parameters command
	cpsne.b	W0,W1
	bra	editparam   ;if yes, skip down
	mov.b	#'s',W1	    ;if no, check if sensor test
	cpsne.b	W0,W1
;	bra	sentst	    ;if yes, skip down
;	bra	psdtst
	bra	simulate
	mov.b	#'t',W1	    ;if no, check if blink LEDs
	cpsne.b	W0,W1
	bra	tled	    ;if yes, skip down
;	bra	testvp
	mov.b	#'v',W1	    ;if no, check if version command
	cpsne.b	W0,W1
	bra	ver	    ;if yes, skip down
	mov.b	#'w',W1	    ;if no, check if init move table command
	cpsne.b	W0,W1
	bra	winit	    ;if yes, skip down
	mov.b	#'y',W1	    ;if no, check if simulate velocity profile command
	cpsne.b	W0,W1
	bra	svp	    ;if yes, skip down
	mov.b	#'z',W1	    ;if no, check if version command
	cpsne.b	W0,W1
	bra	chkstk	    ;if yes, skip down
	mov.b	#'?',W0	    ;if no, flag error
	goto	ser1out

;******************************************************************************
;Routine to test motion control

motion:	mov	#tbloffset(moti10),W1
	rcall	mesag
	rcall	crlf
	bset	LATB,#LEDR  ;turn off red LED
	bset	LATC,#LEDG  ;turn off green LED
	clr	W1	    ;open write file starting at begining of RAM
	rcall	wrfile
	clr	FILSIZ	    ;init file pointer
;	rcall	senze0	    ;measure sensor zero
	call	encodr	    ;zero encoders
	clr	FWDINC	    ;init motor control variables
	clr	FWDERN
	clr	FWDERO
	clr	FWDOUT
	clr	SAMCTR	    ;init sample counter
	clr	FWDDIS	    ;init forward distance
	clr	FWDDIS+2
	clr	ROTDIS	    ;init rotational distance
	clr	ROTDIS+2
	mov	#2,W0	    ;init end signal counter
	mov	W0,ESCTR
	mov	#MOVBUF,W0  ;init move buffer pointer
	mov	W0,MOVPTR
	call	getpar	    ;update run parameters
	rcall	updmt	    ;update move table based on run parameters
;	mov	#36*36,W0   ;init turn acceleration (20*20)
;	mov	W0,TRNACC
;	mov	#0x3000,W0
;	mov	W0,ACCEL
	clr	FWDVEL
	clr	VELINC
;	mov	#36,W0
;	mov	W0,MAXVEL
;	clr	ROTVEL
;	bclr	LATE,#1	    ;clear left direction bit
;	bclr	LATE,#3	    ;clear right direction bit
	bset	PTCON,#PTEN ;enable PWM

motio0:	btss	IFS0,#T1IF  ;check if Timer 1 timed out
	bra	motio0	    ;if no, loop again
	bclr	IFS0,#T1IF  ;if yes, clear Timer 1 interrupt flag
	rcall	psd
	rcall	encodr
	mov	PSDERR,W0
	asr	W0,#2,W0    ;divide signal
	add	PSDDER,WREG ;add derivative 
	add	PSDDER,WREG ;x2
	add	PSDDER,WREG ;x3
	add	PSDDER,WREG ;x4
	add	PSDDER,WREG ;x5 
	add	PSDDER,WREG ;x6
	add	PSDDER,WREG ;x7
	add	PSDDER,WREG ;x8
	mov	W0,ROTVEL
;	rcall	profil	    ;update velocity profile
;	rcall	updwp	    ;update wheel position
	rcall	dmctrl	    ;control drive motors
	rcall	mtrdrv
	mov.b	#0x0d,W0    ;skip to new line
	rcall	so
	mov	PSDERR,W0
	rcall	wordo
	rcall	comma
	mov	LEFENC,W0
	rcall	wordo
	rcall	comma
	mov	RITENC,W0
	rcall	wordo
	rcall	comma
	mov	FWDERN,W0
	rcall	wordo
	rcall	comma
	mov	FWDERO,W0
	rcall	wordo
	rcall	comma
	mov	FWDOUT,W0
	rcall	wordo
	rcall	comma
	mov	PDC2,W0
	rcall	byteo
	rcall	comma
	mov	PDC4,W0
	rcall	byteo
	rcall	comma
	mov	PDC6,W0
	rcall	byteo
	rcall	comma
	mov	PDC5,W0
	rcall	byteo
	btss	U1STA,#URXDA	;check if character is available
	bra	motio0	    ;if no, loop again
	call	crlf	    ;if yes, skip to new line
	clr	PDC2
	clr	PDC4
	clr	PDC5
	clr	PDC6
	mov	#tbloffset(moti11),W1
	rcall	mesag
	return		    ;return

moti10:	.hword	0x0d0a
	.asciz	"Motion Control Test"
moti11:	.asciz	"Test Aborted"

;******************************************************************************
;Routine to increase pulse width

incpw:	bset	PTCON,#PTEN ;enable PWM
	inc	FWDVEL	    ;increment PWM pulse width
	bra	zerop0	    ;skip down

;******************************************************************************
;Routine to decrease pulse width

decpw:	bset	PTCON,#PTEN ;enable PWM
	dec	FWDVEL	    ;decrement PWM pulse width
	bra	zerop0	    ;skip down

;******************************************************************************
;Routine to zero pulse width

zeropw:	bset	PTCON,#PTEN ;enable PWM
	clr	FWDVEL	    ;zero PWM pulse width
zerop0:	call	crlf	    ;display new value
	mov	FWDVEL,W0
	call	wordo
;	bra	mtrdrv	    ;output to motor drive
	mov	FWDVEL,W0   ;get new value
	btsc	W0,#15	    ;check if negative
	bra	zerop1	    ;if yes, skip down
	mov	W0,PDC2	    ;left
	mov	W0,PDC6	    ;right
	clr	PDC4	    ;left
	clr	PDC5	    ;right
	return
	;
zerop1:	neg	W0,W0
	mov	W0,PDC4	    ;left
	mov	W0,PDC5	    ;right
	clr	PDC2	    ;left
	clr	PDC6	    ;right
	return

;******************************************************************************
;Routine to edit parameters
	;
	;display all current parameters
	;
editparam:
	mov	#tbloffset(edtp10),W1
	rcall	mesag
	clr	W10	    ;init loop counter
	mov	#5,W11	    ;init end
;	mov	#tblpage(defpar+4),W0
;	mov	W0,TBLPAG
	mov	#tbloffset(defpar+4),W1
edtpa0:	mov	#1,W3	    ;check if run 1
	cpsne	W3,W10
	rcall	crlf	    ;if yes, skip extra line
	rcall	crlf	    ;display run nunmber
	mov	#2,W3
	rcall	edtpa2
	mov	W10,W0
	rcall	niblo
	rcall	edtpa1	    ;display ACCEL from flash
	rcall	eerd
	inc2	W1,W1
	rcall	binasc
	rcall	edtpa1	    ;display TRNACC from flash
	call	eerd
	inc2	W1,W1
	rcall	binasc
	rcall	edtpa1	    ;display MAXVEL from flash
	rcall	eerd
	inc2	W1,W1
	rcall	binasc
	rcall	edtpa1	    ;display RUNTIM from flash
	rcall	eerd
	inc2	W1,W1
	rcall	binasc
	inc	W10,W10
	cpseq	W10,W11
	bra	edtpa0
	;
	;move data to RAM buffer
	;
	mov	#tblpage(defpar),W0 ;init table page
	mov	W0,TBLPAG
	mov	#tbloffset(defpar),W1	;copy parameters into RAM
	mov	#MOVBUF,W2
	mov	#512,W3	    ;I am copying the entire page that will be erased - I only
			    ;use one row of that so I could set the counter to 64
edtpa7:	tblrdl	[W1],[W2++]
	tblrdh	[W1++],[W2++]
	dec	W3,W3
	bra	NZ,edtpa7
	clr	TBLPAG
	;
	;edit paramters
	;
	mov	#tbloffset(edtp11),W1
	rcall	mesag
	mov	#tbloffset(edtp12),W1
	mov	#MOVBUF,W11
	rcall	edtpa3
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa8	    ;if yes, skip down
	mov	#tbloffset(edtp13),W1
	mov	#MOVBUF+4,W11
	rcall	edtpa3
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa8	    ;if yes, skip down
	mov	#tbloffset(edtp14),W1
	rcall	mesag
	mov	#MOVBUF+8,W11
	rcall	edtpa5
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa8	    ;if yes, skip down
	mov	#1,W10
edtpa6:	mov	#tbloffset(edtp15),W1
	rcall	mesag
	mov	W10,W0
	call	niblo
	rcall	edtpa5
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa8	    ;if yes, skip down
	inc	W10,W10
	mov	#5,W0
	cpseq	W0,W10
	bra	edtpa6
	;
	;write new parameters back to flash
	;
	mov	#0,W0	    ;init nonvolatile data memory upper address register
	mov	W0,NVMSRCADRH
	mov	#MOVBUF,W0  ;init nonvolatile data memory lower address register
	mov	W0,NVMSRCADRL
	mov	#tblpage(defpar),W0	;init nonvolatile memory uppder address register
	mov	W0,NVMADRU
	mov	#tbloffset(defpar),W0	;init nonvolatile memroy lower address register
	mov	W0,NVMADR
	rcall	flashwr	    ;erase page
	
	mov	#tbloffset(edtp19),W1
	rcall	mesag
edtpa8:	rcall	crlf
	return
	;
	;edit one set of run parameters
	;
edtpa5:	mov	#tbloffset(edtp16),W1
	rcall	edtpa3
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa4	    ;if yes, skip down
	inc2	W11,W11
	inc2	W11,W11
	mov	#tbloffset(edtp17),W1
	rcall	edtpa3
	mov.b	#0x1b,W0    ;check if ESC
	cpsne.b	W0,W6
	bra	edtpa4	    ;if yes, skip down
	inc2	W11,W11
	inc2	W11,W11
	mov	#tbloffset(edtp18),W1
	rcall	edtpa3
	inc2	W11,W11
	inc2	W11,W11
	inc2	W11,W11
	inc2	W11,W11
	return		
	;
	;edit one parameter in RAM pointed to by W11
	;
edtpa3:	rcall	mesag	    ;display label
	mov	[W11],W0    ;display value in RAM
	call	binasc
	mov.b	#' ',W0
	rcall	so
	rcall	ascbin	    ;update if required
	bra	NC,edtpa4   ;if no, skip down
	mov	W2,[W11]    ;if yes, save new value to RAM
edtpa4:	return
	;
edtpa1:	mov	#5,W3
edtpa2:	mov.b	#' ',W0
	rcall	so
	dec	W3,W3
	bra	NZ,edtpa2
	return
		;
edtp10:	.hword	0x0d0a
	.ascii	"          Performance Parameters"
	.hword	0x0d0a
	.ascii	" Run   Straight   Turn     Straight   Time"
	.hword	0x0d0a
	.asciz	"Number  Accel    Velocity  Max Vel    (msec)"
edtp11:	.hword	0x0d0a
	.asciz	"Parameter Display and Update Routine (ESC=Quit)"
edtp12:	.asciz	"flags = "
edtp13:	.asciz	"param expan = "
edtp14:	.asciz	"Parameters for Search"
edtp15:	.asciz	"Parameters for Speed Run "
edtp16:	.asciz	"  fwdacc = "
edtp17:	.asciz	"  trnacc = "
edtp18:	.asciz	"  maxvel = "
edtp19:	.asciz	"Parameters updated"
	
;******************************************************************************
;Routine to simulate move table for all runs

simulate:
	mov	#tbloffset(simu10),w1
	rcall	mesag
	mov	RUNCTR,W0   ;save run counter
	push	W0
	clr	RUNCTR
simul0:	rcall	getpar	    ;update run parameters
	rcall	updmt	    ;update move table based on run parameters
	rcall	dump_mov_tbl	;display move table
	inc	RUNCTR	    ;increment run counter
	mov	#5,W0	    ;check if last run
	cp	RUNCTR
	bra	NZ,simul0   ;if no, loop for next run
	pop	W0	    ;restore run counter
	mov	W0,RUNCTR
	return

simu10:	.hword	0x0d0a
	.asciz	"Simulate Move Table"

;******************************************************************************
;Routine to init move table with data from table

initmt:
;	mov	#tbloffset(home_track),W2   ;init pointer
;	mov	#tbloffset(taiwan_2013),W2	;init pointer
;	mov	#tbloffset(japan_2013a),W2	;init pointer
;	mov	#tbloffset(japan_2013b),W2	;init pointer
;	mov	#tbloffset(japan_2013_qualifying),W2	;init pointer
;	mov	#tbloffset(japan_2014_final),W2	;init pointer
;	mov	#tbloffset(japan_2015_test),W2	;init pointer
;	mov	#tbloffset(japan_2015_qualifying),W2	;init pointer
;	mov	#tbloffset(japan_2015_final),W2	;init pointer
	mov	#tbloffset(taiwan_2016_pm3),W2	;init pointer
	mov	#MOVBUF,W4  ;init pointer
initm2:	tblrdl	[W2++],W0   ;get SAMCTR
	cp0	W0	    ;check if zero
	bra	Z,initm3    ;if yes, skip down
	mov	W0,[W4++]   ;if no, save it
	tblrdl	[W2++],W0   ;init FWDDIS
	mov	W0,[W4++]
	tblrdl	[W2++],W0
	mov	W0,[W4++]
	tblrdl	[W2++],W0   ;init ROTDIS
	mov	W0,[W4++]
	tblrdl	[W2++],W0
	mov	W0,[W4++]
	clr	W3
	repeat	#8
	mov	W3,[W4++]   ;clear remaining data in record
	mov	W4,MOVEND
	bra	initm2	    ;loop for next segment
	;
initm3:	return

;******************************************************************************
;A/D converter test routine

adctst: mov	#tbloffset(adct10),W1
        rcall   mesag

	bclr	AD1CON1,#SAMP	;start ADC1 conversion
        bclr    AD2CON1,#SAMP   ;start ADC2 conversion
adcts0:	btss	AD1CON1,#SAMP	;wait until ADC1 is finished
	bra	adcts0
        btss    AD2CON1,#SAMP   ;wait until ADC2 is also finished
        bra     adcts0

        rcall   crlf
        mov     ADC1BUF0,W0	;BATT
        rcall   wordo
        rcall   comma
        mov     ADC1BUF1,W0	;CFA
        rcall   wordo
        rcall   comma
        mov     ADC1BUF2,W0	;CFB
        rcall   wordo
        rcall   comma
        mov     ADC1BUF3,W0	;END1
        rcall   wordo
        rcall   comma
        rcall   comma
        mov     ADC2BUF0,W0	;END1
        rcall   wordo
        rcall   comma
        mov     ADC2BUF1,W0	;END2
        rcall   wordo
        rcall   comma
        mov     ADC2BUF2,W0	;TRN2
        rcall   wordo
        rcall   comma
        mov     ADC2BUF3,W0	;TRN1
        rcall   wordo
        return

adct10:	.hword	0x0a0d
	.ascii	"ADC Test"
    	.hword	0x0a0d
	.asciz	"BATT, CFA, CFB,END1,,END1,END2,TRN2,TRN1"

;******************************************************************************
;PSD test routine

psdtst:	mov	#tbloffset(psdt10),W1
	rcall	mesag
	rcall	crlf
psdts0:	mov.b	#0x0d,W0    ;move to begining of line (CR)
	call	so
	bclr	LATB,#LEDR  ;turn on red LED
	rcall	psd	    ;get PSD data
	bset	LATB,#LEDR  ;turn off red LED
	bclr	LATB,#LEDR  ;turn on red LED
	rcall	encodr
	bset	LATB,#LEDR  ;turn off red LED
	mov	PSDA,W0	    ;display results
	rcall	wordo
	rcall	comma
	mov	PSDB,W0
	rcall	wordo
;	rcall	comma
;	mov	PSDSIG,W0
;	rcall	wordo
	rcall	comma
	mov	PSDERR,W0
	rcall	wordo
	rcall	comma
	mov	ENDS1,W0
	rcall	wordo
	rcall	comma
	mov	ENDS2,W0
	rcall	wordo
	rcall	comma
	mov	TRNS1,W0
	rcall	wordo
	rcall	comma
	mov	TRNS2,W0
	rcall	wordo
	rcall	comma
	mov	BATT,W0
	rcall	wordo
;	rcall	comma
;	mov	BATCOR,W0
;	rcall	wordo
	rcall	comma
	mov	LEFENC,W0
	rcall	wordo
	rcall	comma
	mov	RITENC,W0
	rcall	wordo
	rcall	comma
	mov.b	#'0',W0
	btsc	FLAG0,#LOBATF
	mov.b	#'1',W0
	call	so
	rcall	comma
	mov.b	#'0',W0
	btsc	FLAG0,#LOSIGF
	mov.b	#'1',W0
	call	so
	btss	U1STA,#URXDA	;check if character is available
	bra	psdts0	    ;if no, loop again
	call	crlf	    ;if yes, skip to new line
	return		    ;return

psdt10:	.hword	0x0d0a
	.ascii	"Sensor Test"
	.hword	0x0d0a
	.asciz	"PSDA,PSDB,PSDERR,ENDS1,ENDS2,TRNS1,TRNS2,BATT,LEFENC,RITENC,LOBATF,LOSIGF"

;******************************************************************************
;PSD sensor routine
; 84.4 usec @ 7.35 MHz
	;
	;get sensor values with LED off
	;
psd:	bclr	AD1CON1,#SAMP	;start A/D conversion
	bclr	AD2CON1,#SAMP
	nop		    ;make sure sample mode has stopped
	nop
	bset	LATE,#LED   ;turn on PSD and TRN/END LED
;	bclr	LATC,#LEDG  ;turn on green LED
psd0:	btss	AD2CON1,#SAMP	;wait until A/D is finsihed
	bra	psd0
;	bset	LATC,#LEDG  ;turn off green LED (7.0 usec)
	mov	ADC1BUF1,W2 ;save zero data
	mov	ADC1BUF2,W3
	mov	ADC2BUF0,W10
	mov	ADC2BUF1,W11
	mov	ADC2BUF2,W12
	mov	ADC2BUF3,W13
	;
	;delay for sensor to settle after LED is turned on
	;
	mov	#55,W0	    ;delay for signal to settle
psd1:	dec	W0,W0	    ;each loop is 5 cycles
	bra	NZ,psd1	    ;5 * 67.82 nsec = 339.1 nsec
	;
	;get sensor values with LED on
	;
	bclr	AD1CON1,#SAMP	;start A/D conversion
	bclr	AD2CON1,#SAMP
	nop		    ;make sure sample mode has stopped
	nop
	bclr	LATE,#LED   ;turn off PSD and TRN/END LED
;	bclr	LATC,#LEDG  ;turn on green LED (17.8 usec)
psd2:	btss	AD2CON1,#SAMP	;wait until A/D is finished
	bra	psd2
;	bset	LATC,#LEDG  ;turn off green LED (7.2 usec)
	mov	ADC1BUF1,W4
	mov	ADC1BUF2,W5
	;
	;calculate sensor signals
	;
	sub	W2,W4,W4
	btss	SR,#C	    ;check for underflow
	clr	W4
	mov	W4,PSDA	    ;save signal
	sub	W3,W5,W5
	btss	SR,#C	    ;check for underflow
	clr	W5
	mov	W5,PSDB	    ;save signal
	;
	;balance signals
	;
	mov	#55253,W2   ;reduce gain of PSDB by 0.843101
	mul.uu	W2,W5,W0    ;0.843101 * 2^16
	mov	W1,W5
	mov	W5,PSDB
	;
	;A + B
	;
	add	W4,W5,W6
	inc	W6,W6	    ;***** make sure no division by zero *****
	mov	W6,PSDSIG   ;save result
	;
	;check signal strength
	;
	bclr	FLAG0,#LOSIGF	;clear low signal flag
	mov	#40,W0	    ;check if signal is too small
	cpslt	W0,W6
	bset	FLAG0,#LOSIGF	;is yes, set low signal flag
	;
	;(B * Gain)/(A + B)
	;
	mov	#1024,W0
	mul.uu	W0,W4,W8
	repeat	#17
	div.ud	W8,W6
	sub	#512,W0	    ;subtract offset
	mov	W0,PSDERR   ;save result
	subr	OLDERR,WREG ;calculate derivative
	mov	W0,PSDDER   ;save it
	mov	PSDERR,W0   ;age error
	mov	W0,OLDERR
	;
	;get other signals
	;
	mov	ADC2BUF0,W0 ;TRN2
	sub	W0,W10,W0
	btss	SR,#C	    ;check for underflow
	clr	W0
	mov	W0,TRNS2    ;save result
	mov	ADC2BUF1,W0 ;TRN1
	sub	W0,W11,W0
	btss	SR,#C	    ;check for underflow
	clr	W0
	mov	W0,TRNS1    ;save result
	mov	ADC2BUF2,W0 ;END1
	sub	W0,W12,W0
	btss	SR,#C	    ;check for underflow
	clr	W0
	mov	W0,ENDS1    ;save result
	mov	ADC2BUF3,W0 ;END2
	sub	W0,W13,W0
	btss	SR,#C	    ;check for underflow
	clr	W0
	mov	W0,ENDS2    ;save result
	;
	;calculate battery voltage correction
	;
	mov	ADC1BUF0,W0	;save battery voltage
	mov	W0,BATT
	bclr	FLAG0,#LOBATF	;clear low battery flag
	mov	#700,W0	    ;check for low battery voltage
	sub	BATT,WREG   ;700 = 6 volts
	btss	SR,#C
	bset	FLAG0,#LOBATF	;set low battery flag
	mov	#0xf000,W2  ;calculate battery correction
	mov	#0x0035,W3  ;863 = 7.4 volts
	mov	BATT,W4	    ;863 * 256 * 16
	repeat	#17
	div.ud	W2,W4
	mov	W0,BATCOR
	return

;******************************************************************************
;Encoder input routine

encodr:	mov     POS1CNTL,W0 ;get encoder 1 (left)
	subr	LEFENC,WREG ;calculate left wheel speed
	add	LEFENC	    ;save new encoder value
	mov	W0,LEFSPD   ;save left wheel speed
        mov     POS2CNTL,W0 ;get encoder 2 (right)
	subr	RITENC,WREG ;calculate right wheel speed
	add	RITENC	    ;save new encoder value
	mov	W0,RITSPD   ;save right wheel speed
	add	LEFSPD,WREG ;calculate forward speed
	mov	W0,FWDSPD   ;save it
	sub	FWDERN	    ;subtract from forward error
	add	FWDDIS	    ;add to forward distance
	clr	W0
	btsc	FWDSPD,#15
	setm	W0
	addc	FWDDIS+2
	mov	LEFSPD,W0   ;calculate rotational speed
	sub	RITSPD,WREG
	mov	W0,ROTSPD   ;save it
	add	ROTDIS	    ;add to rotational distance
	clr	W0
	btsc	ROTSPD,#15
	setm	W0
	addc	ROTDIS+2
	return

;******************************************************************************
;Routine to display diagnostic parameters

diag:   rcall   ycmd
    	mov	#tbloffset(diag10),W1
	rcall	mesag
	mov	#tbloffset(diag11),W1
	rcall	mesag
	mov	OSCCON,W0
	call	wordo
	mov	#tbloffset(diag12),W1
	rcall	mesag
	mov	CLKDIV,W0
	call	wordo
	mov	#tbloffset(diag13),W1
	rcall	mesag
	mov	PLLFBD,W0
	call	wordo

	mov	#tbloffset(diag14),W1
	rcall	mesag
	mov	#tblpage(defpar),W0
	rcall	wordo

	mov	#tbloffset(diag15),W1
	rcall	mesag
	mov	#tbloffset(defpar),W0
	rcall	wordo
	
	rcall	diag0	    ;display data in flash

	mov	#tblpage(defpar),W0 ;init table page
	mov	W0,TBLPAG
	mov	#tbloffset(defpar),W1	;copy parameters into RAM
	mov	#MOVBUF,W2
	mov	#512,W3
diag3:	tblrdl	[W1],W0
	mov	W0,[W2++]
	tblrdh	[W1++],W0
	mov	W0,[W2++]
	dec	W3,W3
	bra	NZ,diag3
	clr	TBLPAG
	
	rcall	diag4	    ;display data copied to RAM

	mov	#0,W0	    ;init nonvolatile data memory upper address register
	mov	W0,NVMSRCADRH
	mov	#MOVBUF,W0  ;init nonvolatile data memory lower address register
	mov	W0,NVMSRCADRL
	mov	#tblpage(defpar),W0	;init nonvolatile memory uppder address register
	mov	W0,NVMADRU
	mov	#tbloffset(defpar),W0	;init nonvolatile memroy lower address register
	mov	W0,NVMADR
	rcall	flashwr	    ;erase page

	rcall	diag0	    ;display new data in flash

	return
	
diag0:	mov	#tbloffset(defpar),W1	;init pointer
	mov	#128,W2	    ;init line counter
diag1:	mov	#8,W3	    ;init word counter
	rcall	crlf
diag2:	tblrdh	[W1],W0	    ;display upper byte
;	call	wordo
	call	byteo
	tblrdl	[W1++],W0   ;display lower byte
	rcall	wordo
	mov.b	#',',W0
	rcall	so
	dec	W3,W3
	bra	NZ,diag2
	dec	W2,W2
	bra	NZ,diag1
	return

diag4:	mov	#MOVBUF,W1	;init pointer
	mov	#128,W2	    ;init line counter
diag5:	mov	#8,W3	    ;init word counter
	rcall	crlf
diag6:	mov	[W1++],W0   ;display lower byte
	rcall	wordo
	mov.b	#',',W0
	rcall	so
	dec	W3,W3
	bra	NZ,diag6
	dec	W2,W2
	bra	NZ,diag5
	return

diag10:	.hword	0x0a0d
	.asciz	"Diagnostic"
diag11:	.asciz	" OSCCON = "
diag12:	.asciz	" CLKDIV = "
diag13:	.asciz	" PLLFBD = "
diag14:	.asciz	" Parameter Table Page = "
diag15:	.asciZ	" Parameter Table Offset = "

;******************************************************************************
;Routine to display configuration registers

ycmd:	mov	#tbloffset(ycmd1),w1
	rcall	mesag

;	mov	#tblpage(FICD),W0   ;init table page
	mov	#0x0005,W0  ;init table page of configuration registers
	mov	W0,_TBLPAG
;	mov	#tbloffset(FICD),W1 ;init pointer
	mov	#0x57f0,W1  ;init offset of FICD
	call	ycmd0	    ;display oscillator configuration (FICD)
	call	ycmd0	    ;display watchdog timer (FPOR)
	call	ycmd0	    ;display BOF and POR (FWDT)
	call	ycmd0	    ;display boot code segment (FOSC)
	call	ycmd0	    ;display secure code segment (FOSCSEL)
	call	ycmd0	    ;display general code segment (FGS)

	mov	#0x0000,W0  ;init table page back to default
	mov	W0,_TBLPAG
	return

ycmd0:	rcall	crlf	    ;skip to new line
	mov	_TBLPAG,W0  ;display table page address
	call	byteo
	mov	W1,W0	    ;display offset address
	call	wordo
	mov.b	#0x20,W0    ;space
	rcall	ser1out

;	tblrdh	[W1],W0	    ;display upper byte
;	call	wordo
;	call	byteo
	tblrdl	[W1++],W0   ;display lower byte
	bra	byteo

ycmd1:	.hword	0x0a0d
	.asciz	"Display Configuration Registers"

;******************************************************************************
;Routine to display list of available commands

listc:	mov	#tbloffset(list0),w1
	bra	mesag

list0:	.hword	0x0a0d
	.ascii	"LIST OF AVAILABLE COMMANDS"
	.hword	0x0a0d
	.ascii	" +  increase pulse width"
	.hword	0x0a0d
	.ascii	" -  decrease pulse width"
	.hword	0x0a0d
	.ascii	" 0  zero pulse width"
	.hword	0x0a0d
	.ascii	" 2  MAX21003"
	.hword	0x0a0d
	.ascii	" 3  ADXL345"
	.hword	0x0a0d
	.ascii	" 6  MPU6500"
	.hword	0x0a0d
	.ascii	" a  ADC test"
	.hword	0x0a0d
	.ascii	" d  diagnostic"
	.hword	0x0a0d
	.ascii	" l  list available commands"
	.hword	0x0a0d
	.ascii	" m  memory test"
	.hword	0x0a0d
	.ascii	" p  parameter edit command"
	.hword	0x0a0d
;	.ascii	" s  sensor test"
	.ascii	" s  simulate move table calculations"
	.hword	0x0a0d
;	.ascii	" t  toggle LEDs"
	.ascii	" t  test velocity profile"
	.hword	0x0a0d
	.ascii	" v  version of firmware"
	.hword	0x0a0d
	.ascii	" w  init move table with simulated data"
	.hword	0x0a0d
	.ascii	" y  simulate velocity profile"
	.hword	0x0a0d
	.asciz	" z  display stack pointer"

;******************************************************************************
;Routine to test external memory

memtst:	mov	#tbloffset(memt10),w1
        rcall   mesag
        rcall   crlf
        clr     W2
        clr     W3
        rcall   wrfile
        mov     #0,W1
memts0: mov     W1,W0
        rcall   ramwr
        dec     W1,W1
        bra     NZ,memts0
        clr     W2
        clr     W3
        rcall   rdfile
        mov     #0,W1
memts1: rcall   ramrd
        cp      W0,W1
        bra     NZ,memts2
        dec     W1,W1
        bra     NZ,memts1
        mov.b   #'O',W0
        rcall   ser1out
        mov.b   #'K',W0
        rcall   ser1out
        return
        ;
memts2: mov.b   #'N',W0
        rcall   ser1out
        mov.b   #'G',W0
        rcall   ser1out
        return

memt10:	.hword	0x0a0d
	.asciz	"Memory Test"

;******************************************************************************
;Routine to initialize move table 

winit:	mov	#tbloffset(wini10),w1
	rcall	mesag
	rcall	initmt
	bra	crlf

wini10:	.hword	0x0d0a
	.asciz  "Initialze move table"

;******************************************************************************
;Routine to simulate velocity profile 

svp:	mov	#tbloffset(svp10),w1	;display sigon message
	rcall	mesag

;	call	initmt	    ;***** for testing load standard move table

	mov	#1,W0	    ;init run counter
	mov	W0,RUNCTR

svp0:	rcall	getpar	    ;update run parameters
	rcall	updmt	    ;update move table based on run parameters

	rcall	dump_mov_tbl	;display move table

	mov	#MOVBUF,W0  ;init move buffer pointer
	mov	W0,MOVPTR

	mov	#tbloffset(svp11),w1	;display column headings
	rcall	mesag

	clr	ETCTR	    ;init elapsed time counter
	clr	FWDVEL	    ;init velocity
	clr	VELINC

svp1:	clr	FWDINC	    ;init forward distance
	clr	FWDDIS	    ;***** could not clear FWDINC every time
	clr	FWDDIS+2    ;***** could subtract segment distance from FWDDIS
svp6:	clr	SEGINC	    ;init distance in segment
	clr	SEGDIS
	clr	SEGDIS+2

svp2:
	rcall	svp5	    ;display velocity

	rcall	profil	    ;update velocity

	mov	VELINC,W0   ;update forward distance
	add	FWDINC	    ;FWDDIS may be > SEGDIS if two or more
	mov	FWDVEL,W0   ;straight segments are concatenated
	addc	FWDDIS
	clr	W0
	addc	FWDDIS+2

	mov	VELINC,W0   ;update segment distance
	add	SEGINC
	mov	FWDVEL,W0
	addc	SEGDIS
	clr	W0
	addc	SEGDIS+2

	inc	ETCTR	    ;update elapsed time counter

	mov	MOVPTR,W0   ;check if in next to last segment
	add	W0,#28,W0
	sub	MOVEND,WREG
	bra	NZ,svp3	    ;if no, skip down

	cp0	FWDVEL	    ;if yes, check if velocity is 0
	bra	Z,svp4	    ;if yes, skip down

svp3:	mov	MOVPTR,W12  ;***** may not be needed, done in profil
	mov	[W12+#2],W0 ;check if past segment distance
	sub	SEGDIS,WREG
	mov	[W12+#4],W0
	subb	SEGDIS+2,WREG
	bra	NC,svp2	    ;if no, loop for next time step

	mov	#28,W0	    ;if yes, increment move table pointer
	add	MOVPTR

	mov	MOVPTR,W0   ;check if last segment
	sub	MOVEND,WREG
	bra	Z,svp4	    ;if yes, skip down

	mov	[W12+#10],W0	;if no, check if last segment was a straight
	inc	W0,W0
	bra	NZ,svp1	    ;if no, reset FWDDIS and SEGDIS
	mov	[W12+#10+28],W0	;if yes, check if new segment is a straight
	inc	W0,W0
	bra	NZ,svp1	    ;if no, reset FWDDIS and SEGDIS
	bra	svp6	    ;if yes, reset only SEGDIS
		;
svp4:	rcall	svp5	    ;if yes, display final data	

	mov	#tbloffset(svp12),w1	;display mesage
	rcall	mesag

	mov	ETCTR,W0    ;display elapsed time
	rcall	binasc

;	inc	RUNCTR
;	mov	#5,W0
;	cp	RUNCTR
;	bra	NZ,svp0

	bra	crlf
		;
svp5:
;	return		    ;*****
	rcall	crlf	    ;skip to new line	
	mov	FWDVEL,W0   ;display FWDVEL
	rcall	binasc
	rcall	comma
	mov	VELINC,W0   ;display VELINC
	rcall	binasc
	rcall	comma
	mov	[W12+#10],W0	;display radius
	inc	W0,W0
	bra	binasc

svp10:	.hword	0x0d0a
	.asciz  "Simulate Velocity Profile"
svp11:	.asciz	"FWDVEL,VELINC,RADIUS"
svp12:	.ascii  "Simulation Finished"
	.hword	0x0d0a
	.asciz	"Elapsed Time (msec) = "

;******************************************************************************
;Routine to display stack pointer

chkstk:	mov	#tbloffset(chks10),W1
	rcall	mesag
	mov	W15,W0
	call	wordo
	mov	#tbloffset(chks11),W1
	rcall	mesag
	mov	SPLIM,W0
	call	wordo
	mov	#tbloffset(chks12),W1
	rcall	mesag
	mov	RCON,W0
	call	wordo
	mov	#tbloffset(chks13),W1
	rcall	mesag
	mov	INTCON1,W0
	call	wordo
	mov	#0x1f00,W0		;clear all reasons for reset flags
	and	RCON
	return

chks10:	.hword	0x0d0a
	.ascii  "Check stack pointer"
	.hword	0x0d0a
	.asciz	"  W15 (stack pointer) = "
chks11:	.asciz  "  SPLIM = "
chks12:	.asciz  "  RCON = "
chks13:	.asciz  "  INTCON1 = "

;******************************************************************************
;Routine to test sensors

sentst:	mov	#tbloffset(sent10),w1
        rcall   mesag
sents0:	mov.b	#0x0d,W0    ;cariage return
	rcall	ser1out
        mov     POS1CNTL,W0 ;get encoder 1
        rcall   binasc      ;display result
        rcall   comma
        mov     POS2CNTL,W0 ;get encoder 2
        rcall   binasc      ;display result

        ;test SPI2

        rcall   comma       ;send and received byte on SPI2
        bclr    LATB,#CS2   ;turn on CS
        mov     #0xf5,W0    ;init command (WHO AM I)
        rcall   shft2       ;shift out command
        rcall   shft2       ;shift in response

;	mov     W0,SPI2BUF  ;output command
;        mov     SPI2BUF,W0  ;flush buffer
;        bclr    SPI2STAT,#SPIROV    ;clear overflow flag
;sents1: btss    SPI2STAT,#SPIRBF    ;wait for received character
;        bra     sents1
;        mov     #50,W0
;sents1: dec     W0,W0
;        bra     NZ,sents1
;        mov     W0,SPI2BUF  ;clock in response
;        mov     SPI2BUF,W0  ;flush buffer
;        bclr    SPI2STAT,#SPIROV    ;clear overflow flag
;sents2: btss    SPI2STAT,#SPIRBF    ;wait for received character
;        bra     sents2
;        mov     #50,W0
;sents2: dec     W0,W0
;        bra     NZ,sents2
;        mov     SPI2BUF,W0  ;get response
;        mov     SPI2STAT,W0
        bset    LATB,#CS2   ;turn off CS
        rcall   byteo

        ;test SPI3 - CS3 - ADXL345 - 3-Axis Accelerometer

        rcall   comma	    ;send and received byte on SPI3
        bclr    LATC,#CS3   ;turn on CS
        mov     #0x00,W0    ;init command (WHO AM I)
        rcall   shft3
        rcall   shft3
;        mov     W0,SPI3BUF  ;output command
;        mov     SPI3BUF,W0  ;flush buffer
;        bclr    SPI3STAT,#SPIROV    ;clear overflow flag
;sents1: btss    SPI3STAT,#SPIRBF    ;wait for received character
;        bra     sents1
;        mov     #50,W0
;sents3: dec     W0,W0
;        bra     NZ,sents3
;        mov     W0,SPI3BUF  ;clock in response
;        mov     SPI3BUF,W0  ;flush buffer
;        bclr    SPI3STAT,#SPIROV    ;clear overflow flag
;sents2: btss    SPI3STAT,#SPIRBF    ;wait for received character
;        bra     sents2
;        mov     #50,W0
;sents4: dec     W0,W0
;        bra     NZ,sents4
;        mov     SPI3STAT,W0 ;get status
;        mov     SPI3BUF,W0  ;get response
        bset    LATC,#CS3   ;turn off CS
        rcall   byteo

        ;test SPI3 - CS4 - MAX21003 - Dual-Axis Gyroscope

        rcall   comma	    ;send and received byte on SPI3
        bclr    LATE,#CS4   ;turn on CS
        mov     #0xe0,W0    ;init command (WHO AM I)
        rcall   shft3
        rcall   shft3
;        mov     W0,SPI3BUF  ;output command
;        mov     SPI3BUF,W0  ;flush buffer
;        bclr    SPI3STAT,#SPIROV    ;clear overflow flag
;sents5: btss    SPI3STAT,#SPIRBF    ;wait for received character
;        bra     sents5
;        mov     #50,W0
;sents5: dec     W0,W0
;        bra     NZ,sents5
;        mov     W0,SPI3BUF  ;clock in response
;        mov     SPI3BUF,W0  ;flush buffer
;        bclr    SPI3STAT,#SPIROV    ;clear overflow flag
;sents6: btss    SPI3STAT,#SPIRBF    ;wait for received character
;        bra     sents6
;        mov     #50,W0
;sents6: dec     W0,W0
;        bra     NZ,sents6
;        mov     SPI3BUF,W0  ;get response
;        mov     SPI3STAT,W0 ;get status
        bset    LATE,#CS4   ;turn off CS
        rcall   byteo

    	btss	U1STA,#URXDA	;check if character is available
        bra     sents0	    ;if no, loop again
        mov	#tbloffset(sent11),w1   ;if yes, abort program
        rcall   mesag
        return

sent10:	.hword	0x0a0d
	.ascii	"Sensor Test"
	.hword	0x0a0d
        .ascii  "Encoder1,Encoder2,MPU6500,ADXL345,MAX21003"
	.hword	0x0a0d
        .asciz  " "

sent11:	.hword	0x0a0d
	.asciz	"Sensor Test Aborted"

;******************************************************************************
;Routine to test MAX21003

max2:	mov	#tbloffset(max210),w1
        rcall   mesag
max20:	mov.b	#0x0d,W0    ;cariage return
	rcall	ser1out
        bclr    LATE,#CS4   ;turn on CS
        mov     #0xe0,W0    ;init command (WHO AM I)
        rcall   shft3
        rcall   shft3
        bset    LATE,#CS4   ;turn off CS
        rcall   byteo

    	btss	U1STA,#URXDA	;check if character is available
        bra     max20       ;if no, loop again
        mov	#tbloffset(max211),w1   ;if yes, abort program
        rcall   mesag
        return
        ;
max210:	.hword	0x0a0d
	.ascii	"MAX21003 Test"
	.hword	0x0a0d
        .ascii  "x-gyro,y-gyro"
	.hword	0x0a0d
        .asciz  " "

max211:	.hword	0x0a0d
	.asciz	"MAX21003 Test Aborted"

;******************************************************************************
;Routine to test ADXL345

adx3:	mov	#tbloffset(adx310),w1
        rcall   mesag

;	mov     #0x2c0d,W0  ;init BW_RATE register
                            ;800Hz update rate
        mov     #0x2c0a,W0  ;init BW_RATE register
                            ;100Hz update rate
        bclr    LATC,#CS3
        rcall   shft3o
        bset    LATC,#CS3

        mov     #0x310b,W0  ;init DATA_FORMAT register
                            ;full resolution
                            ;+/-16g
        bclr    LATC,#CS3
        rcall   shft3o
        bset    LATC,#CS3

        mov     #0x2d08,W0  ;init POWER_CTL register
                            ;measurement mode
        bclr    LATC,#CS3
        rcall   shft3o
        bset    LATC,#CS3

adx30:	mov.b	#0x0d,W0    ;cariage return
	rcall	ser1out

        mov     #0xf2,W0    ;init command (X-Axis Data 0 and 1)
        bclr    LATC,#CS3   ;turn on CS
        rcall   shft3       ;shift out command
        rcall   shft3i      ;shift in 16 bits
        swap    W0          ;swap bytes
        mov     W0,W3       ;save X-Axis data in W3
        rcall   shft3i      ;shift in 16 bits
        swap    W0          ;swap bytes
        mov     W0,W4       ;save Y-Axis data in W4
        rcall   shft3i      ;shift in 16 bits
        swap    W0          ;swap bytes
        mov     W0,W5       ;save Z-Axis data in W5
        bset    LATC,#CS3   ;turn off CS
        mov     W3,W0       ;display X-Axis data
        rcall   wordo
        rcall   comma
        mov     W4,W0       ;display Y-Axis data
        rcall   wordo
        rcall   comma
        mov     W5,W0       ;display Z-Axis data
        rcall   wordo

    	btss	U1STA,#URXDA	;check if character is available
        bra     adx30       ;if no, loop again
        mov		#tbloffset(adx311),w1   ;if yes, abort program
        rcall   mesag
        return
        ;
adx310:	.hword	0x0a0d
	.ascii	"ADXL345 Test"
	.hword	0x0a0d
        .ascii  "x-acel,y-acel,z-acel"
	.hword	0x0a0d
        .asciz  " "

adx311:	.hword	0x0a0d
	.asciz	"ADXL345 Test Aborted"

;******************************************************************************
;Routine to test MPU-6500

mpu6:	mov	#tbloffset(mpu610),w1
        rcall   mesag
mpu60:	mov.b	#0x0d,W0    ;cariage return
	rcall	ser1out

        mov     #0xbb,W0    ;init command (ACCEL_XOUT_H)
        bclr    LATB,#CS2   ;turn on CS
        rcall   shft2       ;shift out command
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W3       ;save x-accel in W3
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W4       ;save y-accel in W4
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W5       ;save z-accel in W5
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W6       ;save temp in W6
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W7       ;save x-gyro in W7
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W8       ;save y-gyro in W8
        rcall   shft2i      ;shift in 16 bits
        mov     W0,W9       ;save z-gyro in W9
        bset    LATB,#CS2   ;turn off CS
        mov     W3,W0       ;display x-accel
        rcall   wordo
        rcall   comma
        mov     W4,W0       ;display y-accel
        rcall   wordo
        rcall   comma
        mov     W5,W0       ;display z-accel
        rcall   wordo
        rcall   comma
        mov     W6,W0       ;display temp
        rcall   wordo
        rcall   comma
        mov     W7,W0       ;display x-gyro
        rcall   wordo
        rcall   comma
        mov     W8,W0       ;display y-gyro
        rcall   wordo
        rcall   comma
        mov     W9,W0       ;display z-gyro
        rcall   wordo

    	btss	U1STA,#URXDA	;check if character is available
        bra     mpu60       ;if no, loop again
        mov	#tbloffset(mpu611),w1   ;if yes, abort program
        rcall   mesag
        return
        ;
mpu610:	.hword	0x0a0d
	.ascii	"MPU-6500 Test"
	.hword	0x0a0d
        .ascii  "x-acel,y-acel,z-acel,temp,x-gyro,y-gyro,z-gyro"
	.hword	0x0a0d
        .asciz  " "

mpu611:	.hword	0x0a0d
	.asciz	"MPU-6500 Test Aborted"

;******************************************************************************
;Routine to manually shift data on SPI2

shft2:  push    W2
        mov     #8,W2
shft20: btss    W0,#7	    ;set SDO2
        bclr    LATB,#4
        btsc    W0,#7
        bset    LATB,#4
        bclr    LATB,#7     ;SCK2 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATB,#7     ;SCK2 high
        btsc    PORTC,#2
        bset    W0,#0
        dec     W2,W2
        bra     NZ,shft20
        pop     W2
        return

;******************************************************************************
;Routine to manually shift 16 bits of data out on SPI2

shft2o: push    W2
        mov     #16,W2
shf2o0: btss    W0,#15       ;set SDO2
        bclr    LATB,#4
        btsc    W0,#15
        bset    LATB,#4
        bclr    LATB,#7     ;SCK2 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATB,#7     ;SCK2 high
        dec     W2,W2
        bra     NZ,shf2o0
        pop     W2
        return

;******************************************************************************
;Routine to manually shift 16 bits of data in on SPI2

shft2i: push    W2
        mov     #16,W2
shf2i0: bclr    LATB,#7     ;SCK2 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATB,#7     ;SCK2 high
        btsc    PORTC,#2
        bset    W0,#0
        dec     W2,W2
        bra     NZ,shf2i0
        pop     W2
        return

;******************************************************************************
;Routine to manually shift 8 bits of data out and in on SPI3

shft3:  push    W2
        mov     #8,W2
shft30: btss    W0,#7       ;set SDO3
        bclr    LATG,#6
        btsc    W0,#7
        bset    LATG,#6
        bclr    LATG,#8     ;SCK3 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATG,#8     ;SCK3 high
        btsc    PORTG,#7
        bset    W0,#0
        dec     W2,W2
        bra     NZ,shft30
        pop     W2
        return

;******************************************************************************
;Routine to manually shift 16 bits of data out on SPI3

shft3o: push    W2
        mov     #16,W2
shf3o0: btss    W0,#15	    ;set SDO3
        bclr    LATG,#6
        btsc    W0,#15
        bset    LATG,#6
        bclr    LATG,#8     ;SCK3 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATG,#8     ;SCK3 high
        dec     W2,W2
        bra     NZ,shf3o0
        pop     W2
        return

;******************************************************************************
;Routine to manually shift 16 bits of data in on SPI3

shft3i: push    W2
        mov     #16,W2
shf3i0: bclr    LATG,#8     ;SCK3 low
        rlnc    W0,W0       ;shift to next bit
        bclr    W0,#0
        bset    LATG,#8     ;SCK3 high
        btsc    PORTG,#7
        bset    W0,#0
        dec     W2,W2
        bra     NZ,shf3i0
        pop     W2
        return

;******************************************************************************
;Routine to toggle red/green LEDs

tled:	mov	#tbloffset(tled2),w1
	rcall	mesag
	btss	LATC,#LEDG  ;check if LEDs are off
	bra	tled0
	btss	LATB,#LEDR
	bra	tled0
	bclr	LATC,#LEDG
        return
        ;
tled0: 	btg	LATC,#LEDG
	btg	LATB,#LEDR
	return

tled2:	.hword	0x0a0d
	.asciz	"Toggle LEDs"

;******************************************************************************
;Routine to blink red and greed LEDs

blink:	mov	#10,W1	    ;init loop counters
	clr	W0
blink0:	bclr	LATB,#LEDR  ;turn on red LED
	rcall	blink1
	bset	LATB,#LEDR  ;turn off red LED
	bclr	LATC,#LEDG  ;turn on green LED
	rcall	blink1
	bset	LATC,#LEDG  ;turn off green LED
	dec	W1,W1
	bra	NZ,blink0
	return
	;
blink1:	rcall	blink2
	rcall	blink2
	rcall	blink2
blink2:	dec	W0,W0
	bra	NZ,blink2
	return

;******************************************************************************
;Routine to display version number of firmware

ver:	mov	#tbloffset(ver0),w1
	bra	mesag

ver0:	.hword	0x0a0d
	.hword	0x070d	    ;bell character
	.ascii  "       Jehu 3"
	.hword	0x0a0d
	.ascii	"     Version 0.1"
	.hword	0x0a0d
	.ascii	"      14.7 MIPS"
	.hword	0x0a0d
	.asciz	"   November 21, 2015"

;******************************************************************************
;Drive motor control routine
; Forward error compensator
; forward servo ba dwith = 110 r/s
; mass = 0.1000 kg
; DC gain = 0.302
; K1 = 1.572
; K2 = 1.507
; K3 = 0.786
; new_ouput = K1 * new_error + K2 * old_error + K3 * old_ouput
;		.equ K1,6342
;		.equ K2,6082
;		.equ K3,51557

dmctrl:	mov	FWDOUT,W4   ;KS3 * old output
	mov	#KS3,W5
	mpy	W4*W5,A
	sftac	A,#7	    ;divide result by 128
	mov	FWDERO,W4   ;KS2 * old error
	mov	#KS2,W5
	msc	W4*W5,A
	mov	FWDERN,W4   ;KS1 * new error
	mov	W4,FWDERO   ;age error
	mov	#KS1,W5
	mac	W4*W5,A
	sac.r	A,#-7,W0    ;save new output
	mov	W0,FWDOUT
	return

;******************************************************************************
;Motor Drive Routine
; uses FWDVEL and ROTVEL to update the motor pulse width
	;
	;left motor
	;
mtrdrv:	mov	ROTVEL,W0   ;get rotational velocity
	sl	W0,#4,W0    ;multiply by 16
	add	FWDOUT,WREG ;add forward output
	mov	BATCOR,W1   ;correct for battery voltage
	mul.su	W0,W1,W0
	mov	W1,W0
	bra	N,mtrdr0    ;if negative, skip down
	mov	#255,W1	    ;if positive, check if > 255
	cpsgt	W1,W0	    ;if no, skip down
	mov	#255,W0	    ;if yes, limit to 255
	mov	W0,PDC2	    ;output to PWM
	clr	PDC4
	bra	mtrdr1	    ;skip down
	;
mtrdr0:	neg	W0,W0	    ;take 2's complment of pulse width
	mov	#255,W1	    ;check if > 255
	cpsgt	W1,W0	    ;if no, skip down
	mov	#255,W0	    ;if yes, limit to 255
	mov	W0,PDC4	    ;output to PWM
	clr	PDC2
	;
	;right motor
	;
mtrdr1:	mov	ROTVEL,W0   ;get rotational velocity
	sl	W0,#4,W0    ;multiply by 16
	sub	FWDOUT,WREG ;subtract forward velocity
	mov	BATCOR,W1   ;correct for battery voltage
	mul.su	W0,W1,W0
	mov	W1,W0
	bra	N,mtrdr2    ;if negative, skip down
	mov	#255,W1	    ;if positive, check if > 255
	cpsgt	W1,W0	    ;if no, skip down
	mov	#255,W0	    ;if yes, limit to 255
	mov	W0,PDC6	    ;output to PWM
	clr	PDC5
	return
	;
mtrdr2:	neg	W0,W0	    ;take 2's complement of pulse width
	mov	#255,W1	    ;check if > 255
	cpsgt	W1,W0	    ;if no, skip down
	mov	#255,W0	    ;if yes, limit to 255
	mov	W0,PDC5	    ;output to PWM
	clr	PDC6
	return

;******************************************************************************
;Hysteresis subroutine to debounce switch inputs
; Takes a switch positon in the Z flag and a pointer to a debounce counter
; in W1 and returns with the status as shown below
;
; C flag = 0 old switch position
; C flag = 1 new switch position
; Z flag = 0 switch closed
; Z flag = 1 switch open
; counter = 0-7 switch open
; counter = 8-f switch closed
;***** the Z flag is not working correctly yet ***** 10/17/2012

hyst:	bra	Z,hyst3	    ;if switch is open, skip down
	;
	; Switch is closed, check what it was
	;
	btsc	[W1],#2	    ;check if switch was closed
	bra	hyst0	    ;if yes, skip down
	inc	[W1],[W1]   ;if no, increment counter
	btss	[W1],#2	    ;check if switch is closed now
	bra	hyst6	    ;if no, skip down
	bset	SR,#C	    ;if yes, set new position flag
	bra	hyst1	    ;skip down
		;
hyst0:	bclr	SR,#C	    ;clear new switch position flag
hyst1:	bclr	SR,#Z	    ;set switch closed flag
	mov	#0x0007,W0  ;clear any counts so far
	mov	W0,[W1]
	return
		;
hyst2:	bclr	SR,#C	    ;clear new switch position flag
	bclr	SR,#Z	    ;switch is still closed
	return
	;
	; Switch is open, check what it was
	;
hyst3:	btss	[W1],#2	    ;check if switch was open
	bra	hyst4	    ;if yes, skip down
	dec	[W1],[W1]   ;if no, decrement counter
	btsc	[W1],#2	    ;check if switch is open now
	bra	hyst2	    ;if no, skip down
	bset	SR,#C	    ;if yes, set new position flag
	bra	hyst5	    ;skip down
	;
hyst4:	bclr	SR,#C	    ;clear new switch position flag
hyst5:	bset	SR,#Z	    ;set switch open flag
	clr	[W1]	    ;clear any counts so far
	return
		;
hyst6:	bclr	SR,#C	    ;clear new switch position flag
	bset	SR,#Z	    ;switch is still open
	return

;******************************************************************************
;Routine to delay for 1 second

second: mov     #1000,W0    ;init loop counter
secon0: btss	IFS0,#T1IF  ;check if Timer 1 timed out
	bra	secon0	    ;if no, loop again
	bclr	IFS0,#T1IF  ;if yes, clear Timer 1 interrupt flag
        dec     W0,W0       ;decrement counter
        bra     NZ,secon0   ;loop until zero
        return

;******************************************************************************
;ASCII to binary input routine
; CY = 0 no new data (CR)
; CY = 1 new data
; W2 = result
; W6 = last character

ascbin:	push.d	W0	    ;save registers
	push	W3
	clr	W2	    ;clear result
	clr	W1	    ;clear flags
ascbi0:	rcall	ser1in	    ;get next character
	mov	W0,W6	    ;save character
	mov.b	#'-',W1	    ;check if minus ser1ingn
	cpsne.b	W0,W1
	bra	ascbi2	    ;if yes, skip down
	mov.b	#0x0d,W1    ;if no, check if CR
	cpsne.b	W0,W1
	bra	ascbi3	    ;if yes, skip down
	mov.b	#0x1b,W1    ;if no, check if ESC
	cpsne.b	W0,W1
	bra	ascbi3	    ;if yes, skip down
	rcall	number	    ;if no, check if number
	bra	C,ascbi0    ;if no, loop again
	rcall	ser1out	    ;if yes, echo digit
	mul.uu	W2,#10,W2   ;multiply existing number by 10
	and	W0,#0x0f,W0 ;mask new digit
	add	W0,W2,W2    ;add to total
	bset	W1,#9	    ;set new data flag
	bra	ascbi0	    ;loop for next digit
		;
ascbi2:	rcall	ser1out	    ;echo minus sign
	bset	W1,#8	    ;set negative flag
	bra	ascbi0	    ;loop for next digit
		;
ascbi3:	btsc	W1,#8	    ;check sign
	neg	W2,W2	    ;if negative, take 2's complement
	btst.c	W1,#9	    ;set new data flag
	pop	W3	    ;restore registers
	pop.d	W0
	return		    ;return

;******************************************************************************
;Binary to ASCII output routine
; Converts a binary word in reg W0 to decimal
; and outputs it on the serial port

binasc:	push.d	W0	    ;save registers
	push.d	W2
	mov	W0,W1	    ;move number to W1
	mov	#10000,W2   ;calculate 10,000 digit
	rcall	binas0
	mov	#1000,W2    ;calculate 1,000 digit
	rcall	binas0
	mov	#100,W2	    ;calculate 100 digit
	rcall	binas0
	mov	#10,W2	    ;calculate 10 digit
	rcall	binas0
	mov	#1,W2	    ;calculate 1 digit
	rcall	binas0
	pop.d	W2	    ;restore registers
	pop.d	W0
	return		    ;return
		;
binas0:	mov.b	#'0'-1,W0   ;init digit
binas1:	inc	W0,W0	    ;increment digit
	sub	W1,W2,W1    ;subtract digit value
	bra	C,binas1    ;if no underflow, loop again
	add	W1,W2,W1    ;if yes, add extra subtraction
	call	ser1out	    ;display digit
	return		    ;return

;******************************************************************************
;Subroutine to check for ASCII number (0-9)
; return with CY cleared if it is a valid number

number:	add.b	#0xc6,W0    ;check if number is > 9
	bra	C,numbe0    ;bc		numbe0		;if yes, skip down
	add.b	#0x0a,W0    ;if no, check if < 0
	bra	NC,numbe1   ;bnc		numbe1		;if yes, skip down
	add.b	#0x30,W0    ;if no, return to original number
	return		    ;return
		;
numbe0:	add.b	#0x3a,W0    ;return to original number
	bset	SR,#C	    ;set error flag
	return		    ;return
		;
numbe1:	add.b	#0x30,W0    ;return to original number
	bset	SR,#C	    ;set error flag
	return		    ;return

;******************************************************************************
;Convert to upper case if required

caps:	add.b	#0x85,W0    ;check if > 'z'
	bra	C,caps0	    ;bc		caps0		;if yes, skip down
	add.b	#0x1a,W0    ;if no, check if < 'a'
	bra	NC,caps1    ;bnc		caps1		;if yes, skip down
	add.b	#0x41,W0    ;if no, convert to upper case
	return
		;
caps0:	add.b	#0x7b,W0    ;return to original value
	return
		;
caps1:	add.b	#0x61,W0    ;return to original value
	return

;******************************************************************************
;Hexadecimal output routine
; Converts a binary word in reg W0 to hexadecimal
; and outputs it on the serial port

wordo:	push	W0
	swap	W0
	rcall	byteo
	pop	W0
	bra	byteo

;******************************************************************************
;Hexadecimal output routine
; Converts a binary byte in reg W0 to hexadecimal
; and outputs it on the serial port

byteo:	push	W0
	swap.b	W0
	rcall	niblo
	pop	W0
	bra	niblo

;******************************************************************************
;Hexadecimal output routine
; Converts a binary nible in reg W0 to hexadecimal
; and outputs it on the serial port

niblo:	and.b	#0x0f,W0    ;mask low nible
	add.b	#0xf6,W0    ;check if number > 9
	bra	nc,nibou0   ;if no, skip down
	add.b	#0x07,W0    ;if yes, add offset
nibou0:	add.b	#0x3a,W0    ;convert to ASCII
	bra	ser1out	    ;output to serial port

;******************************************************************************
;Subroutine to output message on serial ouptut

mesag:	rcall	crlf	    ;skip to new line
mesag0:	tblrdl.b [W1++],W0  ;get next character
        cp0.b   W0	    ;check if terminator
        bra     Z,mesag1    ;if yes, skip down
	rcall	ser1out	    ;if no, display character
	bra	mesag0	    ;loop for next character
        ;
mesag1: return

;******************************************************************************
;Subroutine to ouput comma on serial port

comma:	mov.b	#',',W0
	bra	ser1out

;******************************************************************************
;Subroutine to ouput CRLF on serial port

crlf:	mov.b	#0x0d,W0    ;cariage return
	rcall	ser1out
	mov.b	#0x0a,W0    ;line feed
	bra	ser1out

;******************************************************************************
;Serial 1 input routine
; Returns with a character from the asynchrounous serial port in the W reg

si:
ser1in:	btsc	U1STA,#URXDA	;check if character is available
	bra	ser1i0	    ;if yes, skip down
        btss    U1STA,#OERR ;if no, check if overrun error
        bra     ser1in	    ;if no, loop again
        bclr    U1STA,#OERR ;if yes, clear error
        bra     ser1in	    ;loop again
		;
ser1i0:	mov	U1RXREG,W0  ;get character
	return

;******************************************************************************
;Serial 1 output routine
; Outputs a character in the W0 reg to the asynchrounous serial port

so:
ser1out:
        btss	U1STA,#TRMT ;check if transmitter shift register is empty
	bra	ser1out	    ;if no, loop until free
	mov	W0,U1TXREG  ;if yes, output character to transmitter
	return

;******************************************************************************
;Erase one pagae of data (512 instructions) in flash
; and write one row of data (64 instrucitons) to flash
; The registers that specify the location of the RAM buffer with the data
; and the target location of the data in flash have already been initialized
; ***** This routine should probalby be split into two subroutines - 
; ***** one to erase a page of flash and one to write a row

flashwr:
	;
	;erase page (8 rows of instructions = 512 instructions)
	;
	push	SR	    ;disable interrupts while the KEY sequence is written
	mov	#0x00e0,W0
	ior 	SR
	mov 	#0x4003,W0  ;init NVMCON to erase one page of Flash program memory
	mov 	W0,NVMCON
	mov 	#0x55,W0    ;write the KEY sequence
	mov 	W0,NVMKEY
	mov 	#0xAA,W0
	mov 	W0,NVMKEY
	bset 	NVMCON,#WR  ;start the erase cycle
	nop
	nop
flshw0:	btsc	NVMCON,#WR  ;wait until erase is finished
	bra	flshw0
	mov	NVMCON,W2   ;save error flag
;	pop	SR	    ;*****
;	return		    ;*****
	;
	;write row
	;
	mov	#0x4002,W0  ;init NVMCON to write one row of Flash program memory
	mov	W0,NVMCON
	mov	#0x55,W0    ;write the key sequence
	mov	W0,NVMKEY
	mov	#0xAA,W0
	mov	W0,NVMKEY
	bset	NVMCON,#WR  ;start the write cycle
	nop
	nop
flshw1:	btsc	NVMCON,#WR  ;wait until write is finished
	bra	flshw1
	pop	SR	    ;renable interrupts
	
;	rcall	crlf
;	mov	#'E',W0
;	rcall	so
;	mov	W2,W0
;	rcall	wordo
;	mov	NVMCON,W0   ;dispaly error
;	rcall	wordo
	return

;******************************************************************************
;Subroutine to set up write file in external RAM
; W2:W3 = starting address

wrfile: btss    SPI1STAT,#SRMPT	;make sure SR is empty
        bra     wrfile	    ;if not, wait for it
        bset    LATC,#CS1   ;make sure CS is off
        bclr    LATC,#CS1   ;turn on CS
        mov     #0x0600,W0  ;init for WREN opcode
	mov	W0,SPI1BUF  ;clock out opcode
wrfil0: btss    SPI1STAT,#SRMPT	;wait for transmission to finish
        bra     wrfil0
        and     #0x00ff,W2  ;set up WRITE opcode
        ior     #0x0200,W2
        bset    LATC,#CS1   ;turn off CS
        bclr    LATC,#CS1   ;turn on CS
        mov     W2,SPI1BUF  ;output opcode and high byte of address
        mov     W3,SPI1BUF  ;output low word of address
        clr     FILSIZ      ;clear file size
        clr     FILSIZ+2
        return

;******************************************************************************
;Subroutine to set up read file in external RAM
; W2:W3 = starting address

rdfile: and     #0x00ff,W2  ;set up READ opcode
        ior     #0x0300,W2
rdfil0: btss    SPI1STAT,#SRMPT ;make sure SR is empty
        bra     rdfil0      ;if not, wait for it
        bset    LATC,#CS1   ;make sure CS is off
        bclr    LATC,#CS1   ;turn on CS
        mov     W2,SPI1BUF  ;output opcode and high byte of address
        mov     W3,SPI1BUF  ;output low word of address
        clr     FILSIZ      ;clear file size
        clr     FILSIZ+2
rdfil1: mov     SPI1BUF,W0  ;flush word from RX FIFO
        btss    SPI1STAT,#SRMPT ;wait for SR to empty
        bra     rdfil1
        btss    SPI1STAT,#SRXMPT    ;check if RX FIFO is empty
        bra     rdfil1      ;if no, loop again
	bclr	SPI1STAT,#SPIROV    ;clear receive overflow flag bit
        clr     SPI1BUF	    ;fill buffer with first 8 words
        clr     SPI1BUF
        clr     SPI1BUF
        clr     SPI1BUF
        clr     SPI1BUF
        clr     SPI1BUF
        clr     SPI1BUF
        clr     SPI1BUF
        return

;******************************************************************************
;External RAM read routine
; W0 = data word from RAM
; FILSIZ = FILSIZ + 1

ramrd:  btsc    SPI1STAT,#SPITBF    ;check if space in transmit buffer
        bra     ramrd	    ;if no, wait for space in buffer
    	clr     SPI1BUF	    ;if yes, clock in data word
	inc     FILSIZ	    ;increment file size counter
        btsc    SR,#Z
        inc     FILSIZ+2
ramrd0: btsc    SPI1STAT,#SRXMPT    ;wait for new word in RX FIFO
        bra     ramrd0
	mov	SPI1BUF,W0  ;get word from buffer
	return

;******************************************************************************
;External RAM write routine
; W0 = data word to be written to external RAM
; FILSIZ = FILSIZ + 1

ramwr:  btsc    SPI1STAT,#SPITBF    ;check if space in transmit buffer
        bra     ramwr	    ;if no, wait for space in buffer
    	mov	W0,SPI1BUF  ;if yes, output data word to buffer
	inc	FILSIZ	    ;increment file size counter
        btsc    SR,#Z
        inc     FILSIZ+2
		return

;******************************************************************************
;EEPROM read routine
; W1 = address of word
; W0 = data from word

eerd:
;	mov	#tblpage(defpar),W0 ;init table page
;	mov	W0,TBLPAG
	tblrdl	[W1],W0	    ;read the EEPROM data
;	clr	TBLPAG	    ;reset table page to default value
	return

;******************************************************************************
;EEPROM write routine
; W1 = address of word
; W2 = data to write to word
	;
	;erase old word first
	;
eewr:
	return
	
	mov	#0x7f,W0
	mov 	W0,NVMADRU
	mov 	W1,NVMADR
	mov 	#0x4044,W0  ;init NVMCON to erase one word of data EEPROM
	mov 	W0,NVMCON
	push	SR	    ;disable interrupts while the KEY sequence is written
	mov	#0x00e0,W0
	ior 	SR
	mov 	#0x55,W0    ;write the KEY sequence
	mov 	W0,NVMKEY
	mov 	#0xAA,W0
	mov 	W0,NVMKEY
	bset 	NVMCON,#WR  ;start the erase cycle
	nop
	nop
eewr0:	btsc	NVMCON,#WR  ;check if erase is finished
	bra	eewr0	    ;loop until done
	;
	;write new word
	;
	mov	#0x7f,W0
	mov	W0,TBLPAG
	tblwtl	W2,[W1]	    ;write data value to holding latch
			    ;NVMADR captures write address from the TBLWTL instruction
	mov	#0x4004,W0  ;init NVMCON for programming one word to data EEPROM
	mov	W0,NVMCON
	mov	#0x55,W0    ;write the key sequence
	mov	W0,NVMKEY
	mov	#0xAA,W0
	mov	W0,NVMKEY
	bset	NVMCON,#WR  ;start the write cycle
	nop
	nop
eewr1:	btsc	NVMCON,#WR  ;check if write is finished
	bra	eewr1	    ;loop until done
	pop	SR	    ;renable interrupts
	clr	TBLPAG	    ;reset table page to default value
	return

;..............................................................................
;Timer 1 Interrupt Service Routine
;Example context save/restore in the ISR performed using PUSH.D/POP.D
;instruction. The instruction pushes two words W4 and W5 on to the stack on
;entry into ISR and pops the two words back into W4 and W5 on exit from the ISR
;..............................................................................

;__T1Interrupt:
;        PUSH.D W4	    ;Save context using double-word PUSH

        ;<<insert user code here>>

;        BCLR IFS0, #T1IF    ;Clear the Timer1 Interrupt flag Status bit
;        POP.D W4	    ;Retrieve context POP-ping from Stack
;        RETFIE		    ;Return from Interrupt Service routine

;******************************************************************************
;Track Data

home_track:		    ;Practice track from home
	.hword	0x057E,0x4FC1,0x0000,0x0067,0x0000
	.hword	0x044C,0x44BB,0x0000,0x0ABF,0x0000
	.hword	0x05F2,0x5F21,0x0000,0x0115,0x0000
	.hword	0x0865,0x8650,0x0000,0x163E,0x0000
	.hword	0x04BB,0x4BB4,0x0000,0xF59E,0xFFFF
	.hword	0x02A2,0x2A1A,0x0000,0xFD9E,0xFFFF
	.hword	0x05F5,0x5F52,0x0000,0x0194,0x0000
	.hword	0x0704,0x7044,0x0000,0x0A32,0x0000
	.hword	0x0382,0x381F,0x0000,0xEB73,0xFFFF
	.hword	0x091F,0x91ED,0x0000,0xFE63,0xFFFF
	.hword	0x01FB,0x1FAF,0x0000,0xF5C3,0xFFFF
	.hword	0x03CA,0x3CA5,0x0000,0xF56D,0xFFFF
	.hword	0x06E5,0x6E4E,0x0000,0x14AC,0x0000
	.hword	0x012C,0x12BF,0x0000,0x0045,0x0000
	.hword	0x0219,0x2192,0x0000,0xF650,0xFFFF
	.hword	0x04D6,0x4D60,0x0000,0xF3F4,0xFFFF
	.hword	0x02BA,0x2B9D,0x0000,0xFEF1,0xFFFF
	.hword	0x02DF,0x2DEF,0x0000,0x0121,0x0000
	.hword	0x0456,0x4564,0x0000,0x0AD2,0x0000
	.hword	0x0583,0x5830,0x0000,0x0108,0x0000
	.hword	0x044C,0x44BF,0x0000,0x0ABD,0x0000
	.hword	0x0365,0xA4DC,0x0000,0x00C2,0x0000
	.hword	0x0000

taiwan_2013:
	.hword	0x10C3,0x8550,0x0002,0xFFB6,0xFFFF	;1
	.hword	0x020C,0x51D9,0x0000,0xDD33,0xFFFF
	.hword	0x0209,0x5161,0x0000,0x26EB,0x0000
	.hword	0x0315,0x7B53,0x0000,0xDC21,0xFFFF
	.hword	0x0198,0x3FBF,0x0000,0x1369,0x0000
	.hword	0x0171,0x39A9,0x0000,0x010F,0x0000
	.hword	0x0209,0x5169,0x0000,0xFAE5,0xFFFF
	.hword	0x159A,0x6011,0x0003,0xFF27,0xFFFF
	.hword	0x0333,0x7FF6,0x0000,0xD752,0xFFFF
	.hword	0x04D6,0xC174,0x0000,0x24BA,0x0000	;10
	.hword	0x14A2,0x394B,0x0003,0xDDB7,0xFFFF
	.hword	0x060F,0xF25F,0x0000,0xDE43,0xFFFF
	.hword	0x0819,0x43E6,0x0001,0x1754,0x0000
	.hword	0x0606,0xF0EC,0x0000,0x219E,0x0000
	.hword	0x06AA,0x0A92,0x0001,0xD50C,0xFFFF
	.hword	0x064E,0xFC2D,0x0000,0x1A25,0x0000
	.hword	0x0599,0xDFEE,0x0000,0x0034,0x0000
	.hword	0x04A4,0xB9A1,0x0000,0xFCBD,0xFFFF
	.hword	0x029B,0x6836,0x0000,0x0088,0x0000
	.hword	0x09AA,0x8283,0x0001,0x16C3,0x0000	;20
	.hword	0x0193,0x3EF9,0x0000,0x1E45,0x0000
	.hword	0x07C7,0x3727,0x0001,0xEEAB,0xFFFF
	.hword	0x0797,0x2F94,0x0001,0xFFA0,0xFFFF
	.hword	0x0100,0x27FD,0x0000,0xFC5B,0xFFFF
	.hword	0x009A,0x180F,0x0000,0xF675,0xFFFF
	.hword	0x0565,0xD7CE,0x0000,0xFFA4,0xFFFF
	.hword	0x0173,0x39F4,0x0000,0xFEE6,0xFFFF
	.hword	0x02E4,0x73A1,0x0000,0x0219,0x0000
	.hword	0x0174,0x3A20,0x0000,0xFF36,0xFFFF
	.hword	0x057E,0xDBB6,0x0000,0xFF50,0xFFFF	;30
	.hword	0x01B1,0x439E,0x0000,0xDFDA,0xFFFF
	.hword	0x022F,0x575D,0x0000,0xFF49,0xFFFF
	.hword	0x00F3,0x25F8,0x0000,0x0182,0x0000
	.hword	0x01F1,0x4DA8,0x0000,0xFCDA,0xFFFF
	.hword	0x00F4,0x261C,0x0000,0x015C,0x0000
	.hword	0x00D5,0x2149,0x0000,0x006D,0x0000
	.hword	0x00F6,0x2672,0x0000,0x0182,0x0000
	.hword	0x01EF,0x4D58,0x0000,0xFC84,0xFFFF
	.hword	0x00F4,0x261F,0x0000,0x018D,0x0000
	.hword	0x036D,0x8907,0x0000,0x0361,0x0000	;40
	.hword	0x0187,0x3D11,0x0000,0x1D45,0x0000
	.hword	0x00BF,0x1DD9,0x0000,0xFF7D,0xFFFF
	.hword	0x0067,0x1021,0x0000,0x0599,0x0000
	.hword	0x00C2,0x1E46,0x0000,0xFAA0,0xFFFF
	.hword	0x0060,0x0F02,0x0000,0x0560,0x0000
	.hword	0x00C1,0x1E27,0x0000,0xFA93,0xFFFF
	.hword	0x0064,0x0FA5,0x0000,0x0577,0x0000
	.hword	0x00C1,0x1E22,0x0000,0xFAB6,0xFFFF
	.hword	0x0061,0x0F29,0x0000,0x05CB,0x0000
	.hword	0x00A8,0x1A4B,0x0000,0xFC8B,0xFFFF	;50
	.hword	0x0112,0x2ACF,0x0000,0xFEC5,0xFFFF
	.hword	0x00B5,0x1C41,0x0000,0xFEAB,0xFFFF
	.hword	0x0060,0x0F05,0x0000,0x0589,0x0000
	.hword	0x00C4,0x1E9B,0x0000,0xFA75,0xFFFF
	.hword	0x0061,0x0F27,0x0000,0x0549,0x0000
	.hword	0x00C6,0x1EEC,0x0000,0xFAB2,0xFFFF
	.hword	0x005C,0x0E62,0x0000,0x04F8,0x0000
	.hword	0x00C1,0x1E28,0x0000,0xFA84,0xFFFF
	.hword	0x0067,0x1019,0x0000,0x05ED,0x0000
	.hword	0x00A5,0x19D4,0x0000,0xFC82,0xFFFF	;60
	.hword	0x0229,0x5663,0x0000,0xFEF3,0xFFFF
	.hword	0x02B0,0x6B7F,0x0000,0xE699,0xFFFF
	.hword	0x016C,0x38E2,0x0000,0xFF80,0xFFFF
	.hword	0x07C7,0x3718,0x0001,0x005C,0x0000
	.hword	0x0354,0x851E,0x0000,0x0030,0x0000
	.hword	0x01B7,0x4496,0x0000,0xFEEC,0xFFFF
	.hword	0x00E3,0x2373,0x0000,0xF0A9,0xFFFF
	.hword	0x02C2,0x6E54,0x0000,0x0012,0x0000
	.hword	0x01AC,0x42E3,0x0000,0x0F37,0x0000
	.hword	0x045F,0xAED8,0x0000,0xDEA8,0xFFFF	;70
	.hword	0x023E,0x59B1,0x0000,0x0D61,0x0000
	.hword	0x013E,0x31AF,0x0000,0xF825,0xFFFF
	.hword	0x01FC,0x4F64,0x0000,0xFED4,0xFFFF
	.hword	0x0499,0xB7E4,0x0000,0xD4AC,0xFFFF
	.hword	0x050D,0xCA03,0x0000,0x3067,0x0000
	.hword	0x01FC,0x4F64,0x0000,0xDA82,0xFFFF
	.hword	0x01FA,0x4F10,0x0000,0x01D2,0x0000
	.hword	0x006D,0x10FE,0x0000,0x078A,0x0000
	.hword	0x04A7,0xBA28,0x0000,0x0154,0x0000
	.hword	0x015B,0x3638,0x0000,0x0070,0x0000	;80
	.hword	0x052A,0xCE85,0x0000,0x215D,0x0000
	.hword	0x018B,0x3DC5,0x0000,0x00ED,0x0000
	.hword	0x0727,0x1E15,0x0001,0xFF25,0xFFFF
	.hword	0x01AE,0x4327,0x0000,0xDFA7,0xFFFF
	.hword	0x057D,0xDB86,0x0000,0x026C,0x0000
	.hword	0x017E,0x3BB2,0x0000,0x1CC0,0x0000
	.hword	0x00C0,0x1E00,0x0000,0xFAA0,0xFFFF
	.hword	0x00F8,0x26BF,0x0000,0x10A5,0x0000
	.hword	0x00AA,0x1A90,0x0000,0xF7B4,0xFFFF
;taiwan_2013:
	.hword	0x0159,0x35F1,0x0000,0xFEAD,0xFFFF	;90
	.hword	0x0309,0x7965,0x0000,0xDAD3,0xFFFF
	.hword	0x0108,0x2940,0x0000,0x08A0,0x0000
	.hword	0x014F,0x345A,0x0000,0xF8F4,0xFFFF
	.hword	0x037A,0x8B0D,0x0000,0x21B3,0x0000
	.hword	0x0298,0x67C1,0x0000,0xE007,0xFFFF
	.hword	0x01E8,0x4C46,0x0000,0xFF9A,0xFFFF
	.hword	0x00E4,0x23A0,0x0000,0x006C,0x0000
	.hword	0x0161,0x372A,0x0000,0x08F2,0x0000
	.hword	0x0170,0x3979,0x0000,0xE5E5,0xFFFF
	.hword	0x00CC,0x1FE2,0x0000,0xFE54,0xFFFF	;100
	.hword	0x00E0,0x22F3,0x0000,0xFCA1,0xFFFF
	.hword	0x005C,0x0E61,0x0000,0x05A9,0x0000
	.hword	0x00C9,0x1F6C,0x0000,0xFAD6,0xFFFF
	.hword	0x0060,0x0F00,0x0000,0x0524,0x0000
	.hword	0x00B2,0x1BD1,0x0000,0xF869,0xFFFF
	.hword	0x00B1,0x1BA8,0x0000,0x0526,0x0000
	.hword	0x012D,0x2F07,0x0000,0x024B,0x0000
	.hword	0x0273,0x61F7,0x0000,0x1F9B,0x0000
	.hword	0x0246,0x5AFB,0x0000,0x00BF,0x0000
	.hword	0x02FB,0x7735,0x0000,0xE8B1,0xFFFF	;110
	.hword	0x0135,0x304A,0x0000,0xFE3C,0xFFFF
	.hword	0x0218,0x53B7,0x0000,0xDD7D,0xFFFF
	.hword	0x0206,0x50E3,0x0000,0x2849,0x0000
	.hword	0x025B,0x5E46,0x0000,0xDE14,0xFFFF
	.hword	0x01C5,0x46BE,0x0000,0x229A,0x0000
	.hword	0x01F9,0x4EF6,0x0000,0x02C8,0x0000
	.hword	0x0130,0x2F86,0x0000,0x0854,0x0000
	.hword	0x0396,0x8F67,0x0000,0xDE8F,0xFFFF
	.hword	0x0567,0x46AA,0x0001,0xFF7A,0xFFFF
	.hword	0x0000					;120

japan_2013a:				;Practice maze from TST298
	.hword	0x081A,0x2AE3,0x0001,0xFFCD,0xFFFF
	.hword	0x01B3,0x43F5,0x0000,0xEFCD,0xFFFF
	.hword	0x028E,0x6633,0x0000,0x0009,0x0000
	.hword	0x0124,0x2DA1,0x0000,0xFFE3,0xFFFF
	.hword	0x0118,0x2BC1,0x0000,0x0019,0x0000
	.hword	0x011B,0x2C37,0x0000,0xFFF7,0xFFFF
	.hword	0x011B,0x2C36,0x0000,0xFFFA,0xFFFF
	.hword	0x0222,0x5552,0x0000,0xFF60,0xFFFF
	.hword	0x0316,0x7B74,0x0000,0xF008,0xFFFF
	.hword	0x04A0,0xB8FC,0x0000,0xFEC0,0xFFFF
	.hword	0x027E,0x63B2,0x0000,0xDFDC,0xFFFF
	.hword	0x047D,0xB388,0x0000,0x023A,0x0000
	.hword	0x01B8,0x44BC,0x0000,0x1F28,0x0000
	.hword	0x0105,0x28C8,0x0000,0xFF64,0xFFFF
	.hword	0x00E2,0x2349,0x0000,0xF1AB,0xFFFF
	.hword	0x0428,0xA64A,0x0000,0xFFE8,0xFFFF
	.hword	0x0299,0x67E5,0x0000,0x20A3,0x0000
	.hword	0x035D,0x868B,0x0000,0x0055,0x0000
	.hword	0x01BD,0x4588,0x0000,0xEFE6,0xFFFF
	.hword	0x0364,0x87A5,0x0000,0x0F65,0x0000
	.hword	0x0152,0x34C9,0x0000,0xF099,0xFFFF
	.hword	0x0119,0x2BEE,0x0000,0xFEBA,0xFFFF
	.hword	0x014A,0x338A,0x0000,0xF03E,0xFFFF
	.hword	0x0351,0x84A6,0x0000,0xFFEA,0xFFFF
	.hword	0x0357,0x859B,0x0000,0x002D,0x0000
	.hword	0x041B,0xA437,0x0000,0xFF1B,0xFFFF
	.hword	0x00E0,0x22F7,0x0000,0xF0F5,0xFFFF
	.hword	0x0255,0xCBE0,0x0000,0x0038,0x0000
	.hword	0x0000

japan_2013b:				;Practice maze from TST300
	.hword	0x081E,0x2B82,0x0001,0x0000,0x0000
	.hword	0x01B2,0x43D2,0x0000,0xEFD8,0xFFFF
	.hword	0x028F,0x665B,0x0000,0xFFFD,0xFFFF
	.hword	0x0123,0x2D76,0x0000,0xFFE0,0xFFFF
	.hword	0x0118,0x2BB9,0x0000,0x0003,0x0000
	.hword	0x011A,0x2C18,0x0000,0xFFF4,0xFFFF
	.hword	0x011C,0x2C5E,0x0000,0xFFFA,0xFFFF
	.hword	0x0223,0x557B,0x0000,0xFF47,0xFFFF
	.hword	0x0315,0x7B48,0x0000,0xF010,0xFFFF
	.hword	0x04A1,0xB922,0x0000,0xFEC6,0xFFFF
	.hword	0x027F,0x63D9,0x0000,0xE013,0xFFFF
	.hword	0x0480,0xB407,0x0000,0x0299,0x0000
	.hword	0x01DC,0x4A51,0x0000,0x200B,0x0000
	.hword	0x00FC,0x2768,0x0000,0xFE84,0xFFFF
	.hword	0x00DE,0x22AC,0x0000,0xF1A2,0xFFFF
	.hword	0x0430,0xA789,0x0000,0x0123,0x0000
	.hword	0x029B,0x6833,0x0000,0x208F,0x0000
	.hword	0x035B,0x863D,0x0000,0x0037,0x0000
	.hword	0x01BC,0x455C,0x0000,0xF04A,0xFFFF
	.hword	0x0365,0x87C9,0x0000,0x0F6D,0x0000
	.hword	0x0151,0x34A7,0x0000,0xF0A5,0xFFFF
	.hword	0x011B,0x2C3C,0x0000,0xFEEA,0xFFFF
	.hword	0x014C,0x33DC,0x0000,0xF064,0xFFFF
	.hword	0x0350,0x8481,0x0000,0xFFCD,0xFFFF
	.hword	0x0356,0x8574,0x0000,0x001E,0x0000
	.hword	0x041C,0xA459,0x0000,0xFF13,0xFFFF
	.hword	0x00E5,0x23C3,0x0000,0xF0E9,0xFFFF
	.hword	0x0254,0xCBB8,0x0000,0x002E,0x0000
	.hword	0x0000

japan_2013_qualifying:		;2013 All Japan Qualifying Track
	.hword	0x07BC,0x0F31,0x0001,0x00E3,0x0000
	.hword	0x029D,0x634C,0x0000,0x0FC2,0x0000
	.hword	0x05E6,0xE025,0x0000,0x015B,0x0000
	.hword	0x02C1,0x68A5,0x0000,0x100B,0x0000
	.hword	0x01E4,0x47D8,0x0000,0xF1F0,0xFFFF
	.hword	0x025B,0x597C,0x0000,0x14BE,0x0000
	.hword	0x035E,0x7FF8,0x0000,0x012E,0x0000
	.hword	0x0360,0x8043,0x0000,0x00E1,0x0000
	.hword	0x046A,0xA7BD,0x0000,0x1B29,0x0000
	.hword	0x01CE,0x4494,0x0000,0x015E,0x0000
	.hword	0x038E,0x8712,0x0000,0x15B0,0x0000
	.hword	0x02C4,0x691B,0x0000,0x0095,0x0000
	.hword	0x01AC,0x3F87,0x0000,0x00CD,0x0000
	.hword	0x012E,0x2CD3,0x0000,0x0A11,0x0000
	.hword	0x0687,0xF80B,0x0000,0x01A1,0x0000
	.hword	0x02A3,0x6433,0x0000,0x100F,0x0000
	.hword	0x0913,0x58CF,0x0001,0x01D9,0x0000
	.hword	0x0153,0x324C,0x0000,0x0F44,0x0000
	.hword	0x052E,0x3364,0x0001,0x0130,0x0000
	.hword	0x0000

japan_2013_final:		;2013 All Japan Final Track
	.hword	0x1719,0x2B1D,0x0003,0x0071,0x0000
	.hword	0x01E7,0x447E,0x0000,0xF074,0xFFFF
	.hword	0x0310,0x6E3C,0x0000,0x0054,0x0000
	.hword	0x00E9,0x20C6,0x0000,0x0246,0x0000
	.hword	0x01EC,0x452C,0x0000,0xFAC8,0xFFFF
	.hword	0x00E2,0x1FC9,0x0000,0x0225,0x0000
	.hword	0x01E4,0x4415,0x0000,0x008D,0x0000
	.hword	0x156D,0x0350,0x0003,0xF21E,0xFFFF
	.hword	0x00B0,0x18C6,0x0000,0x0104,0x0000
	.hword	0x023A,0x5024,0x0000,0xF996,0xFFFF
	.hword	0x00B3,0x192A,0x0000,0x019E,0x0000
	.hword	0x0D5F,0xE161,0x0001,0xF85D,0xFFFF
	.hword	0x01E7,0x4475,0x0000,0x1F21,0x0000
	.hword	0x0249,0x5245,0x0000,0xDC1D,0xFFFF
	.hword	0x089A,0x35AA,0x0001,0xFFAE,0xFFFF
	.hword	0x03CB,0x888D,0x0000,0xDEF9,0xFFFF
	.hword	0x019D,0x3A12,0x0000,0x0726,0x0000
	.hword	0x01B3,0x3D2B,0x0000,0xF501,0xFFFF
	.hword	0x01D9,0x4285,0x0000,0x0E7B,0x0000
	.hword	0x0195,0x38F6,0x0000,0xF650,0xFFFF
	.hword	0x01CF,0x411A,0x0000,0x0E0A,0x0000
	.hword	0x01E2,0x43C6,0x0000,0xF2CC,0xFFFF
	.hword	0x0236,0x4F9A,0x0000,0x1186,0x0000
	.hword	0x0213,0x4AAB,0x0000,0xF15B,0xFFFF
	.hword	0x01E4,0x4411,0x0000,0x0EDD,0x0000
	.hword	0x01B4,0x3D4F,0x0000,0xF4DD,0xFFFF
	.hword	0x01FC,0x4772,0x0000,0x0FD6,0x0000
	.hword	0x00FE,0x23BB,0x0000,0xFD5D,0xFFFF
	.hword	0x00CF,0x1D13,0x0000,0x0C6B,0x0000
	.hword	0x00DE,0x1F3E,0x0000,0x0384,0x0000
	.hword	0x01EC,0x4531,0x0000,0xFADB,0xFFFF
	.hword	0x00E0,0x1F80,0x0000,0x01DE,0x0000
	.hword	0x00C0,0x1B00,0x0000,0x0150,0x0000
	.hword	0x00EA,0x20EA,0x0000,0x0220,0x0000
	.hword	0x01E3,0x43E6,0x0000,0xFAC8,0xFFFF
	.hword	0x01E0,0x4385,0x0000,0x05ED,0x0000
	.hword	0x01DE,0x4336,0x0000,0xFA96,0xFFFF
	.hword	0x00EC,0x2131,0x0000,0x0259,0x0000
	.hword	0x019B,0x39CB,0x0000,0x0081,0x0000
	.hword	0x017B,0x354A,0x0000,0xFE1E,0xFFFF
	.hword	0x01F6,0x4693,0x0000,0xE217,0xFFFF
	.hword	0x016C,0x3333,0x0000,0xFF99,0xFFFF
	.hword	0x018F,0x3823,0x0000,0x0023,0x0000
	.hword	0x00EC,0x212D,0x0000,0x02C3,0x0000
	.hword	0x01ED,0x4555,0x0000,0xFA77,0xFFFF
	.hword	0x00E0,0x1F7D,0x0000,0x021F,0x0000
	.hword	0x04E7,0xB080,0x0000,0x11EC,0x0000
	.hword	0x01CC,0x40B3,0x0000,0x0073,0x0000
	.hword	0x04CD,0xACCF,0x0000,0x1115,0x0000
	.hword	0x0405,0x90B1,0x0000,0x0081,0x0000
	.hword	0x013B,0x2C51,0x0000,0x0017,0x0000
	.hword	0x01A2,0x3AC4,0x0000,0x036A,0x0000
	.hword	0x01DD,0x4308,0x0000,0x1ECE,0x0000
	.hword	0x0181,0x3634,0x0000,0xFFAE,0xFFFF
	.hword	0x013D,0x2C8F,0x0000,0x0007,0x0000
	.hword	0x03F7,0x8EBF,0x0000,0xFEEB,0xFFFF
	.hword	0x01EA,0x44DD,0x0000,0xE1BD,0xFFFF
	.hword	0x03FE,0x8FC0,0x0000,0xFFE4,0xFFFF
	.hword	0x0140,0x2D01,0x0000,0xFFF9,0xFFFF
	.hword	0x01A5,0x3B2E,0x0000,0x04A0,0x0000
	.hword	0x01B6,0x3D97,0x0000,0x1D07,0x0000
	.hword	0x0187,0x3703,0x0000,0x0077,0x0000
	.hword	0x0143,0x2D6F,0x0000,0x0027,0x0000
	.hword	0x03F8,0x8EDB,0x0000,0xFF39,0xFFFF
	.hword	0x0188,0x3717,0x0000,0xE87B,0xFFFF
	.hword	0x0135,0x2B80,0x0000,0xFECC,0xFFFF
	.hword	0x008F,0x1415,0x0000,0xF9F9,0xFFFF
	.hword	0x024F,0x5322,0x0000,0xFEA4,0xFFFF
	.hword	0x0102,0x2445,0x0000,0xF13B,0xFFFF
	.hword	0x0187,0x36FF,0x0000,0xFF9F,0xFFFF
	.hword	0x0140,0x2D09,0x0000,0xFFBD,0xFFFF
	.hword	0x0143,0x2D67,0x0000,0xFFBD,0xFFFF
	.hword	0x0138,0x2BDC,0x0000,0x0004,0x0000
	.hword	0x01A5,0x3B38,0x0000,0x0298,0x0000
	.hword	0x01CD,0x40C8,0x0000,0x1E74,0x0000
	.hword	0x0199,0x3989,0x0000,0x00B7,0x0000
	.hword	0x0138,0x2BE7,0x0000,0x0013,0x0000
	.hword	0x0140,0x2CFC,0x0000,0x0010,0x0000
	.hword	0x013F,0x2CDB,0x0000,0x0039,0x0000
	.hword	0x044B,0x9A8E,0x0000,0x0016,0x0000
	.hword	0x0141,0x2D25,0x0000,0x0035,0x0000
	.hword	0x01F0,0x45C2,0x0000,0x02C0,0x0000
	.hword	0x00E2,0x1FBC,0x0000,0x0DF6,0x0000
	.hword	0x0360,0x798A,0x0000,0x0026,0x0000
	.hword	0x01F8,0x46E3,0x0000,0xEF65,0xFFFF
	.hword	0x0B06,0x8CD4,0x0001,0xF312,0xFFFF
	.hword	0x01A0,0x3A78,0x0000,0x1BA4,0x0000
	.hword	0x0234,0x4F56,0x0000,0xE89E,0xFFFF
	.hword	0x0186,0x36D0,0x0000,0x1904,0x0000
	.hword	0x020C,0x49B6,0x0000,0xE56A,0xFFFF
	.hword	0x00CC,0x1CAB,0x0000,0x0B6D,0x0000
	.hword	0x0278,0x58E5,0x0000,0xE25B,0xFFFF
	.hword	0x0238,0x4FDA,0x0000,0x2560,0x0000
	.hword	0x01E8,0x44A5,0x0000,0xE5D7,0xFFFF
	.hword	0x0148,0x2E23,0x0000,0x1517,0x0000
	.hword	0x01AA,0x3BE7,0x0000,0xE6F1,0xFFFF
	.hword	0x01FA,0xB5B8,0x0000,0xFFA6,0xFFFF
	.hword	0x0000

japan_2014_final:		;2014 All Japan Final Track
	.hword	0x1C47,0x51E7,0x0004,0x00E7,0x0000
	.hword	0x00C3,0x1E79,0x0000,0x0D85,0x0000
	.hword	0x05A0,0xE101,0x0000,0x0357,0x0000
	.hword	0x00C3,0x1E75,0x0000,0x0DA5,0x0000
	.hword	0x008D,0x1611,0x0000,0x0129,0x0000
	.hword	0x00DA,0x2213,0x0000,0xFFAB,0xFFFF
	.hword	0x01AD,0x4305,0x0000,0x00C9,0x0000
	.hword	0x00CF,0x205B,0x0000,0xFF4D,0xFFFF
	.hword	0x0092,0x16CA,0x0000,0x0070,0x0000
	.hword	0x00D6,0x2170,0x0000,0xFF18,0xFFFF
	.hword	0x01A9,0x4269,0x0000,0x0115,0x0000
	.hword	0x00D7,0x2198,0x0000,0xFFA8,0xFFFF
	.hword	0x01A6,0x41E8,0x0000,0xFFA6,0xFFFF
	.hword	0x01AD,0x4310,0x0000,0xFFD0,0xFFFF
	.hword	0x00D0,0x2080,0x0000,0xFF50,0xFFFF
	.hword	0x01B4,0x4421,0x0000,0x0135,0x0000
	.hword	0x00CD,0x2007,0x0000,0xFF5F,0xFFFF
	.hword	0x008C,0x15E0,0x0000,0xFF30,0xFFFF
	.hword	0x01B9,0x44EB,0x0000,0xE0E7,0xFFFF
	.hword	0x046D,0xB105,0x0000,0x1373,0x0000
	.hword	0x0251,0x5CAB,0x0000,0xEAD1,0xFFFF
	.hword	0x0463,0xAF75,0x0000,0xFEBD,0xFFFF
	.hword	0x02AD,0x6B06,0x0000,0xE656,0xFFFF
	.hword	0x026B,0x60BB,0x0000,0x002F,0x0000
	.hword	0x0136,0x306D,0x0000,0x0791,0x0000
	.hword	0x0185,0x3CC5,0x0000,0x00DB,0x0000
	.hword	0x015D,0x368B,0x0000,0xFF69,0xFFFF
	.hword	0x01BA,0x4514,0x0000,0xF022,0xFFFF
	.hword	0x0468,0xB03F,0x0000,0xFEB3,0xFFFF
	.hword	0x029C,0x685D,0x0000,0xF087,0xFFFF
	.hword	0x0282,0x644E,0x0000,0x1F5C,0x0000
	.hword	0x0353,0x84FB,0x0000,0xD76D,0xFFFF
	.hword	0x0542,0xD251,0x0000,0x326F,0x0000
	.hword	0x0383,0x8C76,0x0000,0xD4B0,0xFFFF
	.hword	0x0472,0xB1D1,0x0000,0x2A3D,0x0000
	.hword	0x01F2,0x4DD1,0x0000,0xE8A1,0xFFFF
	.hword	0x0232,0x57D2,0x0000,0xFED6,0xFFFF
	.hword	0x01BA,0x450E,0x0000,0xF056,0xFFFF
	.hword	0x0209,0x515F,0x0000,0x02C1,0x0000
	.hword	0x0105,0x28CD,0x0000,0x1397,0x0000
	.hword	0x021C,0x5460,0x0000,0xD9A6,0xFFFF
	.hword	0x17DA,0xBA16,0x0003,0x062E,0x0000
	.hword	0x00E0,0x2302,0x0000,0xFDAA,0xFFFF
	.hword	0x01A9,0x4264,0x0000,0x0584,0x0000
	.hword	0x00DC,0x225F,0x0000,0xFD5B,0xFFFF
	.hword	0x157B,0x5B34,0x0003,0x0912,0x0000
	.hword	0x0184,0x3C9F,0x0000,0x1DFB,0x0000
	.hword	0x14B6,0x3C76,0x0003,0xF94E,0xFFFF
	.hword	0x00DB,0x223B,0x0000,0xFD2F,0xFFFF
	.hword	0x01A6,0x41EC,0x0000,0x051C,0x0000
	.hword	0x00D8,0x21C1,0x0000,0xFD31,0xFFFF
	.hword	0x1A9C,0x285B,0x0004,0xF80F,0xFFFF
	.hword	0x0165,0x37C5,0x0000,0x1B63,0x0000
	.hword	0x00ED,0x250E,0x0000,0xFFBA,0xFFFF
	.hword	0x021C,0x545D,0x0000,0xDD99,0xFFFF
	.hword	0x01F2,0x4DCF,0x0000,0x26DF,0x0000
	.hword	0x024E,0x5C33,0x0000,0xDC77,0xFFFF
	.hword	0x01FA,0x4F10,0x0000,0x2698,0x0000
	.hword	0x026F,0x6157,0x0000,0xD8BD,0xFFFF
	.hword	0x01FD,0x4F87,0x0000,0x26BF,0x0000
	.hword	0x0201,0x5029,0x0000,0xE287,0xFFFF
	.hword	0x01E6,0x4BED,0x0000,0x25E1,0x0000
	.hword	0x01C3,0x467A,0x0000,0xE7DC,0xFFFF
	.hword	0x00B0,0x1B7F,0x0000,0x0BA1,0x0000
	.hword	0x018B,0xAC4B,0x0000,0x010F,0x0000
	.hword	0x0000
	
japan_2015_test:	    ;2015 All Japan test track
	.hword	0x07C9,0xD8E4,0x0000,0x000C,0x0000
	.hword	0x01C8,0x38FE,0x0000,0xF562,0xFFFF
	.hword	0x08B8,0x16FF,0x0001,0xFFA9,0xFFFF
	.hword	0x0161,0x2C21,0x0000,0xF55F,0xFFFF
	.hword	0x009C,0x1384,0x0000,0x0134,0x0000
	.hword	0x012C,0x257D,0x0000,0x0941,0x0000
	.hword	0x03FC,0x7F83,0x0000,0x00CD,0x0000
	.hword	0x01D2,0x3A3B,0x0000,0xF56B,0xFFFF
	.hword	0x01E7,0x3CE8,0x0000,0xFF5E,0xFFFF
	.hword	0x0246,0x48B3,0x0000,0xF567,0xFFFF
	.hword	0x0688,0xD104,0x0000,0xFFEE,0xFFFF
	.hword	0x01E9,0x3D23,0x0000,0xFFBB,0xFFFF
	.hword	0x0956,0x2ABA,0x0001,0xDECC,0xFFFF
	.hword	0x01F9,0x3F21,0x0000,0xFFC9,0xFFFF
	.hword	0x016F,0x2DEB,0x0000,0x00CD,0x0000
	.hword	0x01A6,0x34BC,0x0000,0x0A4C,0x0000
	.hword	0x1567,0xACDC,0x0002,0xEA60,0xFFFF
	.hword	0x01BE,0x37BB,0x0000,0xEA81,0xFFFF
	.hword	0x0F29,0xE52D,0x0001,0x1723,0x0000
	.hword	0x0745,0xE897,0x0000,0xFFFD,0xFFFF
	.hword	0x0402,0x8041,0x0000,0xF52F,0xFFFF
	.hword	0x0193,0xA0EE,0x0000,0xFFFE,0xFFFF
	.hword	0x0000
	
japan_2015_qualifying:	    ;2015 All Japan Qualifying Track
	.hword	0x17F5,0x8619,0x0002,0x00E1,0x0000
	.hword	0x0319,0x56B8,0x0000,0xEF90,0xFFFF
	.hword	0x02E5,0x510C,0x0000,0xFFB0,0xFFFF
	.hword	0x01BD,0x30AD,0x0000,0xFF7F,0xFFFF
	.hword	0x0768,0xCF61,0x0000,0xDF85,0xFFFF
	.hword	0x01A7,0x2E45,0x0000,0xFF7B,0xFFFF
	.hword	0x02A4,0x49EF,0x0000,0xFFA9,0xFFFF
	.hword	0x024C,0x4050,0x0000,0xF016,0xFFFF
	.hword	0x0C39,0x5640,0x0001,0xFFF0,0xFFFF
	.hword	0x00F9,0x1B3A,0x0000,0x0046,0x0000
	.hword	0x01F1,0x365A,0x0000,0xFF8C,0xFFFF
	.hword	0x00FA,0x1B57,0x0000,0x0059,0x0000
	.hword	0x0C41,0x5722,0x0001,0x0034,0x0000
	.hword	0x0215,0x3A48,0x0000,0xF596,0xFFFF
	.hword	0x05C0,0xA0FE,0x0000,0xFEEE,0xFFFF
	.hword	0x010D,0x1D69,0x0000,0xF641,0xFFFF
	.hword	0x01AF,0x9DB7,0x0000,0xFF37,0xFFFF

japan_2015_final:	    ;2015 All Japan Final Track
	.hword	0x06DF,0xA7AE,0x0000,0x0034,0x0000
	.hword	0x009E,0x114A,0x0000,0xFFD4,0xFFFF
	.hword	0x0147,0x23C2,0x0000,0x0080,0x0000
	.hword	0x00A1,0x119D,0x0000,0xFFC5,0xFFFF
	.hword	0x009E,0x1143,0x0000,0xFF79,0xFFFF
	.hword	0x00E7,0x1948,0x0000,0xFBCC,0xFFFF
	.hword	0x00D6,0x176B,0x0000,0x08C9,0x0000
	.hword	0x0188,0x2ADD,0x0000,0xFA6F,0xFFFF
	.hword	0x0082,0x0E33,0x0000,0x0493,0x0000
	.hword	0x0287,0x46C6,0x0000,0xE6BE,0xFFFF
	.hword	0x00DE,0x184B,0x0000,0x0101,0x0000
	.hword	0x017E,0x29C2,0x0000,0x11C2,0x0000
	.hword	0x014F,0x24AA,0x0000,0x0232,0x0000
	.hword	0x025E,0x424C,0x0000,0xE922,0xFFFF
	.hword	0x008F,0x0FA0,0x0000,0x04DE,0x0000
	.hword	0x0162,0x26B6,0x0000,0xF85A,0xFFFF
	.hword	0x00EC,0x19D0,0x0000,0x09BE,0x0000
	.hword	0x00E9,0x197E,0x0000,0xFBC6,0xFFFF
	.hword	0x0094,0x1033,0x0000,0xFFC7,0xFFFF
	.hword	0x031D,0x572F,0x0000,0x0A8D,0x0000
	.hword	0x00FE,0x1BC0,0x0000,0xF7BE,0xFFFF
	.hword	0x0645,0xAF91,0x0000,0x02D1,0x0000
	.hword	0x0400,0x7001,0x0000,0x15F1,0x0000
	.hword	0x074E,0xCC89,0x0000,0xFC61,0xFFFF
	.hword	0x1136,0xE1E5,0x0001,0xF541,0xFFFF
	.hword	0x1020,0xC380,0x0001,0xF54A,0xFFFF
	.hword	0x0F88,0xB2DE,0x0001,0xF542,0xFFFF
	.hword	0x018A,0x2B1A,0x0000,0x0004,0x0000
	.hword	0x0184,0x2A70,0x0000,0xFF16,0xFFFF
	.hword	0x01F3,0x3691,0x0000,0xEB3B,0xFFFF
	.hword	0x0182,0x2A3A,0x0000,0xFEEE,0xFFFF
	.hword	0x018E,0x2B86,0x0000,0x0038,0x0000
	.hword	0x0AEA,0x3198,0x0001,0x0A40,0x0000
	.hword	0x00B9,0x1441,0x0000,0xFF87,0xFFFF
	.hword	0x015B,0x25EF,0x0000,0x0457,0x0000
	.hword	0x00BA,0x145C,0x0000,0xFFA0,0xFFFF
	.hword	0x0979,0x0936,0x0001,0x08A6,0x0000
	.hword	0x00B3,0x139A,0x0000,0xFF60,0xFFFF
	.hword	0x015E,0x2647,0x0000,0x0459,0x0000
	.hword	0x00B9,0x1439,0x0000,0xFF8F,0xFFFF
	.hword	0x0ACF,0x2EA9,0x0001,0x0A29,0x0000
	.hword	0x01F5,0x36CA,0x0000,0x0082,0x0000
	.hword	0x0724,0xC7E9,0x0000,0x0B87,0x0000
	.hword	0x019A,0x2CE1,0x0000,0x0047,0x0000
	.hword	0x0190,0x2BBB,0x0000,0x0029,0x0000
	.hword	0x0A39,0x1E3C,0x0001,0x0BC0,0x0000
	.hword	0x0A37,0x1E05,0x0001,0x0C0F,0x0000
	.hword	0x0917,0xFE88,0x0000,0x0BC2,0x0000
	.hword	0x034D,0x5C69,0x0000,0x007F,0x0000
	.hword	0x0408,0x70E3,0x0000,0x0B1B,0x0000
	.hword	0x0192,0x2BF2,0x0000,0x0064,0x0000
	.hword	0x0192,0x2BF8,0x0000,0x004A,0x0000
	.hword	0x0734,0xC9B2,0x0000,0x0BAA,0x0000
	.hword	0x0528,0x905D,0x0000,0x0D39,0x0000
	.hword	0x01D5,0x334F,0x0000,0x164B,0x0000
	.hword	0x02E4,0x50EF,0x0000,0xE749,0xFFFF
	.hword	0x00BF,0x14E5,0x0000,0x07D9,0x0000
	.hword	0x01C9,0x31FB,0x0000,0xF781,0xFFFF
	.hword	0x01B8,0x301E,0x0000,0x13F0,0x0000
	.hword	0x01DF,0x3467,0x0000,0xF40B,0xFFFF
	.hword	0x0081,0x0E1E,0x0000,0x0468,0x0000
	.hword	0x01B4,0x2FAB,0x0000,0x014D,0x0000
	.hword	0x0147,0x23C7,0x0000,0x0005,0x0000
	.hword	0x0147,0x23C6,0x0000,0x000A,0x0000
	.hword	0x014C,0x244F,0x0000,0xFFFB,0xFFFF
	.hword	0x0250,0x40C0,0x0000,0x00DA,0x0000
	.hword	0x024D,0x406C,0x0000,0x09F4,0x0000
	.hword	0x0A8B,0x2734,0x0001,0x0668,0x0000
	.hword	0x01F8,0x371D,0x0000,0xEB13,0xFFFF
	.hword	0x05D6,0xA36A,0x0000,0xFCBC,0xFFFF
	.hword	0x070C,0xC54F,0x0000,0x13F1,0x0000
	.hword	0x0675,0xB4CE,0x0000,0x0084,0x0000
	.hword	0x00A2,0x11B4,0x0000,0x0046,0x0000
	.hword	0x0147,0x23C8,0x0000,0xFF9C,0xFFFF
	.hword	0x009E,0x1145,0x0000,0x0017,0x0000
	.hword	0x0348,0x5BE1,0x0000,0xFF9F,0xFFFF
	.hword	0x0162,0x26B6,0x0000,0xF2A8,0xFFFF
	.hword	0x009D,0x1130,0x0000,0xFE74,0xFFFF
	.hword	0x00C2,0x1534,0x0000,0xF9B6,0xFFFF
	.hword	0x06CC,0xBE56,0x0000,0xFF72,0xFFFF
	.hword	0x00A2,0x11B4,0x0000,0xFFD0,0xFFFF
	.hword	0x0143,0x2358,0x0000,0x0076,0x0000
	.hword	0x00A7,0x123D,0x0000,0xFFEB,0xFFFF
	.hword	0x0B00,0x3408,0x0001,0x005E,0x0000
	.hword	0x00A4,0x11EA,0x0000,0xFFD8,0xFFFF
	.hword	0x0145,0x2392,0x0000,0x0096,0x0000
	.hword	0x00A2,0x11B5,0x0000,0xFFDB,0xFFFF
	.hword	0x047B,0x7D77,0x0000,0xFFA1,0xFFFF
	.hword	0x0180,0x29FC,0x0000,0xF504,0xFFFF
	.hword	0x020E,0x3986,0x0000,0x1824,0x0000
	.hword	0x018B,0x2B35,0x0000,0xF479,0xFFFF
	.hword	0x03C8,0x69E4,0x0000,0xFE9A,0xFFFF
	.hword	0x017B,0x296E,0x0000,0xF4CA,0xFFFF
	.hword	0x0217,0x3A88,0x0000,0x189A,0x0000
	.hword	0x02EF,0x5224,0x0000,0xE864,0xFFFF
	.hword	0x01D1,0x32D6,0x0000,0x159E,0x0000
	.hword	0x0272,0x447F,0x0000,0xED69,0xFFFF
	.hword	0x01ED,0x35EC,0x0000,0xFED2,0xFFFF
	.hword	0x01D1,0x32D9,0x0000,0xF1B3,0xFFFF
	.hword	0x0213,0x3A13,0x0000,0x1851,0x0000
	.hword	0x02CB,0x4E37,0x0000,0xE81F,0xFFFF
	.hword	0x0240,0x3EF7,0x0000,0x1A6F,0x0000
	.hword	0x0199,0x2CC5,0x0000,0xF345,0xFFFF
	.hword	0x01B6,0x9E71,0x0000,0xFF35,0xFFFF
	.hword	0x0000
	;
taiwan_2016_pm3:	    ;Taiwan practice Maze 3
	.hword	0x0A32,0x04BD,0x0001,0x0057,0x0000
	.hword	0x028D,0x476C,0x0000,0xE7DE,0xFFFF
	.hword	0x025D,0x4229,0x0000,0x1B1D,0x0000
	.hword	0x032F,0x5927,0x0000,0xE57D,0xFFFF
	.hword	0x0205,0x388B,0x0000,0x179B,0x0000
	.hword	0x02DE,0x5047,0x0000,0xEAA5,0xFFFF
	.hword	0x011C,0x1F12,0x0000,0xFFCE,0xFFFF
	.hword	0x00A0,0x1182,0x0000,0x01DC,0x0000
	.hword	0x00B9,0x1439,0x0000,0xFBE9,0xFFFF
	.hword	0x0099,0x10BC,0x0000,0x03CE,0x0000
	.hword	0x00CC,0x164F,0x0000,0xFCAB,0xFFFF
	.hword	0x0080,0x0E00,0x0000,0x036C,0x0000
	.hword	0x00D7,0x1783,0x0000,0xFCC1,0xFFFF
	.hword	0x007A,0x0D57,0x0000,0x035F,0x0000
	.hword	0x00D8,0x17A3,0x0000,0xFCBD,0xFFFF
	.hword	0x0083,0x0E50,0x0000,0x0352,0x0000
	.hword	0x00C5,0x158E,0x0000,0xFC82,0xFFFF
	.hword	0x0081,0x0E1E,0x0000,0x03AC,0x0000
	.hword	0x00C7,0x15C3,0x0000,0xFC35,0xFFFF
	.hword	0x0098,0x10A3,0x0000,0x0425,0x0000
	.hword	0x00B8,0x1419,0x0000,0xFDE5,0xFFFF
	.hword	0x0118,0x1EA7,0x0000,0xFEF1,0xFFFF
	.hword	0x0163,0x26CD,0x0000,0xF1EF,0xFFFF
	.hword	0x0197,0x2C86,0x0000,0xFEDE,0xFFFF
	.hword	0x0133,0x2191,0x0000,0xFEEB,0xFFFF
	.hword	0x00B1,0x1361,0x0000,0xFC01,0xFFFF
	.hword	0x0136,0x21EA,0x0000,0xFF20,0xFFFF
	.hword	0x00CF,0x16A1,0x0000,0xFD79,0xFFFF
	.hword	0x01D8,0x33A2,0x0000,0x05E0,0x0000
	.hword	0x00C0,0x14FF,0x0000,0xFD81,0xFFFF
	.hword	0x0123,0x1FD6,0x0000,0xFF2E,0xFFFF
	.hword	0x0304,0x546C,0x0000,0xEACA,0xFFFF
	.hword	0x05A5,0x9E10,0x0000,0xFEF0,0xFFFF
	.hword	0x009A,0x10D6,0x0000,0xFC74,0xFFFF
	.hword	0x0124,0x1FF0,0x0000,0xFEBE,0xFFFF
	.hword	0x01D6,0x3368,0x0000,0xFFA8,0xFFFF
	.hword	0x025C,0x4211,0x0000,0xEF99,0xFFFF
	.hword	0x0205,0xA719,0x0000,0xFF69,0xFFFF
	.hword	0x0000
		
;******************************************************************************
;Default parameters
; these are loaded into the EEPROM if the first parameter is 0xffff

        .palign 1024	    ;Align next word stored in Program space to an
			    ;address that is a multiple of 1024
defpar:	.hword	0x0000,0x0000
	.hword	0x0010,0x001c,0x001c,0x0000
	.hword	0x0030,0x001c,0x0060,0x0000
	.hword	0x0034,0x001d,0x0070,0x0000
	.hword	0x0038,0x001e,0x0080,0x0000
	.hword	0x003c,0x001f,0x0090,0x0000

defpar_jehu:	.hword	0x0000,0x0000
	.hword	0x0020,0x0024,0x0024,0x0000
	.hword	0x003a,0x0024,0x0078,0x0000
	.hword	0x003e,0x0025,0x008c,0x0000
	.hword	0x0042,0x0026,0x00a0,0x0000
	.hword	0x0046,0x0027,0x00b4,0x0000
;--------End of All Code Sections ---------------------------------------------

.end			    ;End of program code in this file

