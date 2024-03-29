;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     FEVEREIRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES
		
		NOTA_REF ; MARCA A NOTA QUE ESTA SENDO TOCADA
		
	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA
	
#DEFINE	NOTA_DO	NOTA_REF,0
#DEFINE	NOTA_RE	NOTA_REF,1
#DEFINE	NOTA_MI	NOTA_REF,2
#DEFINE	NOTA_FA	NOTA_REF,3
#DEFINE	NOTA_SOL NOTA_REF,4
#DEFINE	NOTA_LA	NOTA_REF,5
#DEFINE	NOTA_SI	NOTA_REF,6

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

INTERRUPCAO
	; 0,5 SEGUNDO = 8 us (PRESCALER) X 62500 (TMR1)
	; TMR1 = 65536 - 62500 = 3036 (00001011 11011100)
	; Por�m, utilizando 3037 (00001011 11011101)
	; Obtive valores mais aproximados
	
	BTFSS PIR1, TMR1IF ; CHECA SE PASSOU OS 500 ms
	GOTO IDENTIFICAR_NOTA ; SE N�O, CONTINUA TOCANDO A NOTA ATUAL DIRETO
	
	; SE SIM, RESETA O TIMER1
	MOVLW B'11011101'
	MOVWF TMR1L
	MOVLW B'00001011'
	MOVWF TMR1H
	
	BCF PIR1, TMR1IF
	
	RLF NOTA_REF, F ; PASSA PARA A PR�XIMA NOTA
	BTFSC NOTA_REF, 7 ; CHECA SE CHEGOU AO FIM DA ESCALA
	GOTO RESETA_NOTA_REF ; SE SIM, REINICIA A ESCALA
	GOTO IDENTIFICAR_NOTA
	
RESETA_NOTA_REF
	MOVLW B'00000001'
	MOVWF NOTA_REF

IDENTIFICAR_NOTA
	; A identifica��o das notas musicais
	; � dada da seguinte configura��o:
	; NOTA_REF - NOTA
	; 00000001 - D�
	; 00000010 - R�
	; 00000100 - MI
	; 00001000 - F�
	; 00010000 - SOL
	; 00100000 - L�
	; 01000000 - S�
		
	BTFSC NOTA_DO
	GOTO RESETA_TIMER_DO
	BTFSC NOTA_RE
	GOTO RESETA_TIMER_RE
	BTFSC NOTA_MI
	GOTO RESETA_TIMER_MI
	BTFSC NOTA_FA
	GOTO RESETA_TIMER_FA
	BTFSC NOTA_SOL
	GOTO RESETA_TIMER_SOL
	BTFSC NOTA_LA
	GOTO RESETA_TIMER_LA
	BTFSC NOTA_SI
	GOTO RESETA_TIMER_SI

RESETA_TIMER_DO
	; D�
	; 261,63 Hz approx = 3822 us
	; Duty cicle 50% = 1911 us
	; 1911 us approx = 8 us (PRESCALER) X 239 (TMR0)
	; TMR0 = 256 - 239
	; Ap�s testes, 256 - 237,
	; Trouxe valores mais aproximados
	
	MOVLW .256-.237
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_RE
	; R�
	; 293,67 Hz approx = 3405 us
	; Duty cicle 50% = 1703 us
	; 1703 us approx = 8 us (PRESCALER) X 213 (TMR0)
	; TMR0 = 256 - 213
	; Ap�s testes, 256 - 211,
	; Trouxe valores mais aproximados
	
	MOVLW .256-.211
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_MI
	; MI
	; 329,63 Hz approx = 3034 us
	; Duty cicle 50% = 1517 us
	; 1517 us approx = 8 us (PRESCALER) X 190 (TMR0)
	; TMR0 = 256 - 190
	; Ap�s testes, 256 - 187
	; Trouxe valores mais aproximados
	
	MOVLW .256-.187
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_FA
	; F�
	; 349,23 Hz approx = 2863 us
	; Duty cicle 50% = 1432 us
	; 1432 us approx = 8 us (PRESCALER) X 179 (TMR0)
	; TMR0 = 256 - 179
	; Ap�s testes, 256 - 176
	; Trouxe valores mais aproximados
	
	MOVLW .256-.176
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_SOL
	; SOL
	; 392 Hz approx = 2551 us
	; Duty cicle 50% = 1276 us
	; 1276 us approx = 8 us (PRESCALER) X 160 (TMR0)
	; TMR0 = 256 - 160
	; Ap�s testes, 256 - 156
	; Trouxe valores mais aproximados
	
	MOVLW .256-.156
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_LA
	; L�
	; 440 Hz approx = 2273 us
	; Duty cicle 50% = 1137 us
	; 1137 us approx = 8 us (PRESCALER) X 142 (TMR0)
	; TMR0 = 256 - 142
	; Ap�s testes, 256 - 139
	; Trouxe valores mais aproximados
	
	MOVLW .256-.139
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO

RESETA_TIMER_SI
	; S�
	; 493,89 Hz approx = 2025 us
	; Duty cicle 50% = 1013 us
	; 1013 us approx = 8 us (PRESCALER) X 127 (TMR0)
	; TMR0 = 256 - 127
	; Ap�s testes, 256 - 123
	; Trouxe valores mais aproximados
	
	MOVLW .256-.123
	MOVWF TMR0
	BCF INTCON, T0IF
	GOTO INVERTE_PULSO
	
INVERTE_PULSO
	BTFSS GPIO, GP5 ; CHECA SE GP0 EST� EM ESTADO ALTO
	GOTO SETA_GP5 ; SE N�O, SETA GP0
	BCF GPIO, GP5 ; SE SIM, CLEAR GP0
	GOTO SAI_INT

SETA_GP5
	BSF GPIO, GP5
	GOTO SAI_INT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.
	
DESLIGA_INT
	BCF INTCON, GIE
	BCF GPIO, GP5
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1
	MOVLW	B'00000001'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000010'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11100000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000001'
	MOVWF	PIE1		;ATIVA A INTERRUPCAO DO TIMER1
	BANK0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMP. ANAL�GICO
	MOVLW	B'00110001'
	MOVWF	T1CON		;ATIVA O TIMER1 E DEFINE O PRESCALER

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	; TIMER1 PARA OS 0,5s
	MOVLW	B'11011101'
	MOVWF	TMR1L
	MOVLW	B'00001011'
	MOVWF	TMR1H
	; TIMER0 PARA AS NOTAS MUSICAIS
	MOVLW	.256-.237
	MOVWF	TMR0
	; NOTA_REF PARA IDENTIFICAR E CICLAR ENTRE AS NOTAS
	MOVLW	B'00000001'
	MOVWF	NOTA_REF
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	BTFSC GPIO, GP0 ; CHECA SE GP0 EST� DESLIGADO
	GOTO DESLIGA_INT ; SE N�O, DESLIGA AS INTERRUPCOES E CLEAR GP5
	BSF INTCON, GIE
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
