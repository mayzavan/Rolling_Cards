extends Node2D

@export var dice_scene: PackedScene
@export var card_scene: PackedScene
@export var heart_scene: PackedScene
@export var dice_table_scene: PackedScene
@export var card_table_scene:PackedScene

var dices: Array = []
var cards: Array = []
var hearts: Array = []

var score: int = 0
var scores_array: Array = []
var lifes: int = 3

var cards_amount: Array = [7,4]
var dice1: int = 0
var dice2: int = 0
var dice_sum: int = 0
var time_left: float = 0
var seconds: float = 0

var clicked_cards: Array = []

var playing: bool = false
var counting: bool = false
var lost: bool = false

var round: int = 0

var cards0 : Array = [0,7,30,37]
var cards1 : Array = [1,8,31,38]
var cards2 : Array = [2,9,32,39]
var cards3 : Array = [3,10,33,40]
var cards4 : Array = [4,11,34,41]
var cards5 : Array = [5,12,35,42]
var cards6 : Array = [6,13,36,28]
var cards7 : Array = [15,21,45,52]
var cards8 : Array = [16,22,46,53]
var cards9 : Array = [17,23,47,43]
var cards_empty : Array = [14,20,26,51]
var cards_block : Array = [18,24,48,44]
var cards_plus2 : Array = [19,25,50,49]
var cards_plus4 : int = 27
var card_joker : int = 29

var norml : int = 0
var badnorml : int = 0
var bll : int = 0
var emptl : int = 0
var plus2l : int = 0
var plus4l : int = 0
var jokersl : int = 0

var round_limit : int = 7

var goodscore : int = 20
var badscore : int = -40
var emptyscore : int = 30
var plus2score : int = 200
var plus4score : int = 400
var jokermultiplier : int = 2
var heartscore : int = 1000

func _ready():
	Global.load()
	$MainMenuUI/Label2.text = "Best score: " + str(Global.highscore)

func setup_game():
	for a in lifes:
		await get_tree().create_timer(0.05).timeout
		$putting_boardSFX.play()
		var heart = heart_scene.instantiate()
		heart.position.y = 30
		heart.position.x = 30 + (45 * a)
		hearts.append(heart)
		add_child(heart)
	for b in 2:
		await get_tree().create_timer(0.05).timeout
		$putting_boardSFX.play()
		var dice = dice_scene.instantiate()
		dice.position.y = 220 + 80 * b
		dice.position.x = 50
		dices.append(dice)
		add_child(dice)
	for c in cards_amount[1]:
		for d in cards_amount[0]:
			await get_tree().create_timer(0.05).timeout
			$putting_boardSFX.play()
			var card = card_scene.instantiate()
			card.position.y = 135 + 100 * c
			card.position.x = 170 + 80 * d
			card.frame = 54
			cards.append(card)
			add_child(card)
	await get_tree().create_timer(0.05).timeout
	$putting_boardSFX.play()
	$ScoreLabel.text = "Score: " + str(score)
	$TimeLabel.text = "Time: "
	$ScoreLabel.show()
	$TimeLabel.show()
	await get_tree().create_timer(1.5).timeout
	roll_dice()

func _process(delta):
	if counting or playing:
		time_left -= delta
		if time_left <=0:
			$Timer.stop()
			time_left = 0
			if playing:
				playing = false
				end_round()
			if counting:
				counting = false
	seconds = fmod(time_left, 60)
	$TimeLabel.text = "Time: " + str(int("%02d." % seconds))

func roll_dice():
	var time = 0.1
	for a in 15:
		await get_tree().create_timer(time).timeout
		$dice_throwSFX.play()
		time += a*0.005
		for dice in dices:
			dice.frame = randi_range(0,5)
	dice1 = randi_range(1,6)
	dice2 = randi_range(1,6)
	dice_sum = dice1 + dice2
	dices[0].frame = dice1 - 1
	dices[1].frame = dice2 - 1
	await get_tree().create_timer(1).timeout
	shuffle_cards()
	table_dices()

func shuffle_cards():
	for card in cards:
		card.frame = randi_range(0,53)
	time_left = 11
	counting = true
	$Timer.start()
	await get_tree().create_timer(10).timeout
	prepare_game()

func prepare_game():
	for card in cards:
		card.value = card.frame
		card.frame = 54
		card.clickable = true
	time_left = 6
	$Timer.start()
	playing = true

