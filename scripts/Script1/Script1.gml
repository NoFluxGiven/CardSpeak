// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function addCatspeakBaseFunctions() {
	catspeak_add_function( "getEffectsService", function() {
		return {
			"begin": function() {
			},
			"resolve": function() {
			},
			"damage": function( targets, amount ) {
				for (var i=0;i<array_length( targets );i++) {
					var t = targets[i];
					
					t.hp -= amount;
				}
			}
		}
	} );
	catspeak_add_function("getTargetingService", function() {
		global.TARGETING_LIST = [];
		return {
			"list": [],
			"begin": function( ) {
				show_debug_message("Targeting Service Begin");
			},
			
			"resolve": function( ) {
				show_debug_message("Targeting Service Resolved");
				return global.TARGETING_LIST;
			},
			
			"cancel": function( ) {
				show_debug_message("Targeting Service Cancelled");
			},
			
			"get": function( ) {
				return array_union( global.TARGETING_LIST, [] );
			},
			
			"Filters": {
				"all": function() {
					global.TARGETING_LIST = [];
					
					with (objCreature)
						array_push( global.TARGETING_LIST, self );
				},
				"clear": function() {
					global.TARGETING_LIST = [];
				},
				"random": function( n ) {
					global.TARGETING_LIST = array_shuffle( global.TARGETING_LIST );
					array_delete( global.TARGETING_LIST, n, array_length( global.TARGETING_LIST ) )
				},
				"enemiesOf": function( instance ) {
					var newlist = [];
					for (var i=0;i<array_length(global.TARGETING_LIST);i++) {
						var t = global.TARGETING_LIST[i];
						
						if (!instance_exists(t)) continue;
						
						if ( t.team != instance.team )
							array_push( newlist, t );
					}
					
					show_debug_message("Enemies Of");
					
					global.TARGETING_LIST = newlist;
				}
			},
			
			"Actions": {
				"select": function( list, n ) {
					var response = "Player selects "+string(n)+" from "+string_join_ext(",", global.TARGETING_LIST);

				}
			}
		}
	})
}

function compileCatspeak(){
	var process = catspeak_compile_string(@"
	let Targeting = getTargetingService()
	    Targeting.Filters.all()
	    Targeting.Filters.enemiesOf( Context.caster )
	    Targeting.Filters.random( 1 )

	let targets = Targeting.get()

	    Targeting.Filters.all()
	    Targeting.Filters.enemiesOf( Context.caster )
	    Targeting.Filters.random( 1 )

	let otherTargets = Targeting.get()

	let Effects = getEffectsService()
	    Effects.damage( targets, Context.values.damage )
	    Effects.damage( otherTargets, Context.values.damage * 2 )
	")
	
	process = process.andThen( function( code ) {
		program = code;
	} );
	
	process.andCatch( function(err) {
		show_message(err);
	});
	
	return process;
}