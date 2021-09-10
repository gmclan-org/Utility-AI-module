function no_score_mapping(score) {
	gml_pragma("forceinline");
	return score;
}

function reverse_score_mapping(score) {
	gml_pragma("forceinline");
	return 1 - score;
}

function inverse_score_mapping(score) {
	gml_pragma("forceinline");
	return 1 / score;
}

function reverse_inverse_score_mapping(score) {
	gml_pragma("forceinline");
	return 1 - (1 / score);
}

function fast_sigmoid_score_mapping(score) {
	gml_pragma("forceinline");
	return score / (1 + abs(score));
}

function approx_sigmoid_score_mapping(score) {
	gml_pragma("forceinline");
	return score / sqrt(1 + (score * score));
}
