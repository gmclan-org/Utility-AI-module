_health = choose(70, 80, 90, 100);
_strength = choose(10, 20, 30);
_reasonDelay = choose(0.7, 0.8, 0.9, 1);
_reasonAccum = choose(0, 0.25, 0.5, 0.75);
_path = undefined;

var states = [
	new ExampleStateIdle(
		new UtilityConsiderationConstant(0.01),
	),
	new ExampleStateAttack(
		ExampleNPC,
		choose(0.7, 0.8, 0.9, 1),
		new ExampleConsiderationObjectInRange(ExampleNPC, 0, 32),
	),
	new ExampleStateFollow(
		ExampleFish,
		false,
		new UtilityEvaluatorMultiply([
			new ExampleConsiderationObjectMinCount(ExampleFish, 1),
			new ExampleConsiderationHealth(100, reverse_score_mapping),
		]),
	),
	new ExampleStateFollow(
		ExampleGold,
		false,
		new UtilityEvaluatorMultiply([
			new ExampleConsiderationObjectMinCount(ExampleGold, 1),
			new UtilityEvaluatorSum([
				new ExampleConsiderationRelativeStrength(20, reverse_score_mapping),
				new ExampleConsiderationHealth(100, reverse_score_mapping),
			]),
		]),
	),
	new ExampleStateFollow(
		ExampleNPC,
		true,
		new UtilityEvaluatorMultiply([
			new ExampleConsiderationObjectMinCount(ExampleNPC, 2),
			new ExampleConsiderationObjectInRange(ExampleNPC, 24, infinity),
			new ExampleConsiderationRelativeStrength(30, fast_sigmoid_score_mapping),
		]),
	),
];
_agent = new UtilityAgent(states, self);
