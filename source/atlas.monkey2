'Atlas class by Leo Santos. Feel free to use and/or modify, with credit.

Namespace mojo.graphics

Class Atlas

	Protected

	Field texture:Texture
	Field coordinates:= New Stack<Rect<Double>>		'A stack containing the UV coordinates for each cell
	
	Field rows:Int									'Number of rows in the original image file
	Field columns:Int								'Number of collumns in the original image file
	Field cellWidth:Double							'The width of an individual cell (frame or tile), in pixels
	Field cellHeight:Double							'The height of an individual cell (frame or tile), in pixels
	Field padding :Double							'the gap between cells, in pixels
	Field border :Double							'the gap between the texture's edges and the cells, in pixels
	Field paddedWidth:Double						'the total width of a cell + padding, in pixels
	Field paddedHeight:Double						'the total height of a cell + padding, in pixels
	
	Field handle := New Vec2<Double>( 0.5, 0.5 )	'Handle(pivot) used to draw sprites
	Field img:Image
	
	Field uvStack := New Stack<Stack<Float>>
	Field vertStack := New Stack<Stack<Float>>
	Field queueSize := 0
	
	'*************************************** Public Properties ***************************************
	
	Public
	
	Property Images:Image[]()
		Local images := New Stack<Image>
		For Local n := 0 Until coordinates.Length
			Local c := coordinates[n]
			images.Push( New Image( texture, New Recti( c.Left*texture.Width, c.Top*texture.Height, c.Right*texture.Width, c.Bottom*texture.Height ) ) )
		Next
		Return images.ToArray()
	End
	
	
	Property Coords:Rect<Double>[]()
		Return coordinates.ToArray()	
	End
	
	
	Property Texture:Texture()
		Return texture
	End
	
	
	Property Handle:Vec2<Double>()
		Return handle
	Setter( v:Vec2<Double> )
		handle = v
		
	End
	
	
	'*************************************** Public Methods ***************************************
	
	
	Method New( path:String, _cellWidth:Int, _cellHeight:Int, _padding:Int = 0, _border:Int = 0, _flags:TextureFlags = TextureFlags.FilterMipmap )
		'Loads texture, populates all fields and generates UV coordinates for each cell (frame)
		texture = Texture.Load( path, _flags )
		Assert( texture, " ~n ~nGameGraphics: Image " + path + " not found.~n ~n" )	
		Print ( "New Texture: " + path + "; " + texture.Width + "x" + texture.Height + " Pixels" )
		
		padding = _padding
		border = _border
		cellWidth = _cellWidth
		cellHeight = _cellHeight
		paddedWidth = cellWidth + ( padding * 2 )
		paddedHeight = cellHeight + ( padding * 2 )
		rows = ( texture.Height - border - border ) / paddedHeight
		columns = ( texture.Width - border - border ) / paddedWidth
		
		Local numFrames := rows * columns
		Local w:Double = texture.Width
		Local h:Double = texture.Height
		
		For Local i:= 0 Until numFrames
			Local col := i Mod columns
			Local x:Double = ( col * paddedWidth ) + padding + border
			Local y:Double = ( ( i / columns ) * paddedHeight ) + padding + border
			coordinates.Push( New Rectf( x/w, y/h, (x+cellWidth)/w, (y+cellHeight)/h ) )
		Next
		
		'Sprite queue
		img = New Image( texture )
		For Local n := 0 Until 8
			uvStack[n] = New Stack<Float>
			vertStack[n] = New Stack<Float>
		Next
		
		Print ( "New SpriteSheet: " + rows + "x" + columns )
	End
	
	
	Method QueueSprite( x:Float, y:Float, frame:Int )
		queueSize += 1
		Local group :Int = Floor( queueSize / 15000 )
		If Not vertStack[group] Then vertStack.Push( New Stack<Float> )
		If Not uvStack[group] Then uvStack.Push( New Stack<Float> )
		
		Local w := cellWidth
		Local h := cellHeight
		Local offsetX := cellWidth * handle.X
		Local offsetY := cellHeight * handle.Y
		
		vertStack[group].Push( x - offsetX )
		vertStack[group].Push( y - offsetY )
		vertStack[group].Push( x - offsetX + w )
		vertStack[group].Push( y - offsetY )
		vertStack[group].Push( x - offsetX + w )
		vertStack[group].Push( y - offsetY + h )
		vertStack[group].Push( x - offsetX )
		vertStack[group].Push( y - offsetY + h )
		
		uvStack[group].Push( coordinates[frame].Left )
		uvStack[group].Push( coordinates[frame].Top )
		uvStack[group].Push( coordinates[frame].Right )
		uvStack[group].Push( coordinates[frame].Top )
		uvStack[group].Push( coordinates[frame].Right )
		uvStack[group].Push( coordinates[frame].Bottom )
		uvStack[group].Push( coordinates[frame].Left )
		uvStack[group].Push( coordinates[frame].Bottom )
	End
	
	
	Method DrawBatch( canvas:Canvas )
		For Local n := 0 To Int(Floor( queueSize / 15000 ))
			If vertStack[n].Length >= 8
'				canvas.DrawText( "group " + n, (100*n) + 10, App.ActiveWindow.Height - 18 )	'for group debugging
				canvas.DrawPrimitives( 4, vertStack[n].Length/8, vertStack[n].Data.Data, 8, uvStack[n].Data.Data, 8, Null, 4, img, Null )
			End
			vertStack[n].Clear()
			uvStack[n].Clear()
		Next
		
		queueSize = 0
	End

End
