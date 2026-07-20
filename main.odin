package bubbles

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

print :: fmt.print

colors : [4]rl.Color = {rl.RED, rl.GREEN, rl.YELLOW, rl.BLUE}

Ball :: struct {
	x, y :   i32,
	radius : i32,
	color :  rl.Color,
}

Window :: struct {
	width :  i32,
	height : i32,
}

Board :: struct {
	x, y, width, height : i32,
}

GameOptions :: struct {
	radius :    i32,
	padding_x : i32,
	padding_y : i32,
}

Game :: struct {
	window :     Window,
	options :    GameOptions,

	//
	board :      Board,
	balls :      [160]Ball,
	canon_ball : Ball,
}

init :: proc(game : ^Game) {
	game^ = Game {
		board = {x = 40, y = 40, width = 800, height = 800},
		window = {width = 900, height = 900},
		options = {radius = 8, padding_x = 2, padding_y = 2},
	}

	game.canon_ball = {
		radius = game.options.radius,
		x      = game.window.width / 2 + game.options.radius,
		y      = game.window.height - 20,
		color  = rl.BLACK,
	}

	assert(game.window.width >= game.board.width && game.window.height >= game.board.height)
}

setup_balls :: proc(game : ^Game) {
	board := &game.board
	radius := game.options.radius
	balls := &game.balls
	pad_y := game.options.padding_y
	pad_x := game.options.padding_x

	for i : i32 = 0; i < len(balls); i += 1 {
		x := (i) * (radius + pad_x) * 2

		is_odd := x / board.width % 2 == 0
		x_offset := board.x + radius * (i32(is_odd) + 1)

		balls[i].x = x_offset + x % board.width
		balls[i].y = board.y + radius + (x / board.width) * (radius + pad_y) * 2

		balls[i].radius = radius
		balls[i].color = colors[rand.int_max(len(colors))]
	}
}

// draw the ball with a dotted line pointing towards the mouse
draw_canon_with_preview :: proc(ball : Ball) {
	mouse := rl.GetMousePosition()

	// mouse.x
	rl.DrawCircle(ball.x, ball.y, f32(ball.radius), ball.color)

	start : [2]i32 = {ball.x, ball.y - ball.radius * 2}
	end : [2]i32 = {i32(mouse.x), math.min(i32(mouse.y) + 30, start.y)}

	rl.DrawLine(start.x, start.y, end.x, end.y, rl.GRAY)
}

main :: proc() {
	game : Game
	init(&game)
	setup_balls(&game)

	rl.InitWindow(game.window.width, game.window.height, "bubbles")

	board := &game.board
	for !rl.WindowShouldClose() {
		// Events

		// Draw Loop
		rl.BeginDrawing()
		rl.ClearBackground(rl.SKYBLUE)
		rl.DrawRectangle(board.x, board.y, board.width, board.height, rl.SKYBLUE)

		for ball in game.balls {
			rl.DrawCircle(ball.x, ball.y, f32(ball.radius), ball.color)
		}

		draw_canon_with_preview(game.canon_ball)

		rl.EndDrawing()
	}
}
