Namespace bunnies

#Import "assets/wabbit_alpha.png"

#Import "<std>"
#Import "<mojo>"
#Import "source/atlas"

Using std..
Using mojo..

Const bunnyAtlas := New Atlas( "asset::wabbit_alpha.png", 32, 64 )
Const initialCount := 10000

Function Main()
	New AppInstance
	New Bunnymark
	App.Run()
End Function


'******************************************************************************************************


Class Bunnymark Extends Window 
	
	Field bunnies := New Stack<Bunny>
	
	Method New()
		Super.New("Bunnymark", 1024, 768, WindowFlags.Resizable )
		For Local n := 0 Until initialCount
			bunnies.Push( New Bunny( 512, 384 ) )
		Next
	End
	
	
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		If Keyboard.KeyReleased(Key.Escape) Then App.Terminate()
		
		For Local bunny:=Eachin bunnies
			bunny.Update()
		Next
		
		bunnyAtlas.DrawBatch( canvas )
		
		canvas.Color = Color.White 
		canvas.DrawRect( 0, 0, App.ActiveWindow.Width , 25 )
		
		canvas.Color = Color.Black
		canvas.DrawText("The Bunnymark ( " + bunnies.Length + " )",10,5)
		canvas.DrawText(" FPS: " + App.FPS, 250, 5 )
		canvas.DrawText(" Left mouse = +10, middle = +100, right = +1000  (hold alt key to remove) ", 450, 5 )
	End	
	
	
	Method OnMouseEvent( event:MouseEvent ) Override

		If event.Type = EventType.MouseDown
			Local _len := 0  
			If event.Button = MouseButton.Left
				_len = 10
			Elseif event.Button = MouseButton.Middle
				_len = 100
			Elseif event.Button = MouseButton.Right
				_len = 1000
			End  
			
			If Keyboard.KeyDown( Key.LeftAlt ) Or Keyboard.KeyDown( Key.RightAlt )
				For Local n := 1 To _len
					If bunnies.Length Then bunnies.Pop()
				Next
			Else
				For Local n := 1 To _len
					bunnies.Push( New Bunny( Mouse.X, Mouse.Y ) )
				Next
			End
		End
		
	End	

End


'******************************************************************************************************


Class Bunny
	
	Global gravity := 0.1
	Global border := 32.0
	
	Field x: Float 
	Field y: Float 
	Field xspeed: Float
	Field yspeed: Float
	Field maxBounce:= 5.0

	Field atlas:Atlas
	Field frame:Int
	
	
	Method New( x: Float, y: Float )
		Self.x = x
		Self.y = y
		
		xspeed = Rnd( -10, 10 )
		frame = Floor( Rnd(0,4) )

		atlas = bunnyAtlas
	End
	
	
	Method Update:Void( )
		yspeed += gravity

		y += yspeed
		x += xspeed
		
		If y < border*2
			y = border*2
			yspeed *= -1
			yspeed = Clamp( yspeed, 0.0, Float( maxBounce ) )
		End
		
		If y > App.ActiveWindow.Height - border
			y = App.ActiveWindow.Height - border
			yspeed = -random.Rnd( maxBounce * 3 )
		End
		
		If( x < border ) Or ( x > App.ActiveWindow.Width - border )
			xspeed *= -1
			x = Clamp( x, border, Float(App.ActiveWindow.Width - border ) )
		End
		
		atlas.QueueSprite( x, y, frame )
	End
	
End
