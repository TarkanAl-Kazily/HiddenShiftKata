namespace HiddenShiftKata.GaussianEliminationTests
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	open HiddenShiftKata;

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

	operation DoSwapsTest() : Unit
    {
		// In the second column, both the first and third rows and added with the second
        let result = GaussianElimination([
			[false, false, true, false],
			[false, true, false, false],
			[true, false, false, false]
		]);

		AssertBoolMatrixEqual(result, [
			[true, false, false, false],
			[false, true, false, false],
			[false, false, true, false]
		], "");
    }
	
	operation EliminateRowTest() : Unit
    {
        let result = GaussianElimination([
			[false, false, true, false],
			[false, true, false, false],
			[false, true, false, false],
			[true, false, false, false]
		]);

		AssertBoolMatrixEqual(result, [
			[true, false, false, false],
			[false, true, false, false],
			[false, false, true, false],
			[false, false, false, false]
		], "");
    }

	operation BasicKernelTest() : Unit
    {
        let result = Kernel([
			[true, false, false, false],
			[false, true, false, false],
			[false, false, true, false],
			[false, false, false, false]
		]);

		AssertSubspaceEqual(result, [
			[false, false, false, true]
		], "");
    }

	operation TrickyKernelTest() : Unit
    {
        let result = Kernel([
			[true, false, false, true],
			[false, true, true, true]
		]);
		
		AssertSubspaceEqual(result, [
			[true, true, false, true],
			[false, true, true, false]
		], "");
    }
	

	function AssertBoolMatrixEqual(actual: Bool[][], expected: Bool[][], message: String) : Unit {
		AssertIntEqual(Length(actual), Length(expected), message);
		for (i in 0..Length(actual)-1) {
			AssertBoolArrayEqual(actual[i], expected[i], message);
		}
	}

	function AssertSubspaceEqual(actualBasis: Bool[][], expectedBasis: Bool[][], message: String) : Unit {
		AssertIntEqual(Length(actualBasis), Length(expectedBasis), message);
		for (i in 0..Length(actualBasis)-1) {
			mutable foundMatch = false;
			for (j in 0..Length(expectedBasis) - 1) {
				set foundMatch = foundMatch || BoolVectorEqual(actualBasis[i], expectedBasis[j]);
			}
			AssertBoolEqual(foundMatch, true, message);
		}
	}

	function BoolVectorEqual(a: Bool[], b: Bool[]) : Bool {
		if (Length(a) != Length(b)) {
			return false;
		}

		mutable equal = true;
		for (i in 0..Length(a)-1) {
			set equal = equal && a[i] == b[i];
		}

		return equal;
	}
}
