Namespace bunnies

#Import "assets/wabbit_alpha.png"

#Import "<std>"
#Import "<mojo>"
#Import "atlas"

Using std..
Using mojo..

Const bunnyAtlas := New Atlas( "asset::wabbit_alpha.png", 32, 64 ).Images	'Property .Images returns an image array

Function Main()
	New AppInstance
	New Bunnymark
	App.Run()
End Function


'******************************************************************************************************


Class Bunnymark Extends Window 
	
	Field frames := 1
	Field elapsed := 1
	Field bunnies := New Stack<Bunny>
	
	Method New()
		Super.New("Bunnymark", 1024, 768, WindowFlags.Resizable )
		For Local i:=0 Until bunnies.Length
			bunnies.Push( New Bunny( 0, 0 ) )
		Next
	End
	
	
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		If Keyboard.KeyReleased(Key.Escape) Then App.Terminate()
		
		For Local bunny:=Eachin bunnies
			bunny.Update()
			bunny.Draw(canvas)
		Next
		
		canvas.Color = Color.White 
		canvas.DrawRect( 0, 0, App.ActiveWindow.Width , 25 )
		
		canvas.Color = Color.Black
		canvas.DrawText("The Bunnymark ( " + bunnies.Length + " )",0,0)
		canvas.DrawText(" FPS: " + App.FPS, 300, 0 )
	End	
	
	
	Method OnMouseEvent( event:MouseEvent ) Override
		If event.Type = EventType.MouseDown
			Local _len := 0 
			If event.Button = MouseButton.Left
				_len = 10
			Elseif event.Button = MouseButton.Right
				_len = 1000
			Elseif event.Button = MouseButton.Middle
				_len = -100	
			End  
			
			For Local n := 1 To _len
				bunnies.Push( New Bunny( Mouse.X, Mouse.Y ) )
			Next
			
		End 	
	End	

End


'******************************************************************************************************


Class Bunny
	
	Global gravity := 0.5
	Global border := 32.0
	
	Field x: Float 
	Field y: Float 
	Field xspeed: Float
	Field yspeed: Float
	Field maxBounce:= 5.0

	Field image: Image
	Field frame:Int
	
	
	Method New( x: Float, y: Float )
		Self.x = x
		Self.y = y
		
		xspeed = Rnd( -10, 10 )
		frame = Floor( Rnd(0,4) )
		image = bunnyAtlas[frame]
		image.Handle = New Vec2f( 0.5, 0.5 )
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
			yspeed = -random.Rnd( 35 )
		End
		
		If( x < border ) Or ( x > App.ActiveWindow.Width - border )
			xspeed *= -1
			x = Clamp( x, border, Float(App.ActiveWindow.Width - border ) )
		End
	End
	
	
	Method Draw(canvas:Canvas)
		canvas.DrawImage( image, x, y )
	End
	
End
