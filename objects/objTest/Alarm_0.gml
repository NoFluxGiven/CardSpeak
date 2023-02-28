program.setGlobal( "Context", {
	caster: objPlayer,
	values: {
		damage: 1
	}
} );

catspeak_execute(program)
	.andThen(function(result) {
	})
	.andCatch(function(err) {
		show_message("An error occurred.");
		show_message(err);
	} )
	
alarm[0] = irandom_range(90, 180);