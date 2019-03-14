namespace HiddenShiftKata.GaussianEliminationTests
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	open HiddenShiftKata;

	// Dummy to name the test group
	operation AGaussianEliminationTest() : Unit {}

    operation BasicTest () : Unit
    {
        let result = GaussianElimination([
			[true, false],
			[true, true]
		]);

		AssertBoolMatrixEqual(result, [
			[true, false],
			[false, true]
		], "");
    }

	operation OnlyFlipIfTrueTest () : Unit
    {
		// In the second column, only one value is true, so none of the rows should be modified
        let result = GaussianElimination([
			[true, false, true, false],
			[false, true, true, false],
			[false, false, false, false]
		]);

		AssertBoolMatrixEqual(result, [
			[true, false, true, false],
			[false, true, true, false],
			[false, false, false, false]
		], "");
    }

	operation FlipIfTrueTest () : Unit
    {
		// In the second column, both the first and third rows and added with the second
        let result = GaussianElimination([
			[true, true, true, false],
			[false, true, true, false],
			[false, true, false, false]
		]);

		AssertBoolMatrixEqual(result, [
			[true, false, false, false],
			[false, true, false, false],
			[false, false, true, false]
		], "");
    }

	function AssertBoolMatrixEqual(actual: Bool[][], expected: Bool[][], message: String) : Unit {
		AssertIntEqual(Length(actual), Length(expected), message);
		for (i in 0..Length(actual)-1) {
			AssertBoolArrayEqual(actual[i], expected[i], message);
		}
	}
}
