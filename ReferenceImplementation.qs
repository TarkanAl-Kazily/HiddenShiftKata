
//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace HiddenShiftKata
{

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    // Implement the inner product oracle, which is the most basic kind
    // of bent function.
    operation InnerProductOracle(x : Qubit[], target : Qubit) : Unit {
        body (...) {
            let N = Length(x);
            AssertBoolEqual(((N % 2) == 0) && (N > 0), true, "The number of input qubits must be even and positive");
            for (i in 0 .. 2 .. N-1) {
                CCNOT(x[i], x[i+1], target);
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    operation PrepareQubitFromInt(qs : Qubit[], s : Int) : Unit {
        body (...) {
            let N = Length(qs);
            for (i in 0 .. N - 1)  {
                if (((s >>> i) % 2) == 0) {
                    X(qs[i]);
                }
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    operation ShiftedOracleHelper(f : ((Qubit[], Qubit) => Unit : Controlled), s : Int, x : Qubit[], target : Qubit) : Unit {
        body (...) {
            let N = Length(x);
            using (qs = Qubit[N]) {
                PrepareQubitFromInt(qs, s);
                ModularAddProductLE(1, N^2, LittleEndian(x), LittleEndian(qs));
                f(qs, target);
                Adjoint ModularAddProductLE(1, N^2, LittleEndian(x), LittleEndian(qs));
                Adjoint PrepareQubitFromInt(qs, s);
            }
        }
        controlled auto;
    }

    // Returns the shifted oracle g(x) = f(x + s).
    function ShiftedOracle(f : ((Qubit[], Qubit) => Unit : Controlled), s : Int) : ((Qubit[], Qubit) => Unit : Controlled) {
        return ShiftedOracleHelper(f, s, _, _);
    }

}
