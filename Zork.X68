   org $1000

*-------------------------------------------------------
*Choose to be Evil Wizard or New Romancers
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_feed    EQU 100    min feed requirement0

*Start of Game
start:
    move.b  #100,$4000 put score/health in memory location $4000
    lea     $4000,A3   assign address A3 to that memory location
    move.l  #300,$5000 puts the total feed for the horses in $5000 
    lea     $5000,A4   assigns A5 to that memory location
    move.b  #4,$6000   puts starting gold in memory location $6000
    lea     $6000,A5
    move.b  #0,$7000   puts number of horses at $7000
    lea     $7000,A6
    move.b  #0,$8000   puts number of soldiers at &8000
    lea     $8000,A7
    move.b  #0,$8500
    lea     $8500,A2   puts neumber of stable boys at $9000


    bsr     welcome    branch to the welcome subroutine
    bsr     intro
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine

Intro: 
    lea     intro_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    CMP     #1,D1
    BEQ     Emerald_Castle
    CMP     #2,D1
    BEQ     White_Castle
    CMP     #3,D1
    BEQ     Neverwinter
    CMP     #4,D1
    BEQ     Sand_Castle
    
    trap    #15
    rts
    
White_Castle:
    bsr     decorate
    lea     $3100,A2
    move.b  #1,D1
    ADD     D1,(A2)
    lea     White_Stats,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    jmp     hud
Neverwinter:
    bsr     decorate
    lea     $3100,A2
    move.b  #4,D1
    ADD     D1,(A2)
    lea     Neverwinter_Stats,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    jmp     hud
Emerald_Castle:
    bsr     decorate
    lea     $3100,A2
    move.b  #3,D1
    ADD     D1,(A2)
    lea     Emerald_Stats,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    jmp     hud
Sand_Castle:
    bsr     decorate
    lea     $3100,A2
    move.b  #2,D1
    ADD     D1,(A2)
    lea     Sand_Stats,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    jmp     hud
*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     horses          branch to ship input subroutine
    bsr     stableboy
    bsr     soldiers        branch to soldiers input subroutine
    bsr     feed            branch to feed input subroutine
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine   
    bsr     hud             branch to display HUD subroutine      
    bsr     gameplay        branch to gameplay subroutine   
    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts     
    
*-------------------------------------------------------
*-----------------------Horse feed-----------------------
* Input the feed load for each horse. Feed costs money
* For an advanced mark you need to manage this resource
*------------------------------------------------------- 
feed:
    bsr     endl
    bsr     decorate
    move.l  $5000,A3
    lea     feed_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    move.l  A3,D2
    CMP     D2,D1
    BGT     insufficient_feed
    SUB     D1,D2
    move.l  D2,A3
    move.l  A3,$5000  
    bsr     decorate
    jmp     gameloop

insufficient_feed:
    lea     insuf_funds,A1
    move.b  #14,D0
    trap    #15
    bsr     feed
 

*-------------------------------------------------------
*--------------------Horses Inventory---------------------
* Number of horses to be allocated to a mission 
*------------------------------------------------------- 
horses:
    bsr     endl
    bsr     decorate
    lea     $3400,A2
    move.b  #3,D1
    ADD     D1,(A2)
    lea     $7000,A3
    lea     horses_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    MOVE.b  (A5),D2
    CMP     D2,D1
    BGT     insufficient_gold
    ADD     D1,(A3)
    SUB     D1,D2
    move.b  D2,(A5)
    bsr     decorate
    jmp     stableboy
    
insufficient_gold:
    lea     insuf_funds,A1
    move.b  #14,D0
    trap    #15
    bsr     horses

    
stableboy:
    bsr     endl
    bsr     decorate
    lea     $8500,A3
    lea     stable_boy_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    MOVE.b  (A5),D2
    CMP     D2,D1
    BGT     insufficient_gold_stableboys
    ADD     D1,(A3)
    SUB     D1,D2
    move.b  D2,(A5)
    jmp     soldiers
    
insufficient_gold_stableboys:
    lea     insuf_funds,A1
    move.b  #14,D0
    trap    #15
    bsr     stableboy



*-------------------------------------------------------
*-----------------------Soldiers----------------------
* Number of soldiers
*-------------------------------------------------------   
soldiers:
    bsr     endl
    bsr     decorate
    lea     $8000,A3
    lea     soldiers_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    MOVE.b  (A5),D2
    CMP     D2,D1
    BGT     insufficient_gold_soldiers
    ADD     D1,(A3)
    SUB     D1,D2
    move.b  D2,(A5)
    bsr     decorate
    jmp     feed
    
insufficient_gold_soldiers:
    lea     insuf_funds,A1
    move.b  #14,D0
    trap    #15
    bsr     soldiers


