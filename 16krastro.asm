
//-----------------------------------------------------------------------------------
//
// Code by TWILIGHT / Excess 2019 - ...
// Kick Assembler V5.14
//
//-----------------------------------------------------------------------------------



.pc = $1000 "music"
      .import binary "jeroen tel db.prg",2

      .pc = $2000 "1x2 charset"
      .import binary "devils_collection_18_y_multi.64c",2
      
      .pc = $2800 "logo charset"
      .import binary "logoneu.pimap",2
      
      

.pc = $0801 "BasicStart"
:BasicUpstart($2b00)

.pc= $2b00 "maincode"


			lda #$49    //49 pal    24 ntsc
			sta FIX1a
        	sta FIX2a
        	sta FIX3
        	sta FIX1c
        	sta FIX2c
			jsr disable		
			lda #<sctext			
			sta text+1			
			lda #>sctext		
			sta text+2			
			jsr sc3			
			lda #$0b
			sta $d022
			
			lda #$00
			sta $0286
			jsr $e544
			lda #$00
			tax
			tay
			jsr $1000
			ldx #$00
lop4:		lda #$0b
			sta $d800,x
			sta $d900-100,x
			sta $da80,x
		//	sta $db80-110,x
			inx
			bne lop4
			
			ldx #$00
lop5:		lda logo,x
			sta $0450,x
			sta $0680,x
			lda logo+40,x
			sta $0450+40,x
			sta $0680+40,x
			lda logo+40*2,x
			sta $0450+40*2,x
			sta $0680+40*2,x
			lda logo+40*3,x
			sta $0450+40*3,x
			sta $0680+40*3,x
			lda logo+40*4,x
			sta $0450+40*4,x
			sta $0680+40*4,x
			lda logo+40*5,x
			sta $0450+40*5,x
			sta $0680+40*5,x
			inx
			cpx #$28
			bne lop5
			lda #$00
			sta $d020
			
        	sei
        	lda #$7F
        	sta $DC0D    
        	sta $DD0D    
        	lda $DC0D    
        	lda $DD0D    
        	lda #$01
        	sta $D01A    
        	lda #$d8
        	sta $d016
        	lda #$31
        	sta $D012    
        	lda #$1B
        	sta $D011    
        	lda #<INT1
        	sta $0314    
        	lda #>INT1
        	sta $0315    
        	cli
        	jmp *
        	
kbcheck:	
			lda $dc00    
        	eor $dc01    
        	asl
        	bne exit1     
        	rts
exit1:     	jmp exit
			
			

			
//----- RESTORE DEAD -----------------------------------------------
disable:        lda #<nmi             //Set NMI vector
                sta $0318
                sta $fffa
                lda #>nmi
                sta $0319
                sta $fffb
                lda #$81
                sta $dd0d             //Use Timer A
                lda #$01              //Timer A count ($0001)
                sta $dd04
                lda #$00
                sta $dd05
                lda #%00011001        //Run Timer A
                sta $dd0e
                rts

nmi:           	rti





exit:         	
			sei
			lda #$00
			sta $d01a
			
        	ldx #<$ea31
        	ldy #>$ea31
        	jsr INTe
        	jsr $fda3    //$fda3 (jmp) - initialize cia & irq
        	ldx #$1f
        	jsr $e5aa    //get a vic ii chip initialisation value



        	ldx #$18
        	lda #$00
lop7:      	sta $d400,x  //;select filter mode and volume
        	dex
        	bpl lop7
        	lda #$00
        	sta $d011

        	
       		jmp $fce2    //$080d   // Gamestart Jump

//-----------------------------------------------------------------			
			

.align $0100
//------------------------------------------------------------------------------
// Rasters  logo oben

INT1:	   	ldy #$0d
lop1:      	dey
        	bpl lop1
FIX1a:		nop //NTSC
        	nop
        	bit $EA
        	ldx #$00
INT1_J1: 	lda color11,x
        	sta $D021    
        	sta $D021    
logoc1:    	lda color33,x
        	sta $D023    
FIX2a:   	nop //;NTSC
        	nop
        	nop
        	inx
        	ldy #$06
INT1_J2: 	lda color11,x
        	sta $D021    
        	sta $D021    
logoc11:   	lda color33,x
        	sta $D023    
        	jsr Delay
        	bpl INT1_J2
        	nop
        	cpx #$50
        	bne INT1_J1
			nop
			nop
			nop
	//		lda #$00
	//		sta $d020
			
        	ldx #<INT2
        	ldy #>INT2
        	lda #$8a
        	jsr INTe
        	jmp $ea81

//------------------------------------------------------------------------------
// Rasters mitte scroll

