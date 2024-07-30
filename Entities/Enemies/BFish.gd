extends EnemyBase

#Behavior:
#Swim idle left/right at var distance
#When Player enters eyesight body,agro
#When Agro, swim towards player at 3*60*delta
#if player if above water, jump at them.
#If sight of either player is lst for 3 seconds, lose agro, swim home
#Return to idel state once home, unless player seen again.

@export var distance = 160