*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:

    bsr     endl
    bsr     decorate
    lea     victory_msg,A1
    move.b  #14,D0
    trap    #15    

    jmp     intro

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     $7000,A6
    lea     num_horses,A1
    move.b  #14,D0
    trap    #15
    move.b  (A6),D1     
    move.b  #3,D0       
    trap    #15  
    bsr     endl
    lea     $8000,A6
    lea     num_soldiers,A1
    move.b  #14,D0
    trap    #15
    move.b  (A6),D1     
    move.b  #3,D0       
    trap    #15  
    bsr     endl
    lea     $8500,A6
    lea     num_stable_boys,A1
    move.b  #14,D0
    trap    #15
    move.b  (A6),D1     
    move.b  #3,D0       
    trap    #15 
    bsr     endl 
    lea     $6000,A6
    lea     num_gold,A1
    move.b  #14,D0
    trap    #15
    move.b  (A6),D1     
    move.b  #3,D0      
    trap    #15 
    bsr     endl 
    lea     $5000,A6
    lea     num_feed,A1
    move.b  #14,D0
    trap    #15
    move.l  (A6),D1     
    move.l  #3,D0       
    trap    #15  
    bsr     endl
    bsr     decorate
    rts
    
*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'ZorkQuest: Assault on Egreth Castle'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A,0
intro_msg:      dc.b    'In a land far far away there were five waring castles, Emerald Castle,'
                dc.b    $0D,$0A
                dc.b    'Neverwinter, White Castle,Sand Castle and your kingdom Cloveshire Castle.'
                dc.b    $0D,$0A
                dc.b    'One of the four other castles having taken your bride to be.'
                dc.b    $0D,$0A
                dc.b    'Your men are at the ready to storm every castle in the land to find her but,'
                dc.b    $0D,$0A
                dc.b    'where will you begin.'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    '1.Emerald Castle'
                dc.b    $0D,$0A
                dc.b    '2.Neverwinter'
                dc.b    $0D,$0A
                dc.b    '3.White Castle'
                dc.b    $0D,$0A
                dc.b    '4.Sand Castle'
                dc.b    $0D,$0A
                dc.b    '',0
feed_msg:       dc.b    'Feed load (each horse needs at least 100 units of feed)'
                dc.b    $0D,$0A
                dc.b    'Enter feed load : ',0
horses_msg:     dc.b    'Horses cost 1 gold but must be accompanied by a stable boy'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'How many do you want to buy? : ',0
stable_boy_msg  dc.b    'Stable boys cost 1 gold but dont need to be replaced'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'How many do you want to buy? : ',0
soldiers_msg:   dc.b    'Each horse need at least 1 Knight and Stable Hand'
                dc.b    $0D,$0A
                dc.b    'minimum requirement is 2 i.e. Stable Hand x 1 and Knight x 1.'
                dc.b    $0D,$0A
                dc.b    'How many do you want to buy? : ',0
gameplay_msg:   dc.b    'Add Gameplay !',0
update_msg:     dc.b    'Update Gameplay !',0
loop_msg:       dc.b    '.',0
num_horses:     dc.b    'Horses: ',0
num_soldiers:   dc.b    'Soldiers: ',0
num_stable_boys dc.b    'Stable_Boys: ',0
num_gold:       dc.b    'Gold: ',0
num_feed:       dc.b    'Feed: ',0
insuf_funds:    dc.b    'You have insufficant funds ! ',0
Emerald_Stats:  dc.b    'The Emerald Castle Stats:'
                dc.b     $0D,$0A
                dc.b    'Defense: 3'
                dc.b     $0D,$0A
                dc.b    'Treasure: 15 gold'
                dc.b     $0D,$0A
                dc.b    'Feed supplies: 500 units'
                dc.b     $0D,$0A
                dc.b    'Attack: 2',0
White_Stats:    dc.b    'The White Castle Stats:'
                dc.b     $0D,$0A
                dc.b    'Defence: 4'
                dc.b     $0D,$0A
                dc.b    'Treasure: 18 gold'
                dc.b     $0D,$0A
                dc.b    'Feed Supplies: 600'
                dc.b     $0D,$0A
                dc.b    'Attack: 4',0
Sand_Stats:     dc.b    'The Sand Castle Stats:'
                dc.b     $0D,$0A
                dc.b    'Defence: 6'
                dc.b     $0D,$0A
                dc.b    'Treasure: 36 gold'
                dc.b     $0D,$0A
                dc.b    'Feed Supplies: 1300'
                dc.b     $0D,$0A
                dc.b    'Attack: 7',0
Neverwinter_Stats: dc.b    'Neverwinters Stats:'
                dc.b     $0D,$0A 
                dc.b    'Defence: 10'
                dc.b     $0D,$0A
                dc.b    'Treasure: 30 gold'
                dc.b     $0D,$0A
                dc.b    'Feed Supplies: 1500'
                dc.b     $0D,$0A
                dc.b    'Attack: 12',0
victory_msg     dc.b    'VICTORY!',0
loss_msg        dc.b    'DEFEAT!',0


health:     ds.w    1
score:      ds.w    1 reserve space for score

    end start








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