INT2:    	
        	lda scrpos
        	sta $d016
        	lda #$18
        	sta $D018    
        	ldx #<INT3
        	ldy #>INT3
        	lda #$a1
        	jsr INTe
        	jmp $ea81

//------------------------------------------------------------------------------
// Rasters logo unten

.align $0100
INT3:    	
			lda #$1a
			sta $d018
			lda #$d0
			sta $d016

			ldy #$0a
lop3:      	dey
        	bpl lop3
        	nop

FIX1c:   	nop //;NTSC
			nop
        	bit $EA
        	ldx #$00
INT3_J1: 	lda color11,x
        	sta $D021    
        	sta $D021    
logoc2:    	lda color33,x
        	sta $D023        
FIX2c:   	nop //;NTSC
			nop
			nop
        	inx
        	ldy #$06
INT3_J2: 	lda color11,x
        	sta $D021    
        	sta $D021    
logoc22:   	lda color33,x
        	sta $D023    
        	jsr Delay
        	bpl INT3_J2
        	nop
        	cpx #$50
        	bne INT3_J1

			lda #$1a
			sta $d018
			lda #$d0
			sta $d016
        	ldx #<INT1
        	ldy #>INT1
        	lda #$31
        	jsr INTe
			jsr scroll
			jsr $1003
			jsr fade
			jsr rasterro
        	jsr kbcheck
			jmp $ea81


//------------------------------------------------------------------------------
// Exit the interrupt
.align $0100
INTe:  	  	stx $0314    
        	sty $0315    
        	sta $D012    
        	inc $D019    
        	rts

//------------------------------------------------------------------------------
Delay:   	lda ($ea,x)
        	lda ($ea,x)
        	lda ($ea,x)
FIX3:    	nop //;NTSC
        	nop
        	nop
        	inx
        	dey
        	rts

//-------------------------------------------------------------------------


//-------------------------------------------------------------------------
.var scline = $0590+40

scroll:		dec scrpos
			lda scrpos
			cmp #$bf
			beq go
			rts
go:			lda #$c7
			sta scrpos
			ldx #$00
sc1:		lda scline+1,x
			sta scline,x
			inx
			cpx #$27
			bne sc1
text:		lda sctext   //scrolltext
			sta $55
			cmp #$ff
			beq scinit
			sta scline+$27
			inc text+1
			bne sc3
			inc text+2
			
sc3:		ldx #$00
sc4:		lda scline,x
			clc
			adc #$40
			sta scline+$28,x
			inx
			cpx #$28
			bne sc4
			rts
			
scinit:		lda #<sctext1			
			sta text+1			
			lda #>sctext1		
			sta text+2			
			jsr sc3			
			rts			
					
					
					
					
fade:				
			lda $55
			cmp #$fe
			beq rasteron
			cmp #$fd
			beq grau
			cmp #$fc
			beq logo1
			cmp #$fb
			beq logo2
			rts
			
// grauer rasterstrich on
grau:		lda #$0b			
			sta	color11+7			
			sta color11+72			
			rts			
			
// raster hinter dem Logo			
rasteron:	
			lda #$00
			sta $d022
			lda #<color1
        	sta INT1_J1+1
        	sta INT1_J2+1
        	lda #>color1
        	sta INT1_J1+2
        	sta INT1_J2+2
			lda #<color2
        	sta INT3_J1+1
        	sta INT3_J2+1
        	lda #>color2
        	sta INT3_J1+2
        	sta INT3_J2+2
	      	lda #$60
	  		sta logoaufbau
			rts
					
logo1:		lda #<color3
        	sta logoc1+1
        	sta logoc11+1
        	lda #>color3
        	sta logoc1+2
        	sta logoc11+2
			rts		
					
logo2:		lda #<color31
        	sta logoc2+1
        	sta logoc22+1
        	lda #>color31
        	sta logoc2+2
        	sta logoc22+2
			rts		
					
scrpos:		.byte $c7	

			
rasterro:   lda color1+16+$2f
            sta color1+16+$00
            ldx #$2f
cycle:      lda color1+16-$01,x
            sta color1+16+$00,x
            dex
            bne cycle

			lda color2+16+$00
            sta color2+16+$2f
            ldx #$00
cycle1:     lda color2+16+$01,x
            sta color2+16+$00,x
            inx
            cpx #$2f
            bne cycle1
        //    rts 			
            
            
logoaufbau: 
			nop
			lda color33+$c2
            sta color33+$00
            ldx #$c2
cycle2:     lda color33-$01,x
            sta color33+$00,x
            dex
            bne cycle2
            rts
//-------------------------------------------------------------------------




.align $0100

