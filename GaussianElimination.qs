namespace HiddenShiftKata
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	///
	/// Returns an array of bool vectors which together form the basis of the null space
	///
	function KernelMod2(matrix: Int[][]) : Int[][] {
		let reduced = GaussianEliminationMod2(matrix);
		let rank = QuickRank(reduced);
		let nullSpaceDims = Length(matrix[0]) - rank;
		
		mutable result = new Int[][nullSpaceDims];
		for (i in 0..nullSpaceDims-1) {
			set result[i] = new Int[Length(matrix[0])];
			for (j in 0..rank-1) {
				set result[i][j] = reduced[j][i+rank];
			}
		}

		for (i in 0..nullSpaceDims-1) {
			set result[i][i+rank] = 1;
		}

		return result;
	}

	function RankMod2(matrix: Int[][]) : Int {
		return QuickRank(GaussianEliminationMod2(matrix));
	}

	/// Assumes the matrix is in row echelon form
	function QuickRank(matrix: Int[][]) : Int {
		mutable zeroRows = 0;
		for (i in 0..Length(matrix)-1) {
			mutable onlyZeroes = true;
			for (j in 0..Length(matrix[i])-1) {
				if (matrix[i][j] != 0) {
					set onlyZeroes = false;
				}
			}

			if (onlyZeroes) {
				set zeroRows = zeroRows + 1;
			}
		}
		return Length(matrix) - zeroRows;
	}

	function GaussianEliminationMod2(matrix_: Int[][]) : Int[][] {
		mutable matrix = matrix_;
		mutable minPivotRow = 0;
		for (column in 0..Length(matrix[0])-1) {
			mutable pivotRow = -1;
			for (row in minPivotRow..Length(matrix)-1) {
				if (matrix[row][column] == 1 && pivotRow == -1) {
					set pivotRow = row;
					// Add the other rows when needed
					for (i in 0..Length(matrix)-1) {
						if (matrix[i][column] == 1 && i != row) {
							set matrix = AddRowsMod2(matrix, row, i);
						}
					}
				} 
			}

			if (pivotRow != -1) {
				let temp = matrix[minPivotRow];
				set matrix[minPivotRow] = matrix[pivotRow];
				set matrix[pivotRow] = temp;
			}

			set minPivotRow = minPivotRow + 1;
		}

		return matrix;
	}

	function AddRowsMod2(matrix_: Int[][], srcRow: Int, destRow: Int) : Int[][] {
		mutable matrix = matrix_;
		for (col in 0..Length(matrix[0])-1) {
			set matrix[destRow][col] = matrix[destRow][col] ^^^ matrix[srcRow][col];
		}
		return matrix;
	}
}