func end_round():
	playing = false
	for card in cards:
		card.clickable = false
		if card.clicked == true:
			card.frame = card.value
			clicked_cards.append(card.value)
	count_score()

func table_dices():
	var dicet = dice_table_scene.instantiate()
	dicet.position.x = 715
	dicet.position.y = 90 + 60 * round
	dicet.frame = dice1 - 1
	add_child(dicet)
	var dicet2 = dice_table_scene.instantiate()
	dicet2.position.x = 715
	dicet2.position.y = 115 + 60 * round
	dicet2.frame = dice2 - 1
	add_child(dicet2)

func table_cards():
	var i = 0
	for a in clicked_cards:
		a = card_table_scene.instantiate()
		a.position.x = 735 + 8 * i
		a.position.y = 100 + 60 * round
		a.frame = clicked_cards[i]
		add_child(a)
		i += 1

func count_score():
	table_cards()
	scores_array.append(0)
	for card in clicked_cards:
		if card in cards_block:
			lifes -= 1
			draw_lifes()
			bll += 1
			if lifes <= 0:
				lost = true
				finish_game()
	for card in clicked_cards:
		if card in cards_empty:
			scores_array[round] += emptyscore
			emptl += 1
		
		elif card in cards0:
			scores_array[round] += badscore
			badnorml += 1
		elif card in cards1:
			if dice1 == 1 or dice2 == 1:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards2:
			if dice1 == 2 or dice2 == 2:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards3:
			if dice1 == 3 or dice2 == 3 or dice_sum == 3:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards4:
			if dice1 == 4 or dice2 == 4 or dice_sum == 4:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards5:
			if dice1 == 5 or dice2 == 5 or dice_sum == 5:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards6:
			if dice1 == 6 or dice2 == 6 or dice_sum == 6:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards7:
			if dice1 == 7 or dice2 == 7 or dice_sum == 7:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards8:
			if dice1 == 8 or dice2 == 8 or dice_sum == 8:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
		elif card in cards9:
			if dice1 == 9 or dice2 == 9 or dice_sum == 9:
				scores_array[round] += goodscore
				norml += 1
			else:
				scores_array[round] += badscore
				badnorml += 1
	for card in clicked_cards:
		if card in cards_plus2:
			scores_array[round] += plus2score
			plus2l += 1
		elif card == cards_plus4:
			scores_array[round] += plus4score
			plus4l += 1
	for card in clicked_cards:
		if card == card_joker:
			scores_array[round] *= jokermultiplier
			jokersl += 1
	clicked_cards.clear()
	score += int(scores_array[round])
	$ScoreLabel.text = "Score: " + str(score)
	if round < round_limit - 1 and !lost:
		next_round()
	else:
		finish_game()

func next_round():
	round += 1
	await get_tree().create_timer(3).timeout
	for card in cards:
		card.frame = 54
		card.clickable = false
		card.clicked = false
	roll_dice()

func finish_game():
	for life in lifes:
		score += heartscore
	if score >= Global.highscore:
		Global.highscore = score
	Global.save()
	$ENDUI/norml.text = str(norml) + " cards"
	$ENDUI/badnorml.text = str(badnorml) + " cards"
	$ENDUI/bll.text =  str(bll) + " cards"
	$ENDUI/emptl.text =  str(emptl) + " cards"
	$"ENDUI/4l".text =  str(plus4l) + " cards"
	$"ENDUI/2l".text = str(plus2l) + " cards"
	$ENDUI/jokersl.text =  str(jokersl) + " cards"
	$ENDUI/heartlabel.text = "You have " +str(lifes) + " hearts"
	$ENDUI/pointlabel.text = "and " + str(score) + " points"
	$ENDUI.show()

func draw_lifes():
	for life in hearts:
		life.queue_free()
	hearts.clear()
	for a in lifes:
		var heart = heart_scene.instantiate()
		heart.position.y = 30
		heart.position.x = 30 + (45 * a)
		hearts.append(heart)
		add_child(heart)

func _on_playagain_pressed():
	get_tree().reload_current_scene()

func _on_timer_timeout():
	$timerSFX.play()

func _on_playbutton_pressed():
	$MainMenuUI.hide()
	setup_game()

func _on_settbutton_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_h_2_pbutton_pressed():
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
