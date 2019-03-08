
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
                if (((s >>> i) % 2) == 1) {
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
                ModularAddProductLE(1, 2^N, LittleEndian(x), LittleEndian(qs));
                f(qs, target);
                Adjoint ModularAddProductLE(1, 2^N, LittleEndian(x), LittleEndian(qs));
                Adjoint PrepareQubitFromInt(qs, s);
            }
        }
        controlled auto;
    }

    // Returns the shifted oracle g(x) = f(x + s).
    function ShiftedOracle(f : ((Qubit[], Qubit) => Unit : Controlled), s : Int) : ((Qubit[], Qubit) => Unit : Controlled) {
        return ShiftedOracleHelper(f, s, _, _);
    }

    operation PhaseFlipOracleHelper(f : ((Qubit[], Qubit) => Unit : Controlled), x : Qubit[]) : Unit {
        body (...) {
            let N = Length(x);
            using (b = Qubit()) {
                X(b);
                H(b);
                f(x, b);
                H(b);
                X(b);
            }
        }
        controlled auto;
    }

    function PhaseFlipOracle(f : ((Qubit[], Qubit) => Unit : Controlled)) : ((Qubit[]) => Unit : Controlled) {
        return PhaseFlipOracleHelper(f, _);
    }

    //--------------------------------------------------------------------
    operation AlgorithmOne(N : Int, oracledualf : ((Qubit[]) => Unit), oracleg : ((Qubit[]) => Unit)) : Int {
        mutable res = 0;
        using (qs = Qubit[N]) {
            ApplyToEach(H, qs);
            oracleg(qs);
            ApplyToEach(H, qs);
            oracledualf(qs);
            ApplyToEach(H, qs);
            set res = MeasureInteger(LittleEndian(qs));
            ResetAll(qs);
        }
        return res;
    }
}