// raster oben			
color1:			.text "    ibhjgagjhbi   ibbh bhhj hjjg jgga gaag aggj gjjo jool ollk   ibhjgagjhbi k k  "		
				.byte $00,$00,$00,$00,$00,$00		
// raster unten			
color2:			.text "k k ibhjgagjhbi   kllo looj ojjg jgga gaag aggc gccn cnnd nddf   ibhjgagjhbi       "			
				.byte $00,$00,$00,$00,$00,$00		

.align $0100
// raster im logo oben					
color3:			   
			//	.text "                 klogagolk golk olk lk k k kl klo klog klogagolk    "
				.text "                 fk fkn fknc fknca fkncaaacnkf acnkf cnkf nkf kf    "
			//	.text "                 kl klo klog klogaaaaaaaaaaaaaaagolk golk olk lk    "
.align $0100
color11:		.text "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"		


color31:	//	.text "                 fkncacnkf cnkf nkf kf f f fk fkn fknc fkncacnkf    "
			//	.text "                 ih ihe ihec iheca ihecaaacehi acehi cehi ehi hi    "
				.text "                 ib ibj ibjg ibjga ibhjgaagjbi agjbi gjbi jbi ib    "
				
				
color33:		.text " k         k      k    k   k  k kk kkk kkkkk kkkkkkk kkkkkkkkkk"
                .text "kkkkkkkkkkkkkkkkkkk kkkkkkkkk kkkkkk kkkkk kkkk kk k   k    k      k        k           k    " 

color4:			.text " i ib ibj ibjg ibjgagjbi gjbi jbi bi i   ih ihe ihec ihecacehi cehi ehi hi ik kl klo klog klogagolk golk olk lk kf fk fkn fknc fkncacnkf cnkf nkf kf f"
					



logo:

.byte $20, $20, $20, $01, $02, $03, $04, $05, $06, $07, $05, $06, $07, $05, $08, $09, $05, $0a, $05, $0b, $0c, $0d, $0e, $0f, $05, $10, $09, $05, $0a, $05, $11, $12, $0d, $0e, $0f, $05, $08, $20, $20, $20
.byte $20, $20, $20, $13, $14, $15, $16, $17, $18, $19, $14, $1a, $1b, $1c, $1d, $1e, $14, $1f, $17, $00, $21, $14, $1a, $22, $17, $23, $24, $14, $1f, $17, $25, $26, $14, $1a, $22, $17, $27, $20, $20, $20
.byte $20, $20, $20, $28, $14, $29, $2a, $20, $20, $2b, $2c, $2d, $2e, $2f, $30, $14, $14, $31, $20, $20, $32, $14, $2d, $33, $20, $20, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $20, $20, $20
.byte $20, $20, $20, $28, $14, $15, $3f, $37, $40, $41, $14, $1a, $1b, $42, $43, $14, $14, $44, $37, $45, $32, $14, $1a, $46, $37, $47, $37, $37, $48, $14, $49, $3f, $37, $40, $1b, $14, $4a, $20, $20, $20
.byte $20, $20, $20, $4b, $14, $15, $32, $14, $1a, $1b, $14, $1a, $1b, $14, $4c, $4d, $14, $4e, $14, $4f, $50, $14, $1a, $1b, $14, $51, $14, $14, $4e, $14, $4f, $32, $14, $1a, $1b, $14, $52, $20, $20, $20
.byte $20, $20, $20, $53, $54, $55, $56, $17, $18, $22, $17, $18, $22, $17, $27, $57, $17, $58, $17, $59, $5a, $5b, $5c, $5d, $17, $23, $17, $17, $58, $17, $59, $16, $17, $5c, $5d, $5e, $5f, $20, $20, $20

//.align $0100
sctext:		.text "                       "  //24
			.byte $fd  // Rastersriche an
			.text "                                          "  //42
			.byte $fc  // Logo oben raster
			.text "   "   //3
			.byte $fb  // Logo unten raster 
			.text "                                                            "  //60			
			.byte $fe  // intro aktion
sctext1:			
			.text "more than you deserve          welcome to 16krastro for icc2019  and a happy new year to all our friends "
			.text "    greetings to  abyss conection - angels - atlantis - arsenic - avatar - chorus - delysid - demonix - dentifrice - " 
			.text "desire - f4cg - fairlight - genesis project - hitmen - hoaxers - hokuto force - laxity - lombardasoft - mayday! - "
			.text "nah-kolor - nostalgia - onslaught - oxyron - padua - performers - plush - protovision - pvm - rabenauge - role - "
			.text "samar - scs+trc - tempest - the dreams - the new ninja skateboarders of death - the solution - the transfer team - "
			.text "triad - trsi - ultimate .......       code by twilight      music by jeroen tel                "
			
			.byte $ff

