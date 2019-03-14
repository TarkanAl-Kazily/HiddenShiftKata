namespace HiddenShiftKata
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	
	function GaussianElimination(matrix_: Bool[][]) : Bool[][] {
		mutable matrix = matrix_;
		mutable minPivotRow = -1;
		for (column in 0..Length(matrix[0])-1) {
			mutable pivotRow = -1;
			for (row in minPivotRow+1..Length(matrix)-1) {
				if (matrix[row][column] && pivotRow == -1) {
					set pivotRow = row;
					// Add the other rows when needed
					for (i in 0..Length(matrix)-1) {
						if (matrix[i][column] && i != row) {
							set matrix = AddRows(matrix, row, i);
						}
					}
				} 
			}
			set minPivotRow = pivotRow;
		}

		return matrix;
	}

	function AddRows(matrix_: Bool[][], srcRow: Int, destRow: Int) : Bool[][] {
		mutable matrix = matrix_;
		for (col in 0..Length(matrix[0])-1) {
			set matrix[destRow][col] = XOR(matrix[destRow][col], matrix[srcRow][col]);
		}
		return matrix;
	}
}
